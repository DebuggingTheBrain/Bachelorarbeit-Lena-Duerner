% === Pfade definieren ===
data_dir = 'G:\ROIs_für_Auswertung\TMS_STimulation_Location\';
atlas_file = fullfile(data_dir, 'TMS_Heatmap.nii');

% === Alle TMS-Masken finden ===
all_files = dir(fullfile(data_dir, 'TMS_FieldMap_Threshold_1_sub-*.nii'));

% === Lade Atlasmaske (binär) ===
VA = spm_vol(atlas_file);
YA = spm_read_vols(VA);
atlas_mask = YA > 0;  % binarisieren

% === Initialisierung ===
overlap_results = struct('Subject', {}, 'PercentInAtlas', []);
voxel_volume = abs(det(VA.mat));  % optional: mm³/Voxel

for i = 1:numel(all_files)
    mask_path = fullfile(all_files(i).folder, all_files(i).name);
    
    % === Lade Einzelmaske ===
    VB = spm_vol(mask_path);
    YB = spm_read_vols(VB);
    
    % === Resample Maske in Atlas-Raum (Nearest-Neighbour) ===
    [Ix, Iy, Iz] = ndgrid(1:VA.dim(1), 1:VA.dim(2), 1:VA.dim(3));
    XYZ_vox_A = [Ix(:)'; Iy(:)'; Iz(:)'; ones(1, numel(Ix))];
    XYZ_world = VA.mat * XYZ_vox_A;
    XYZ_vox_B = VB.mat \ XYZ_world;
    
    xb = round(XYZ_vox_B(1,:));
    yb = round(XYZ_vox_B(2,:));
    zb = round(XYZ_vox_B(3,:));
    
    valid = xb>=1 & xb<=VB.dim(1) & yb>=1 & yb<=VB.dim(2) & zb>=1 & zb<=VB.dim(3);
    linB = sub2ind(VB.dim, xb(valid), yb(valid), zb(valid));
    
    resampled_B = zeros(VA.dim, 'uint8');
    tmp = zeros(numel(Ix), 1, 'uint8');
    tmp(valid) = uint8(YB(linB) > 0);
    resampled_B(:) = tmp;
    
    % === Berechne binäre Maske & Overlap ===
    M = resampled_B > 0;
    volM = sum(M(:));
    overlap_vox = sum(M(:) & atlas_mask(:));
    
    if volM > 0
        percent_in_atlas = 100 * overlap_vox / volM;
    else
        percent_in_atlas = NaN;
    end
    
    % === Speichern ===
    overlap_results(i).Subject = all_files(i).name;
    overlap_results(i).PercentInAtlas = percent_in_atlas;
    
    fprintf('%s: %.2f %% der Maske liegt im Atlas\n', ...
        all_files(i).name, percent_in_atlas);
end

% === Mittelwert & SD ===
all_percents = [overlap_results.PercentInAtlas];
mean_val = mean(all_percents, 'omitnan');
std_val = std(all_percents, 'omitnan');

fprintf('\n== Gesamtergebnis ==\n');
fprintf('Mittelwert: %.2f %%\n', mean_val);
fprintf('Standardabweichung: %.2f %%\n', std_val);

% === Optional: Speichern als CSV ===
csv_file = fullfile(data_dir, 'TMS_Masken_Overlap_Ergebnisse.csv');
fid = fopen(csv_file, 'w');
fprintf(fid, 'Subject,PercentInAtlas\n');
for i = 1:numel(overlap_results)
    fprintf(fid, '%s,%.2f\n', ...
        overlap_results(i).Subject, ...
        overlap_results(i).PercentInAtlas);
end
fclose(fid);
fprintf('CSV gespeichert: %s\n', csv_file);

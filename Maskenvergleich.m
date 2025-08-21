% ===============================%
%   OVERLAP-MESSUNG ZWEIER MASKEN
% ===============================%

% === Eingabedateien ===
maskA = 'F:\FMRIPREPRESULTFINAL\ROIs\Combined_ROI_Sum.nii';     % Referenzmaske A
maskB = 'F:\FMRIPREPRESULTFINAL\ROIs\Frontal_Mid_R.nii';        % Zu resamplende Maske B

% === Ausgabedateien ===
outB        = 'F:\FMRIPREPRESULTFINAL\ROIs\rFrontal_Mid_R_inA_manual.nii';   % resamplte B-Maske in A
overlap_out = 'F:\FMRIPREPRESULTFINAL\ROIs\Overlap_A_and_B.nii';             % Overlap-Maske (A ∩ B)

% === Lade A (ggf. nur 1. Volumen) ===
VA_all = spm_vol(maskA);
if numel(VA_all) > 1
    VA = spm_vol(sprintf('%s,1', maskA));
else
    VA = VA_all;
end
YA = spm_read_vols(VA);    % Daten A

% === Lade B (ggf. nur 1. Volumen) ===
VB_all = spm_vol(maskB);
if numel(VB_all) > 1
    VB = spm_vol(sprintf('%s,1', maskB));
else
    VB = VB_all;
end
YB = spm_read_vols(VB);    % Daten B

% === 1. Resample Maske B → in Raum von A (Nearest-Neighbour) ===
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

% === 2. Binarisiere Masken ===
M1 = YA > 0;            % A
M2 = resampled_B > 0;   % B (resampled)

% === 3. Overlap-Kennzahlen ===
overlap = sum(M1(:) & M2(:));
vol1 = sum(M1(:));
vol2 = sum(M2(:));
voxvol = abs(det(VA.mat));  % mm³/Voxel

fprintf('\nVoxel counts (A-Raum):\n  |A|=%d, |B_resamp|=%d, |A∩B|=%d\n', vol1, vol2, overlap);
fprintf('Volumes (mm^3):  A=%.2f,  B_resamp=%.2f,  A∩B=%.2f\n', vol1*voxvol, vol2*voxvol, overlap*voxvol);
fprintf('%% A in B: %.2f%%\n', 100 * overlap / max(vol1,eps));
fprintf('%% B in A: %.2f%%\n', 100 * overlap / max(vol2,eps));
fprintf('Jaccard:  %.4f\n', overlap / (vol1 + vol2 - overlap + eps));
fprintf('Dice:     %.4f\n', 2*overlap / (vol1 + vol2 + eps));

% === 4. Speichere resamplte B-Maske ===
N1 = nifti;
N1.dat      = file_array(outB, VA.dim, 'uint8', 0, 1, 0);
N1.mat      = VA.mat;
N1.mat0     = VA.mat;
N1.descrip  = 'Frontal_Mid_R resampled into A-space (NN, manual)';
create(N1);
N1.dat(:,:,:) = uint8(M2);

% === 5. Speichere Overlap-Maske ===
N2 = nifti;
N2.dat      = file_array(overlap_out, VA.dim, 'uint8', 0, 1, 0);
N2.mat      = VA.mat;
N2.mat0     = VA.mat;
N2.descrip  = 'Overlap Combined_ROI_Sum ∩ Frontal_Mid_R (manual resample)';
create(N2);
N2.dat(:,:,:) = uint8(M1 & M2);

fprintf('Saved resampled B:   %s\n', outB);
fprintf('Saved overlap image: %s\n', overlap_out);

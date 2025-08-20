%% Skript: Extraktion & Aggregation des MNI-Outputs (Einzelproband, alles unter G:)
% Entpacken mit MATLAB 'gunzip'
% Mittelwertbildung mit SPM (imcalc)

clear; clc;

% ======= Proband-ID HIER FESTLEGEN =======================================
user = "sub-SM2VP025_ses-T1";

% ======= Pfad-Setup ======================================================
baseIn   = 'G:\MNI_Output';                     % subject2mni-Ausgabe
baseOut  = fullfile('G:\MNI_Entpackt');         % Entpack-Zielbasis (neu)
aggOut   = fullfile(baseOut, 'Aggregiert');     % Aggregationsordner

if ~exist(baseOut, 'dir'); mkdir(baseOut); end
if ~exist(aggOut,  'dir'); mkdir(aggOut);  end

inUserDir  = fullfile(baseIn, user);
outUserDir = fullfile(baseOut, ['Pat_', char(user)]);
if ~exist(outUserDir, 'dir'); mkdir(outUserDir); end

if ~exist(inUserDir, 'dir')
    error('Eingabeordner nicht gefunden: %s', inUserDir);
end

fprintf('\n==== %s ====\n', user);

% ---- Alle .nii.gz Dateien rekursiv finden ----
gzFiles = dir(fullfile(inUserDir, '**', '*.nii.gz'));
fprintf('Gefundene .nii.gz-Dateien: %d\n', numel(gzFiles));

% ---- Entpacken ----
for k = 1:numel(gzFiles)
    srcGz = fullfile(gzFiles(k).folder, gzFiles(k).name);

    [~, baseName, ext] = fileparts(gzFiles(k).name); % ext == '.gz'
    if endsWith(baseName, '.nii', 'IgnoreCase', true)
        targetNii = fullfile(outUserDir, baseName);
    else
        targetNii = fullfile(outUserDir, [baseName, '.nii']);
    end

    if exist(targetNii, 'file')
        fprintf('Schon vorhanden (übersprungen): %s\n', targetNii);
        continue;
    end

    try
        gunzip(srcGz, outUserDir);
        fprintf('Entpackt: %s -> %s\n', gzFiles(k).name, outUserDir);
    catch ME
        warning('Entpacken fehlgeschlagen: %s\nGrund: %s', srcGz, ME.message);
    end
end

% ---- Nach dem Entpacken: alle .nii im Patienten-Ordner einsammeln ----
niiFiles = dir(fullfile(outUserDir, '*.nii'));
if isempty(niiFiles)
    error('Keine entpackten NIfTIs gefunden in: %s', outUserDir);
end

% ---- SPM: Mittelwert über alle Bilder --------------------------------
quellen = cell(numel(niiFiles), 1);
for i = 1:numel(niiFiles)
    quellen{i} = [fullfile(niiFiles(i).folder, niiFiles(i).name), ',1'];
end

matlabbatch = [];
matlabbatch{1}.spm.util.imcalc.input           = quellen;
matlabbatch{1}.spm.util.imcalc.output          = sprintf('mean_%s', user);
matlabbatch{1}.spm.util.imcalc.outdir          = {aggOut};
matlabbatch{1}.spm.util.imcalc.expression      = 'mean(X)';
matlabbatch{1}.spm.util.imcalc.var             = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx    = 1;
matlabbatch{1}.spm.util.imcalc.options.mask    = 0;
matlabbatch{1}.spm.util.imcalc.options.interp  = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype   = 4;

% ---- SPM ausführen ----
spm('defaults', 'FMRI');
spm_jobman('initcfg');
spm_jobman('run', matlabbatch);

fprintf('\nMittelwert gespeichert unter: %s\n', aggOut);
fprintf('\nFertig.\n');

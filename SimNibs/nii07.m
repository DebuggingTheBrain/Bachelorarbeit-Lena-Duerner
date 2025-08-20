% Angepasstes Skript für MNI-Output aus Python
% 12.08.2025 - basierend auf Kilian Rolle Vorlage

output_base = 'G:\tutorial_output\sub-SM2VP007_ses-T1';
aggregiert_ordner = 'G:\tutorial_output\Aggregiert';

if ~exist(aggregiert_ordner, 'dir')
    mkdir(aggregiert_ordner);
end

% Suche alle NIfTI-Dateien (E- und magnE)
nii_files = dir(fullfile(output_base, '**', '*_MNI_*.nii.gz'));

% Falls entpacken nötig (SPM liest oft .nii.gz direkt)
entpack_pfad = 'H:\tutorial_output\Entpackt';
if ~exist(entpack_pfad, 'dir')
    mkdir(entpack_pfad);
end

for k = 1:length(nii_files)
    src_file = fullfile(nii_files(k).folder, nii_files(k).name);
    
    % Optional: Entpacken mit 7z, falls nötig
    cmd = sprintf('7z e -y "%s" -o"%s"', src_file, entpack_pfad);
    system(cmd);
end

% Jetzt entpackte NIfTI-Dateien sammeln
nii_unpacked = dir(fullfile(entpack_pfad, '*.nii'));
input = cell(size(nii_unpacked));

for i = 1:length(nii_unpacked)
    input{i} = [fullfile(nii_unpacked(i).folder, nii_unpacked(i).name), ',1'];
end

% SPM Mittelwert-Batch
matlabbatch{1}.spm.util.imcalc.input = input;
matlabbatch{1}.spm.util.imcalc.output = 'mean_sub-SM2VP011_ses-T1';
matlabbatch{1}.spm.util.imcalc.outdir = {aggregiert_ordner};
matlabbatch{1}.spm.util.imcalc.expression = 'mean(X)';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 1;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);

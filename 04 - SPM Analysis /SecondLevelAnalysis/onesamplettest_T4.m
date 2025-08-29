% === Parameter definieren ===
base_dir = 'F:\FMRIPREPRESULTFINAL\';
second_level_dir = fullfile(base_dir, 'second_level', 'one_sample_ttest_T4');
contrast_file = 'con_0001.nii';  % Kontrast: Spider vs Bird

% === Nur Kontraste aus ses-T4 einsammeln ===
subs = dir(fullfile(base_dir, 'sub-*'));
subs = subs([subs.isdir]);

con_files = {};  % Container für Kontrastdateipfade

for i = 1:length(subs)
    sub_name = subs(i).name;
    ses_name = 'ses-T4';  % Nur diese Session
    fl_dir = fullfile(base_dir, sub_name, ses_name, 'FL_ALL_MASK');
    con_path = fullfile(fl_dir, contrast_file);
    
    if isfile(con_path)
        con_files{end+1,1} = [con_path ',1'];  % ,1 für SPM
    else
        fprintf('⚠️ Keine Kontrastdatei gefunden: %s\n', con_path);
    end
end

% === Sicherstellen, dass Kontraste vorhanden sind ===
if isempty(con_files)
    error('❌ Keine Kontrastdateien für ses-T4 gefunden. Abbruch.');
end

% === Zielordner erstellen ===
if ~exist(second_level_dir, 'dir')
    mkdir(second_level_dir);
end

% === SPM Batch: One-Sample T-Test ===
clear matlabbatch
matlabbatch{1}.spm.stats.factorial_design.dir = {second_level_dir};
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = con_files;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

% === Modellschätzung ===
matlabbatch{2}.spm.stats.fmri_est.spmmat = {fullfile(second_level_dir, 'SPM.mat')};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

% === Kontraste definieren ===
matlabbatch{3}.spm.stats.con.spmmat = {fullfile(second_level_dir, 'SPM.mat')};

matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Spider > Bird';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Bird > Spider';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = -1;
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.delete = 0;

% === Ausführen ===
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);

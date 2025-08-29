% === Parameter definieren ===
base_dir = 'F:\FMRIPREPRESULTFINAL\';
second_level_dir = fullfile(base_dir, 'second_level', 'one_sample_t_test');
contrast_file = 'con_0001.nii';  % Spider vs Bird

% === Alle Kontrastdateien automatisch sammeln ===
subs = dir(fullfile(base_dir, 'sub-*'));
subs = subs([subs.isdir]);

con_files = {};  % Container für Pfade

for i = 1:length(subs)
    sub_name = subs(i).name;
    ses_dirs = dir(fullfile(base_dir, sub_name, 'ses-*'));
    ses_dirs = ses_dirs([ses_dirs.isdir]);
    
    for j = 1:length(ses_dirs)
        ses_name = ses_dirs(j).name;
        fl_dir = fullfile(base_dir, sub_name, ses_name, 'FL_ALL_MASK');
        con_path = fullfile(fl_dir, contrast_file);
        
        if isfile(con_path)
            con_files{end+1,1} = [con_path ',1'];  % wichtig: ,1 für SPM
        else
            fprintf('⚠️ Kontrast fehlt: %s\n', con_path);
        end
    end
end

% === Prüfen, ob Kontraste gefunden wurden ===
if isempty(con_files)
    error('❌ Keine Kontrastdateien gefunden. Überprüfe den Pfad oder Dateinamen.');
end

% === Zielordner anlegen ===
if ~exist(second_level_dir, 'dir')
    mkdir(second_level_dir);
end

% === One-Sample T-Test Setup ===
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

% === Model Estimation ===
matlabbatch{2}.spm.stats.fmri_est.spmmat = {fullfile(second_level_dir, 'SPM.mat')};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

% === Kontraste (Spider > Bird und Bird > Spider) ===
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

% === Basisverzeichnis & Kontrastdatei ===
base_dir = 'F:\FMRIPREPRESULTFINAL\';
contrast_file = 'con_0001.nii';  % Spider vs Bird
second_level_dir = fullfile(base_dir, 'second_level', 't1_rTMS_vs_placebo');

% === Gruppen IDs (aus Tabelle) ===
rTMS_IDs = {'SM2_VP007','SM2_VP011','SM2_VP023','SM2_VP025','SM2_VP035','SM2_VP039','SM2_VP041','SM2_VP046','SM2_VP047','SM2_VP050','SM2_VP058'};
placebo_IDs = {'SM2_VP010','SM2_VP012','SM2_VP017','SM2_VP033','SM2_VP034','SM2_VP040','SM2_VP043','SM2_VP044','SM2_VP049','SM2_VP051','SM2_VP053'};

group1_files = {};
group2_files = {};

for i = 1:length(rTMS_IDs)
    id_clean = strrep(rTMS_IDs{i}, '_', '');  % z.B. SM2VP007
    sub_path = fullfile(base_dir, ['sub-' id_clean], 'ses-T1', 'FL_ALL_MASK', contrast_file);
    if isfile(sub_path)
        group1_files{end+1,1} = [sub_path ',1'];
    else
        warning('❌ Datei fehlt (rTMS): %s', sub_path);
    end
end

for i = 1:length(placebo_IDs)
    id_clean = strrep(placebo_IDs{i}, '_', '');
    sub_path = fullfile(base_dir, ['sub-' id_clean], 'ses-T1', 'FL_ALL_MASK', contrast_file);
    if isfile(sub_path)
        group2_files{end+1,1} = [sub_path ',1'];
    else
        warning('❌ Datei fehlt (Placebo): %s', sub_path);
    end
end

% === Abbruch wenn Gruppen leer ===
if isempty(group1_files) || isempty(group2_files)
    error('🚫 Keine Kontrastdaten für eine oder beide Gruppen gefunden.');
end

% === Zielordner erstellen ===
if ~exist(second_level_dir, 'dir')
    mkdir(second_level_dir);
end

% === SPM Batch für Two-Sample t-Test ===
clear matlabbatch
matlabbatch{1}.spm.stats.factorial_design.dir = {second_level_dir};
matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = group1_files;
matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = group2_files;
matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = 0;
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

% === Kontraste ===
matlabbatch{3}.spm.stats.con.spmmat = {fullfile(second_level_dir, 'SPM.mat')};

matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'rTMS > Placebo';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 -1];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Placebo > rTMS';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1 1];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.delete = 0;

% === Ausführen ===
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);

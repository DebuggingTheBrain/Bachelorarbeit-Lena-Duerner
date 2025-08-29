% === Verzeichnis, in dem dein SPM.mat liegt ===
second_level_dir = fullfile('F:\FMRIPREPRESULTFINAL\', 'second_level', 'mixed_ANOVA_rTMS_vs_placebo');
spm_mat_path = fullfile(second_level_dir, 'SPM.mat');

% === SPM Kontrast-Batch ===
clear matlabbatch
matlabbatch{1}.spm.stats.con.spmmat = {spm_mat_path};

% Interaktion: (rTMS T4 - T1) > (Placebo T4 - T1)
matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'Interaction: (rTMS T4-T1) > (Placebo T4-T1)';
matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [-1 1 1 -1];
matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

% Umgekehrte Interaktion (optional)
matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'Interaction: (Placebo T4-T1) > (rTMS T4-T1)';
matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [1 -1 -1 1];
matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

% === Kontraste nicht löschen ===
matlabbatch{1}.spm.stats.con.delete = 0;

% === Ausführen ===
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);

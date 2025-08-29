% === Basisinformationen ===
base_dir = 'F:\FMRIPREPRESULTFINAL\';
contrast_file = 'con_0001.nii';  % Spider vs Bird
second_level_dir = fullfile(base_dir, 'second_level', 'mixed_ANOVA_rTMS_vs_placebo');

rTMS_IDs = {'SM2_VP007','SM2_VP011','SM2_VP023','SM2_VP025','SM2_VP035','SM2_VP039','SM2_VP041','SM2_VP046','SM2_VP047','SM2_VP050','SM2_VP058'};
placebo_IDs = {'SM2_VP010','SM2_VP012','SM2_VP017','SM2_VP033','SM2_VP034','SM2_VP040','SM2_VP043','SM2_VP044','SM2_VP049','SM2_VP051','SM2_VP053'};

% === Zieldateiordner ===
if ~exist(second_level_dir, 'dir')
    mkdir(second_level_dir);
end

% === Scans in Zellen pro Bedingung sammeln ===
cells = cell(4,1);  % 1: rTMS T1, 2: rTMS T4, 3: Placebo T1, 4: Placebo T4

for i = 1:length(rTMS_IDs)
    id_clean = strrep(rTMS_IDs{i}, '_', '');

    % T1
    p1 = fullfile(base_dir, ['sub-' id_clean], 'ses-T1', 'FL_ALL_MASK', contrast_file);
    if isfile(p1)
        cells{1}{end+1,1} = [p1 ',1'];
    else
        warning('❌ Datei fehlt (rTMS T1): %s', p1);
    end

    % T4
    p2 = fullfile(base_dir, ['sub-' id_clean], 'ses-T4', 'FL_ALL_MASK', contrast_file);
    if isfile(p2)
        cells{2}{end+1,1} = [p2 ',1'];
    else
        warning('❌ Datei fehlt (rTMS T4): %s', p2);
    end
end

for i = 1:length(placebo_IDs)
    id_clean = strrep(placebo_IDs{i}, '_', '');

    % T1
    p1 = fullfile(base_dir, ['sub-' id_clean], 'ses-T1', 'FL_ALL_MASK', contrast_file);
    if isfile(p1)
        cells{3}{end+1,1} = [p1 ',1'];
    else
        warning('❌ Datei fehlt (Placebo T1): %s', p1);
    end

    % T4
    p2 = fullfile(base_dir, ['sub-' id_clean], 'ses-T4', 'FL_ALL_MASK', contrast_file);
    if isfile(p2)
        cells{4}{end+1,1} = [p2 ',1'];
    else
        warning('❌ Datei fehlt (Placebo T4): %s', p2);
    end
end

% === SPM Batch ===
clear matlabbatch
matlabbatch{1}.spm.stats.factorial_design.dir = {second_level_dir};

% === Faktoren definieren ===
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'Group';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = 2;  % rTMS, Placebo
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 0;    % between
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).ancova = 0;

matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).name = 'Time';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).levels = 2;  % T1, T4
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).dept = 1;    % within
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).ancova = 0;

% === Zellen definieren ===
for c = 1:4
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(c).levels = get_levels(c);
    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(c).scans = cells{c};
end

% === Keine Covariates ===
matlabbatch{1}.spm.stats.factorial_design.des.fd.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});

% === Masking & Global normalisation ===
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

% === Ausführen ===
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);


%% Hilfsfunktion: Faktor-Level pro Zelle
function levels = get_levels(cell_idx)
    switch cell_idx
        case 1
            levels = [1 1];  % rTMS, T1
        case 2
            levels = [1 2];  % rTMS, T4
        case 3
            levels = [2 1];  % Placebo, T1
        case 4
            levels = [2 2];  % Placebo, T4
    end
end

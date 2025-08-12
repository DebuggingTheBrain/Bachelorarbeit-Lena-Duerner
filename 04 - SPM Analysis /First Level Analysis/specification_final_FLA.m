% --- Parameter & Pfade wie bei dir oben ---
base_dir = 'F:\FMRIPREPRESULTFINAL\';
onset_base_dir = 'F:\LOG_MAT_FILES5\';
TR = 2.48;

subs = dir(fullfile(base_dir, 'sub-*')); subs = subs([subs.isdir]);
for s = 1:length(subs)
    sub_name = subs(s).name;           % z.B. 'sub-SM2VP009'
    ses_dir  = fullfile(base_dir, sub_name);
    ses      = dir(fullfile(ses_dir, 'ses-*')); ses = ses([ses.isdir]);

    for se = 1:length(ses)
        ses_name = ses(se).name;       % z.B. 'ses-T1'

        func_dir   = fullfile(base_dir, sub_name, ses_name, 'func');
        onset_dir  = fullfile(onset_base_dir, ['sub-', strrep(sub_name(5:end),'SM2VP','SM2_VP')], ses_name, 'func', 'onset_new');
        output_dir = fullfile(base_dir, sub_name, ses_name, 'FL_All');
        if ~exist(output_dir,'dir'); mkdir(output_dir); end

        % Preprocessed BOLD (achte auf dein Präfix/Regex)
        func_file = spm_select('ExtFPList', func_dir, ...
            ['^s6_sub-', sub_name(5:end), '_', ses_name, '_task-ep2dSpiderTask_dir-AP_space-MNI152NLin2009cAsym_desc-preproc_bold\.nii$'], Inf);
        if isempty(func_file)
            fprintf('Keine funktionellen Dateien für %s %s gefunden.\n', sub_name, ses_name);
            continue
        end
        nScans = size(func_file,1);   % Anzahl Volumes

        % Onsets (part1)
        onset_files = dir(fullfile(onset_dir, '*part1*.mat'));
        if isempty(onset_files)
            warning('Keine Onset-Dateien mit "part1" für %s %s\n', sub_name, ses_name);
            continue
        end
        onset_file = fullfile(onset_dir, onset_files(1).name);
        data = load(onset_file);
        if ~isfield(data,'names') || ~isfield(data,'onsets') || ~isfield(data,'durations')
            warning('Onset-Datei ohne names/onsets/durations: %s\n', onset_file); continue
        end
        if numel(data.names) ~= numel(data.onsets) || numel(data.names) ~= numel(data.durations)
            warning('Längenfehler in Onsets/Durations: %s\n', onset_file); continue
        end

        % Confounds TSV einlesen (n/a als fehlend)
        reg_file = fullfile(func_dir, sprintf('%s_%s_task-ep2dSpiderTask_dir-AP_desc-confounds_timeseries.tsv', sub_name, ses_name));
        if ~exist(reg_file,'file')
            warning('TSV confounds fehlt für %s %s\n', sub_name, ses_name); continue
        end

        opts = detectImportOptions(reg_file, 'FileType','text', 'Delimiter','\t', 'TreatAsEmpty',{'n/a','NA','NaN',''});
        % PreserveVariableNames, damit Spaltennamen exakt bleiben
        opts = setvaropts(opts, 'Type','double');   % versuche numerisch zu importieren
        tbl  = readtable(reg_file, opts);

        % Fallback: sicherstellen, dass zentrale Spalten numerisch sind
        needCols = {'trans_x','trans_y','trans_z','rot_x','rot_y','rot_z'};
        for k = 1:numel(needCols)
            if ismember(needCols{k}, tbl.Properties.VariableNames)
                col = tbl.(needCols{k});
                if iscell(col); col = str2double(col); end
                col = double(col);
                % auf Spaltenvektor trimmen
                tbl.(needCols{k}) = col(:);
            else
                warning('Spalte %s nicht gefunden – wird übersprungen.', needCols{k});
            end
        end

        % Längencheck
        if height(tbl) ~= nScans
            warning('Zeilen TSV (%d) != Anzahl Scans (%d) für %s %s', height(tbl), nScans, sub_name, ses_name);
            continue
        end

        % --- matlabbatch aufsetzen ---
        clear matlabbatch
        matlabbatch{1}.spm.stats.fmri_spec.dir = {output_dir};
        matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
        matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 37;
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 19;

        % WICHTIG: immer sess(1), nicht sess(counter)
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = cellstr(func_file);

        % Bedingungen
        for i = 1:numel(data.names)
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(i).name     = data.names{i};
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(i).onset    = data.onsets{i};
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(i).duration = data.durations{i};
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(i).tmod     = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(i).pmod     = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(i).orth     = 1;
        end

        matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi = {''};

        % Regressoren: 6 Motion-Parameter (falls vorhanden)
        regIdx = 0;
        addReg = @(nm) ...
            ( ismember(nm, tbl.Properties.VariableNames) && ~all(isnan(tbl.(nm))) );

        namesToAdd = {'trans_x','trans_y','trans_z','rot_x','rot_y','rot_z'};
        for k = 1:numel(namesToAdd)
            nm = namesToAdd{k};
            if addReg(nm)
                regIdx = regIdx + 1;
                v = tbl.(nm); v(isnan(v)) = 0;       % fehlende Werte -> 0 (oder andere Strategie)
                matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress(regIdx).name = nm;
                matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress(regIdx).val  = v(:);
            end
        end

        % Optional: einzelne motion_outlierXX Spalten hinzufügen (0/1 Dummys)
        olCols = startsWith(tbl.Properties.VariableNames, 'motion_outlier');
        olNames = tbl.Properties.VariableNames(olCols);
        for k = 1:numel(olNames)
            regIdx = regIdx + 1;
            v = tbl.(olNames{k});
            if iscell(v); v = str2double(v); end
            v = double(v); v(isnan(v)) = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress(regIdx).name = olNames{k};
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress(regIdx).val  = v(:);
        end

        % keine zusätzliche multi_reg Datei, da wir oben alles einzeln gesetzt haben
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = {''};
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf = 128;

        matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
        matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
        matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
        matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
        matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
        matlabbatch{1}.spm.stats.fmri_spec.mask = {''};   % keine Maske
        matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

        % Ausführen
        spm('defaults','FMRI');
        spm_jobman('run', matlabbatch);

        fprintf('SPM Modell-Spezifikation abgeschlossen für %s %s\n', sub_name, ses_name);
    end
end

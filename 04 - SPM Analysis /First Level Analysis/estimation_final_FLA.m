%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Skript zur FIRSTLEVEL Model Estimation in MATLAB
% Alle Sessions und Subjekte – passend zum Spezifikations-Skript (FL_All)
% Autorin: Lena Dürner (angepasst)
% Letzte Änderung: 12.08.2025 (Residualbilder aktiviert)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

base_dir = 'F:\FMRIPREPRESULTFINAL\';

% Alle Subjekt-Ordner (sub-*)
subs = dir(fullfile(base_dir, 'sub-*')); 
subs = subs([subs.isdir]);

for s = 1:numel(subs)
    sub_name = subs(s).name;                            % z.B. 'sub-SM2VP009'
    ses_dir  = fullfile(base_dir, sub_name);
    ses      = dir(fullfile(ses_dir, 'ses-*')); 
    ses      = ses([ses.isdir]);

    for se = 1:numel(ses)
        ses_name = ses(se).name;                        % z.B. 'ses-T1'

        % Pfad zur SPM.mat im gleichen Output-Ordner wie im Spezifikationsskript
        fl_dir   = fullfile(base_dir, sub_name, ses_name, 'FL_All');
        spm_path = fullfile(fl_dir, 'SPM.mat');

        if ~isfile(spm_path)
            warning('⚠️  SPM.mat nicht gefunden: %s – wird übersprungen.', spm_path);
            continue
        end

        % Estimation-Batch (mit Residualbildern)
        clear matlabbatch
        matlabbatch{1}.spm.stats.fmri_est.spmmat = {spm_path};
        matlabbatch{1}.spm.stats.fmri_est.write_residuals = 1;  % Residuals speichern
        matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

        % SPM starten & ausführen
        try
            spm('defaults', 'FMRI');
            spm_jobman('run', matlabbatch);
            fprintf('✅ Estimation abgeschlossen (mit Residuals): %s | %s\n', sub_name, ses_name);
        catch ME
            warning('❌ Fehler bei %s | %s: %s', sub_name, ses_name, ME.message);
        end
    end
end

% =============================================================================
% ENDE DES SKRIPTS
% =============================================================================

% =========================================================================
% Titel:    SPM First-Level Model Estimation (mit Residualbildern)
% Autor:    Lena Dürner
% Datum:    2025-09-01
%
% Beschreibung:
%   Führt die Parameterschätzung für alle Subjekte (sub-*)
%   und Sessions (ses-*) durch – passend zum zuvor erzeugten Design in
%   `FL_All`. Residualbilder werden mitgeschrieben
%   (`write_residuals = 1`).
%
% Abhängigkeiten:
%   - MATLAB R2022b (oder neuer)
%   - SPM12 (spm_jobman)
%
% Input:
%   - base_dir/sub-*/ses-*/FL_All/SPM.mat  (aus dem Spezifikations-Skript)
%
% Output:
%   - base_dir/sub-*/ses-*/FL_All/
%       * beta_*.nii, ResMS.nii, RPV.nii, mask.nii, SPM.mat (aktualisiert)
%       * ResI_*.nii  (Residualbilder, aktiviert)
%
% Verwendung:
%   - Pfad `base_dir` prüfen/anpassen
%   - Skript in MATLAB ausführen
% =========================================================================



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
            warning('  SPM.mat nicht gefunden: %s – wird übersprungen.', spm_path);
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
            fprintf(' Estimation abgeschlossen (mit Residuals): %s | %s\n', sub_name, ses_name);
        catch ME
            warning(' Fehler bei %s | %s: %s', sub_name, ses_name, ME.message);
        end
    end
end

% =============================================================================
% ENDE DES SKRIPTS
% =============================================================================



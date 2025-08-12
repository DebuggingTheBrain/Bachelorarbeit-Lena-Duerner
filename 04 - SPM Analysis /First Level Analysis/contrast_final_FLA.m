%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Robustes Skript zur Erstellung der Kontraste (Spider vs Bird) für FIRSTLEVELANALYSIS
% - Sicherheitschecks (Vektorlänge vs. Design)
% - Regressor-Namen werden geloggt
% - Kontraste per Namen ("spider" vs "bird") statt fester Indizes (robuster ggü. Spaltenverschiebungen)
% - Sessrep bleibt 'none' (ein SPM.mat pro Session)
%
% Autorin: Lena Dürner (angepasst)
% Letzte Änderung: 12.08.2025
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

baseDir = 'F:\FMRIPREPRESULT\';

% Alle Subjekt-Ordner finden (sub-*)
subjFolders = dir(fullfile(baseDir, 'sub-*'));
subjFolders = subjFolders([subjFolders.isdir]);  % Nur Ordner behalten

for iSub = 1:numel(subjFolders)
    subjName = subjFolders(iSub).name;  % z.B. 'sub-SM2VP007'
    subjPath = fullfile(baseDir, subjName);

    % Alle Session-Ordner finden (ses-*)
    sessFolders = dir(fullfile(subjPath, 'ses-*'));
    sessFolders = sessFolders([sessFolders.isdir]);  % Nur Ordner behalten

    for iSess = 1:numel(sessFolders)
        sessName = sessFolders(iSess).name;  % z.B. 'ses-T1'
        sessPath = fullfile(subjPath, sessName);

        % Pfad zur SPM.mat Datei im Ordner FL_All
        est_file = fullfile(sessPath, 'FL_All', 'SPM.mat');

        if exist(est_file, 'file')
            fprintf('Verarbeite: %s\n', est_file);

            %--------------------------------------------------------------
            % 1) SPM laden, Spaltenzahl & Namen ermitteln
            %--------------------------------------------------------------
            S = load(est_file, 'SPM');
            if ~isfield(S,'SPM')
                warning('SPM-Struktur nicht gefunden in %s. Überspringe...', est_file);
                continue;
            end
            if ~isfield(S.SPM,'xX') || ~isfield(S.SPM.xX,'X') || isempty(S.SPM.xX.X)
                warning('Designmatrix fehlt/leer in %s. Überspringe...', est_file);
                continue;
            end

            X = S.SPM.xX.X;
            ncols = size(X,2);

            % Namen der Regressoren sammeln
            if isfield(S.SPM.xX,'name') && ~isempty(S.SPM.xX.name)
                regNames = S.SPM.xX.name(:);
            else
                regNames = arrayfun(@(k) sprintf('Regressor_%02d',k), 1:ncols, 'UniformOutput', false)';
            end

            %--------------------------------------------------------------
            % 2) Regressor-Namen loggen
            %--------------------------------------------------------------
            try
                logFile = fullfile(sessPath, 'FL_All', 'regressor_names.txt');
                fid = fopen(logFile,'w');
                fprintf(fid, 'Regressornamen für %s\n', est_file);
                for k = 1:numel(regNames)
                    rn = regNames{k};
                    if iscell(rn), rn = rn{1}; end
                    fprintf(fid, '%3d: %s\n', k, rn);
                end
                fclose(fid);
            catch ME
                warning('Konnte Log-Datei nicht schreiben (%s): %s', logFile, ME.message);
            end

            %--------------------------------------------------------------
            % 3) Indizes für "spider" und "bird" per Namen finden
            %    - case-insensitive Suche
            %    - fasst ggf. mehrere BF-Spalten pro Bedingung zusammen
            %--------------------------------------------------------------
            spider_idx = [];
            bird_idx   = [];

            for k = 1:numel(regNames)
                rn = regNames{k};
                if iscell(rn), rn = rn{1}; end
                rn_lc = lower(rn);

                % Motion/Constante aussortieren (heuristisch)
                if contains(rn_lc,'rp(') || contains(rn_lc,'motion') || contains(rn_lc,'mp_') || contains(rn_lc,'realign')
                    continue; % Bewegungs-Parameter
                end
                if contains(rn_lc,'constant') || strcmp(strtrim(rn_lc),'constant')
                    continue; % Konstante Spalte
                end

                if contains(rn_lc,'spider')
                    spider_idx(end+1) = k; %#ok<AGROW>
                elseif contains(rn_lc,'bird')
                    bird_idx(end+1) = k; %#ok<AGROW>
                end
            end

            if isempty(spider_idx) || isempty(bird_idx)
                warning('Konnte "spider" (%d gefunden) oder "bird" (%d gefunden) nicht eindeutig identifizieren in %s. Überspringe...', ...
                    numel(spider_idx), numel(bird_idx), est_file);
                continue;
            end

            %--------------------------------------------------------------
            % 4) Kontrastvektoren konstruieren (Spider > Bird und Bird > Spider)
            %--------------------------------------------------------------
            w_spider_gt_bird = zeros(1, ncols);
            w_bird_gt_spider = zeros(1, ncols);
            w_spider_gt_bird(spider_idx) =  1/numel(spider_idx); % gleiches Gewicht pro BF
            w_spider_gt_bird(bird_idx)   = -1/numel(bird_idx);
            w_bird_gt_spider = -w_spider_gt_bird;

            %--------------------------------------------------------------
            % 5) Sicherheitsgurt: Vektorlänge prüfen (sollte immer passen)
            %--------------------------------------------------------------
            assert(numel(w_spider_gt_bird) == ncols, ...
                'Kontrastlänge (%d) ≠ Designspalten (%d) in %s', numel(w_spider_gt_bird), ncols, est_file);

            %--------------------------------------------------------------
            % 6) Batch definieren (nur die zwei gewünschten Kontraste)
            %--------------------------------------------------------------
            clear matlabbatch
            matlabbatch{1}.spm.stats.con.spmmat = {est_file};

            matlabbatch{1}.spm.stats.con.consess{1}.tcon.name    = 'Spider_vs_Bird';
            matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = w_spider_gt_bird;
            matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

            matlabbatch{1}.spm.stats.con.consess{2}.tcon.name    = 'Bird_vs_Spider';
            matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = w_bird_gt_spider;
            matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

            % Kontraste NICHT löschen (alte behalten)
            matlabbatch{1}.spm.stats.con.delete = 0;

            % Optional: Batch abspeichern
            try
                save(fullfile(sessPath, 'contrast_batch_spider_bird.mat'), 'matlabbatch');
            catch ME
                warning('Konnte contrast_batch nicht speichern: %s', ME.message);
            end

            %--------------------------------------------------------------
            % 7) Kontraste ausführen
            %--------------------------------------------------------------
            try
                spm_jobman('run', matlabbatch);
            catch ME
                warning('Fehler beim Ausführen von spm_jobman für %s: %s', est_file, ME.message);
            end

        else
            warning('SPM.mat nicht gefunden: %s', est_file);
        end
    end
end

% ========================================================================
% ENDE DES SKRIPTS
% ========================================================================

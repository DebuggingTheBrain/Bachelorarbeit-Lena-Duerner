"""
Titel: Umwandlung von Onset-Files für SPM  
Autor: Lena Dürner  
Datum: 2025-09-01  

Beschreibung:  
Dieses Skript verarbeitet Logfiles aus fMRT-Experimenten und wandelt sie in Onset-Dateien für SPM um.  
Es berücksichtigt die Ereignistypen *spider*, *bird*, *fixation* und *instruction*.  
Die Onsets werden automatisch für jedes Subjekt und jede Session extrahiert und in .mat-Dateien gespeichert.  

Abhängigkeiten:  
    - MATLAB R2022b (oder neuer)  

Input:  
    - Logfiles im Format: `ses-*_subject_trial.txt` (enthält Events und Zeitstempel)  

Output:  
    - `<sub>/<ses>/func/onset_new/*_onsets_durations_names.mat` (MATLAB-Dateien mit Onsets, Durations, Names)  

Verwendung:  
    - Pfade zu `input_root` und `output_root` im Skript anpassen  
    - Skript in MATLAB ausführen  
"""



clear;

% --- Eingabe- und Ausgabe-Pfade ---
input_root = 'F:\LOG_FILES';
output_root = 'F:\LOG_MAT_FILES5';

% --- fMRI-Parameter ---
tr = 2.48; % Repetition Time in Sekunden
deleted_scans = 5; % Anzahl der gelöschten Volumes (angepasst)

% --- Alle sub-Ordner (sub-*) durchsuchen ---
sub_dirs = dir(fullfile(input_root, 'sub-*'));

for i = 1:length(sub_dirs)
    sub_dir = strtrim(sub_dirs(i).name);  % Leerzeichen entfernen
    ses_dirs = dir(fullfile(input_root, sub_dir, 'ses-*'));

    for j = 1:length(ses_dirs)
        ses_dir = strtrim(ses_dirs(j).name);  % Leerzeichen entfernen
        ses_path = fullfile(input_root, sub_dir, ses_dir);

        % --- Nur relevante Logfiles laden ---
        log_files = dir(fullfile(ses_path, 'ses-*_subject_trial.txt'));
        if isempty(log_files)
            warning('Keine passende subject_trial.txt-Datei in %s gefunden.', ses_path);
            continue;
        end

        % --- Ausgabeordner vorbereiten ---
        out_dir = fullfile(output_root, sub_dir, ses_dir, 'func', 'onset_new');
        out_dir = strtrim(out_dir);  % sicherstellen, dass keine Leerzeichen enthalten sind

        % --- Debug-Ausgabe zur Ordnerstruktur ---
        fprintf('[DEBUG] Geplanter Ausgabeordner: %s\n', out_dir);
        if exist(out_dir, 'dir')
            disp('[DEBUG] Ordner existiert bereits.');
        else
            disp('[DEBUG] Ordner wird erstellt...');
            mkdir(out_dir);
        end

        % --- Jede Logfile einzeln verarbeiten ---
        for k = 1:length(log_files)
            file_name = log_files(k).name;
            name_infile = fullfile(ses_path, file_name);

            % --- Datei einlesen ---
            fid = fopen(name_infile, 'r');
            zeilen = textscan(fid, '%s', 'Delimiter', '\n', 'Whitespace', '');
            fclose(fid);
            zeilen = zeilen{1};

            % --- Initialisierung der Variablen ---
            onsets_bird = []; durations_bird = [];
            onsets_spider = []; durations_spider = [];
            onsets_fixation = []; durations_fixation = [];
            onsets_instr = []; durations_instr = [];

            % --- Beginnzeit anhand des ersten "Pulse 66" bestimmen ---
            pulseIdx = find(contains(zeilen, 'Pulse') & contains(zeilen, '66'));
            if isempty(pulseIdx)
                warning('Keine "Pulse 66"-Zeile in Datei %s gefunden.', file_name);
                continue;
            else
                first_pulse_line = strsplit(zeilen{pulseIdx(1)}, '\t');
                beginning_time = str2double(first_pulse_line{5}); % Zeit in 1/10 ms

                % --- Alle "Picture"-Events identifizieren ---
                pictureIdx = find(contains(zeilen, 'Picture'));

                for idx = pictureIdx'
                    parts = strsplit(zeilen{idx}, '\t');
                    if length(parts) < 8
                        continue; % überspringe unvollständige Zeilen
                    end

                    stimName = strtrim(parts{4});
                    time_ms = str2double(parts{5}); % in 1/10 ms
                    dur_ms = str2double(parts{8});  % in 1/10 ms

                    if isnan(time_ms) || isnan(dur_ms)
                        continue;
                    end

                    % --- Berechnung relativer Stimuluszeit mit Anpassung für gelöschte Volumes ---
                    act_time = ((time_ms - beginning_time) / 10000) - deleted_scans * tr; % in Sekunden
                    dur_time = dur_ms / 10000; % in Sekunden

                    % --- Einordnung nach Stimulus-Typ ---
                    if startsWith(stimName, 'spiderpic')
                        onsets_spider = [onsets_spider, act_time];
                        durations_spider = [durations_spider, dur_time];
                    elseif startsWith(stimName, 'birdpic')
                        onsets_bird = [onsets_bird, act_time];
                        durations_bird = [durations_bird, dur_time];
                    elseif strcmpi(stimName, 'fixation')
                        onsets_fixation = [onsets_fixation, act_time];
                        durations_fixation = [durations_fixation, dur_time];
                    elseif startsWith(stimName, 'instr')
                        onsets_instr = [onsets_instr, act_time];
                        durations_instr = [durations_instr, dur_time];
                    end
                end

                % --- Ergebnisse strukturieren und speichern ---
                onsets = {onsets_bird, onsets_spider, onsets_fixation, onsets_instr};
                durations = {durations_bird, durations_spider, durations_fixation, durations_instr};
                names = {'bird', 'spider', 'fixation', 'instr'};

                [~, fname, ~] = fileparts(file_name);
                save_filename = sprintf('%s_onsets_durations_names.mat', fname);
                save_path = fullfile(out_dir, save_filename);
                save(save_path, 'onsets', 'durations', 'names');

                fprintf('Verarbeitet und gespeichert: %s\n', save_path);
            end
        end
    end
end

disp('Fertig: Onsets und Durations für birdpic, spiderpic, fixation und instr extrahiert.');


% ========================================================================
% ENDE DES SKRIPTS
% ======================================================================== 


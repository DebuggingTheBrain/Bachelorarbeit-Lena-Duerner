% Skript für die Umrechnung der Mesh Simulationsdateien in MNI Nifti Dateien.
% Achtung! Für die anschließende Weiterverarbeitung in SPM müssen die Ergebnisse
% ggf. noch mit 7-Zip extrahiert werden.
% Kilian Rolle 02.04.2022 | angepasst: automatische Ordnererstellung & eindeutige Namen

user = "sub-SM2VP010_ses-T1";

% alle .msh-Dateien des Probanden
files = dir('G:\tutorial_output\sub-SM2VP010_ses-T1\*.msh');

% Basis-Ausgabeordner anlegen
out_user = fullfile('G:\MNI_Output', user);
if ~exist(out_user, 'dir')
    mkdir(out_user);
end

for Liste = 1:numel(files)
    Pfad_Input  = files(Liste).folder;
    Datei_Input = files(Liste).name;
    stimnum     = int2str(Liste);

    % Basisname für Output (z. B. G:\MNI_Output\sub-...\1)
    out_base = fullfile(out_user, stimnum);

    % subject2mni-Befehl
    String1 = append('subject2mni --in "', Pfad_Input, '\', Datei_Input, '" ', ...
        '--m2mpath "', 'H:\headmodels\', user, '\m2m_', user, '" ', ...
        '-o "', out_base, '" --labels 1,2');

    % Aufruf
    status = system(String1);
    if status ~= 0
        warning('subject2mni fehlgeschlagen für %s (Stim %s).', Datei_Input, stimnum);
    end
end

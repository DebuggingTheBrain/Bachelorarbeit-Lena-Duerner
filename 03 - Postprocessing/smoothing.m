"""
Titel: Automatisches Smoothing von fMRIPrep-BOLD-Daten  
Autor: Lena Dürner  
Datum: 2025-09-01  

Beschreibung:  
Dieses Skript durchsucht fMRIPrep-Ergebnisse für jede(n) Proband*in (sub-*) und Session (ses-*).  
Es identifiziert die vorverarbeiteten BOLD-Dateien mit der exakten Namenskonvention  
`*_task-ep2dSpiderTask_dir-AP_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz`,  
entpackt sie falls nötig und führt ein räumliches Smoothing mit einem FWHM von 6 mm in SPM durch.  
Die gesmoothte Datei erhält das Präfix `s6_`.  

Abhängigkeiten:  
    - MATLAB R2022b (oder neuer)  
    - SPM12 (für `spm_jobman`)  

Input:  
    - fMRIPrep-Ausgabeverzeichnis mit Struktur:  
      `<basePath>/sub-*/ses-*/func/*_desc-preproc_bold.nii.gz`  

Output:  
    - Gesmoothte Dateien im jeweiligen `func`-Ordner mit Präfix `s6_`  

Verwendung:  
    - Pfad `basePath` im Skript anpassen  
    - Skript in MATLAB ausführen  
"""



% Basis-Pfad anpassen
basePath = 'F:\FMRIPREPRESULTFINAL';

% Hole alle sub-Ordner
subFolders = dir(fullfile(basePath, 'sub-*'));
subFolders = subFolders([subFolders.isdir]);

parfor iSub = 1:length(subFolders)
    subName = subFolders(iSub).name; % z.B. sub-SM2VP025
    subPath = fullfile(basePath, subName);
    
    % Hole alle ses-Ordner im jeweiligen sub-Ordner
    sesFolders = dir(fullfile(subPath, 'ses-*'));
    sesFolders = sesFolders([sesFolders.isdir]);
    
    for iSes = 1:length(sesFolders)
        sesName = sesFolders(iSes).name; % z.B. ses-T1
        sesPath = fullfile(subPath, sesName);
        
        % Pfad zum func-Ordner
        funcPath = fullfile(sesPath, 'func');
        
        % Falls func-Ordner nicht existiert, skip
        if ~isfolder(funcPath)
            continue;
        end
        
        % Exaktes Suchmuster
        pattern = [subName '_' sesName '_task-ep2dSpiderTask_dir-AP_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'];
        
        % Suche nach Datei mit genau diesem Namen
        files = dir(fullfile(funcPath, pattern));
        
        if isempty(files)
            fprintf('Keine passende Datei in %s gefunden.\n', funcPath);
            continue;
        end
        
        for f = 1:length(files)
            gzFile = fullfile(funcPath, files(f).name);
            niiFile = gzFile(1:end-3); % .nii.gz zu .nii
            
            % Entpacken falls nötig
            if ~exist(niiFile, 'file')
                gunzip(gzFile);
                fprintf('Entpacke %s\n', gzFile);
            end
            
            % Smoothing (ganze 4D-Datei angeben)
            scans = {niiFile};
            smoothing(scans);
            
            fprintf('Gesmoothte Datei: %s\n', niiFile);
        end
    end
end

function smoothing(scans)
    matlabbatch{1}.spm.spatial.smooth.data = scans;
    matlabbatch{1}.spm.spatial.smooth.fwhm = [6 6 6];
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = 's6_';
    
    spm_jobman('run', matlabbatch);
    clear matlabbatch
end


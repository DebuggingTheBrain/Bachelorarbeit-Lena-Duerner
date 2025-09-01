# fMRI Preprocessing & QC Pipeline

Dieses Repository enthält Skripte zur **Vorverarbeitung** und **Qualitätskontrolle (QC)** von fMRI-Daten, die mit [fMRIPrep](https://fmriprep.org/en/stable/) erstellt wurden.

---

## 📂 Inhalte

### Onset & Preprocessing
- **`Trennung der Onset Dateien.py`** → Trennt `.log`-Dateien in Trial- und Eventtype-Abschnitte.  
- **`responseanalysis onset files.py`** → Bewertet Blöcke (Spider/Bird) als gültig/ungültig.  
- **`umwandlung der onset dateien.m`** → Erstellt SPM-kompatible Onset-Files (.mat).  
- **`smoothing.m`** → Führt räumliches Smoothing mit SPM durch.  

### Qualitätskontrolle [MRIQC](https://mriqc.readthedocs.io/en/latest/)
- **`Berechnung der FD.py`** → Framewise Displacement (FD); FAIL bei zu starker Bewegung.  
- **`Berechnung des DVARS.py`** → DVARS-Metriken; FAIL bei Spikes/Varianz.  
- **`mriqc.sh`** → Startet [MRIQC](https://mriqc.readthedocs.io/) (Docker) für Einzel- & Gruppen-Reports.  

---

## ⚙️ Abhängigkeiten
- **Python** 3.10, `pandas >= 2.0`, `numpy >= 1.24`  
- **MATLAB** R2022b+, [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/)  
- **Bash/Docker** mit MRIQC-Images (`nipreps/mriqc:24.0.2`, `21.0.0rc2`)  

---

## 🚀 Workflow

```text
Logfiles (.log)
    │
    ├── Trennung der Onset Dateien.py
    │       └── *_part1_subject_trial.txt
    │       └── *_part2_eventtype.txt
    │
    ├── responseanalysis onset files.py
    │       └── valid_blocks_log.txt
    │
    └── umwandlung der onset dateien.m
            └── *_onsets_durations_names.mat  (für SPM)
            
fMRIPrep-Outputs (BOLD)
    │
    └── smoothing.m
            └── s6_*_bold.nii (gesmootht)
            
QC-Checks
    ├── Berechnung der FD.py → FD_QC_Summary.csv
    ├── Berechnung des DVARS.py → dvars_with_fail_flag.csv
    └── mriqc.sh → derivatives/mriqc/ (Reports)

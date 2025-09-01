# 🧪 Neuroimaging Processing & Analyse – Skripte

Autor: Lena Dürner  
Datum: 2025-09-01  

Dieses Repository enthält eine Sammlung von Bash- und Python-Skripten zur Verarbeitung und Analyse von fMRT- und Verhaltensdaten.  
Die Skripte sind modular aufgebaut und decken verschiedene Schritte von der Rohdatenvorbereitung bis zur Auswertung ab.  

---

## 📂 Übersicht der Skripte

### 1. **run_fmriprep_batch.sh**
- **Zweck:** Batch-Verarbeitung von BIDS-Daten mit *fMRIPrep* im Docker-Container.  
- **Input:** BIDS-Verzeichnis (`/mnt/f/RESULTVER2`), FreeSurfer Lizenzdatei  
- **Output:** fMRIPrep-Ergebnisse (`/mnt/f/FMRIPREPRESULTFINAL`)  
- **Start:**  
  ```bash
  bash run_fmriprep_batch.sh
  ```

---

### 2. **remove_dummy_scans.sh**
- **Zweck:** Entfernen der ersten 5 Dummy-Scans aus allen funktionellen NIfTI-Dateien.  
- **Input:** BIDS-Verzeichnis mit funktionellen NIfTI-Dateien  
- **Output:** Geänderte NIfTI-Dateien (Original wird überschrieben), Logdatei `dummy_removal_log.txt`  
- **Start:**  
  ```bash
  bash remove_dummy_scans.sh
  ```

---

### 3. **analyze_valid_blocks.py**
- **Zweck:** Analyse von Verhaltens-Logfiles (`part2_eventtype.txt`) zur Bestimmung gültiger und ungültiger Blöcke (Spider vs. Bird).  
- **Input:** Logfiles im Ordner `F:\LOG_FILES`  
- **Output:** Textdatei `valid_blocks_log.txt`  
- **Start:**  
  ```bash
  python analyze_valid_blocks.py
  ```

---

## ⚙️ Abhängigkeiten

### Allgemein
- [Docker](https://www.docker.com/) (für fMRIPrep)
- [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki) (für Dummy-Scan-Entfernung)

### Python
- Python 3.10
- `pandas >= 2.0`

---

## 📑 Hinweise
- **Pfadangaben:** Einige Skripte nutzen absolute Pfade (z. B. `/mnt/f/...` oder `F:\...`). Diese müssen ggf. an das eigene System angepasst werden.  
- **Datenstruktur:** Die Skripte setzen die BIDS-Standardstruktur für fMRI-Daten voraus.  
- **FreeSurfer Lizenz:** Für fMRIPrep ist eine gültige `license.txt` erforderlich.  

---
  
Für das Preprocessing der MRT-Daten wird in der Arbeit die Preprocessing Pipeline [fMRIPrep](https://fmriprep.org/en/stable/).  verwendet.


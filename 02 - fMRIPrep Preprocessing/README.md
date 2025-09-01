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

  
Für das Preprocessing der MRT-Daten wird in der Arbeit die Preprocessing Pipeline [fMRIPrep](https://fmriprep.org/en/stable/).  verwendet.


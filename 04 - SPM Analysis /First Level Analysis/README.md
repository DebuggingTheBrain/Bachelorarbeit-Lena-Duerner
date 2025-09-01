
# 📊 SPM First-Level Pipeline – Übersicht

Diese drei Skripte bilden gemeinsam die First-Level fMRI-Auswertung mit SPM12 für jede(n) Proband*in und jede Session.

---

## 1. 🧩 `SPM_FirstLevel_Specification.m`
Erstellt das **Design** für jede Session:

- Lädt gesmoothete BOLD-Dateien (`s6_*.nii`)
- Verwendet Onsets/Durations aus `.mat`-Dateien (`part1`)
- Integriert Motion-Regressoren und motion_outlier-Dummys aus fMRIPrep `.tsv`
- Speichert alles im Ordner `FL_All/`

**Output:**  
- `FL_All/SPM.mat`, `SPM.xX`, `SPM.xY`, etc.

---

## 2. 🧮 `SPM_FirstLevel_Estimation.m`
Führt die **Modellschätzung** durch:

- Lädt `SPM.mat` aus `FL_All/`
- Schätzt die Parameter
- Speichert zusätzlich **Residualbilder**

**Output:**  
- `beta_*.nii`, `ResMS.nii`, `ResI_*.nii`, etc.

---

## 3. 🧠 `SPM_FirstLevel_Contrasts.m`
Erstellt robuste **Kontraste** für:

- `Spider_vs_Bird`  
- `Bird_vs_Spider`

Per Namenssuche statt fester Spaltenindizes  
(Regressoren werden geloggt und Bewegungs-/Konstantenregressoren ignoriert)

**Output:**  
- `con_*.nii`, `spmT_*.nii`, `regressor_names.txt`

---

## 🔧 Voraussetzungen
- MATLAB R2022b+  
- SPM12 installiert und im Pfad  
- Struktur: `sub-*/ses-*/func/` + `FL_All/` mit SPM.mat

---

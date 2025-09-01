# 🧠 TFCE-Analysen (SPM Toolbox)

Diese Sammlung enthält Skripte zur Durchführung und Auswertung von **TFCE-basierten Korrekturen** in SPM12. Sie eignen sich für Second-Level-Analysen wie t-Tests oder gemischte ANOVAs und können sowohl **whole-brain** als auch **ROI-basiert** durchgeführt werden.

---

## 📄 Skripte

### `tfce_rTMS_vs_placebo.m`
Führt eine **TFCE-Korrektur** für ein gemischtes ANOVA-Modell durch (z. B. rTMS vs Placebo). Unterstützt mehrere Kontraste gleichzeitig sowie optional eine zusätzliche Maskierung.

**Input:**  
- `SPM.mat` aus Second-Level  
- Optional: ROI-Maske (`.nii`)  
**Output:**  
- TFCE-korrigierte Maps pro Kontrast (`*_TFCE_corrp.nii`)

---

### `tfce_roi_loop.m`
Führt die TFCE-Analyse **ROI-basiert** durch: Für jede Maske in einer Liste wird eine TFCE-Korrektur separat durchgeführt. Besonders nützlich für Hypothesentests in vorab definierten Regionen.

**Input:**  
- Liste an `.nii`-ROIs  
- `SPM.mat` mit Kontrasten  
**Output:**  
- TFCE-Ergebnisse pro ROI

---

### `analyze_tfce_clusters.m`
Analysiert ein vorhandenes TFCE-Ergebnisbild (z. B. `TFCE_corrp.nii`) und extrahiert:

- Clustergröße  
- Peak-Koordinaten (MNI)  
- (log-)p-Werte  

**Output:**  
- CSV-Datei mit allen Peaks & Clustern

---

## ⚙️ Voraussetzungen
- **MATLAB R2022b** (oder neuer)  
- **SPM12** installiert  
- **TFCE Toolbox für SPM** (z. B. via `spm.tools.tfce_estimate`)  

---

Zur Korrektur der whole brain analysis wird die Toolbox [TFCE](https://github.com/ChristianGaser/tfce) verwendet. 
Durch die relevanz besonders kleiner ROIs wie beispielsweise des Amygdala, führt eine Korrektur mittels Threshold-Free Cluster Enhancement  
wodurch sowohl lokale als auch großflächige Effekte ohne willkürliche Cluster-Schwellen erfasst werden können.

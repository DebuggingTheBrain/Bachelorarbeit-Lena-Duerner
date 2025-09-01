# 🧪 Neuroimaging Processing & Analyse – Skripte

Autor: Lena Dürner  
Datum: 2025-09-01  

Dieses Repository enthält eine Sammlung von Bash- und Python-Skripten zur Verarbeitung und Analyse von fMRT- und Verhaltensdaten.  
Die Skripte sind modular aufgebaut und decken verschiedene Schritte von der Rohdatenvorbereitung bis zur statistischen Auswertung ab.  

---

## 📂 Übersicht der Skripte

### 1. **normalize_rnaseq.py**
- **Zweck:** Normalisierung von RNA-Seq Rohdaten mittels DESeq2-Methodik (über `rpy2`).
- **Input:** `data/raw_counts.csv`  
- **Output:** `results/normalized_counts.csv`  
- **Start:**  
  ```bash
  python normalize_rnaseq.py data/raw_counts.csv results/normalized_counts.csv
  ```


Für das Preprocessing der MRT-Daten wird in der Arbeit die Preprocessing Pipeline [fMRIPrep](https://fmriprep.org/en/stable/).  verwendet.


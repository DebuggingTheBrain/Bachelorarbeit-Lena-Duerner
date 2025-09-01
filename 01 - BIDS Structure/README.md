## BIDS Struktur
Autor: **Lena Dürner**  
Datum: **2025-09-01**

---

## 📖 Übersicht
Dieser Ordner enthält eine Sammlung von Python-Skripten zur **Datenvorbereitung und Umwandlung in die BIDS Struktur**.
Die Skripte dienen dazu, Rohdaten konsistent zu strukturieren, Dateien zu normalisieren und für nachgelagerte Analysen vorzubereiten.

---

## ⚙️ Voraussetzungen

- **Python 3.10**  
- Installierte Bibliotheken:
  - `pandas >= 2.0`
  - `numpy >= 1.24`
  - `rpy2` (falls DESeq2-Normalisierung verwendet wird)
  - `os` (Standardbibliothek)
  - `shutil` (Standardbibliothek)
  - `re` (Standardbibliothek)

Installation (falls benötigt):
```bash
pip install pandas numpy rpy2


Zur Vereinheitlichung der Datenstruktur wird die **BIDS-Struktur** verwendet.  
Zur automatisierten Umwandlung wurde hierfür  [BIDScoin](https://github.com/Donders-Institute/bidscoin) verwendet,  
um die Daten in die richtige Struktur für das Preprocessing mit **fMRIPrep** zu bringen.

Zur Vorbereitung auf die Verarbeitung mit **BIDScoin** wurden die Daten noch mit diversen Python Skripten umbenannt und umstrukturiert, um für eine besssere Übersichtlichkeit zu sorgen. 

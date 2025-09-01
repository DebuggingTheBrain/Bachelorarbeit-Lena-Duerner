"""
Titel: Framewise Displacement (FD) Qualitätskontrolle für fMRIPrep-Daten  
Autor: Lena Dürner  
Datum: 2025-09-01  

Beschreibung:  
Dieses Skript überprüft Bewegungsartefakte in fMRIPrep-Ausgaben anhand der Spalte  
`framewise_displacement` in den Confounds-Dateien.  
Es berechnet:  
- Mittlere Framewise Displacement (mean_FD)  
- Anzahl von Volumes mit FD > 0.5 mm  
- Prozentsatz von Volumes mit FD > 0.5 mm  

Ein Run wird als **FAIL** markiert, wenn:  
- `mean_FD > 0.2 mm` oder  
- mehr als 20 % der Volumes `FD > 0.5 mm` aufweisen.  

Abhängigkeiten:  
    - Python 3.10  
    - pandas >= 2.0  

Input:  
    - `<base_dir>/sub-*/ses-*/func/*desc-confounds_timeseries.tsv`  

Output:  
    - `FD_QC_Summary.csv` (Tabelle mit QC-Metriken und FAIL-Flag)  

"""



import pandas as pd
import glob
import os

# Schwellenwerte
mean_fd_threshold = 0.2
high_fd_threshold = 0.5
high_fd_percentage_threshold = 0.2

# Pfad zu deinen Daten (Windows-Backslashes beachten oder roher String)
base_dir = r"F:\FMRIPREPRESULT2"

# Alle relevanten confounds-Dateien finden
pattern = os.path.join(base_dir, "sub-*", "ses-*", "func", "*desc-confounds_timeseries.tsv")
confound_files = glob.glob(pattern)

# Ergebnisse speichern
results = []

for file in confound_files:
    try:
        df = pd.read_csv(file, sep='\t')

        if 'framewise_displacement' not in df.columns:
            print(f"  Keine FD-Spalte in {file}")
            continue

        fd = pd.to_numeric(df['framewise_displacement'], errors='coerce').dropna()

        mean_fd = fd.mean()
        high_fd_count = (fd > high_fd_threshold).sum()
        high_fd_percentage = high_fd_count / len(fd)

        failed = (mean_fd > mean_fd_threshold) or (high_fd_percentage > high_fd_percentage_threshold)

        # Subjekt & Session extrahieren
        parts = file.split(os.sep)
        subject = [p for p in parts if p.startswith("sub-")][0]
        session = [p for p in parts if p.startswith("ses-")][0]

        results.append({
            'subject': subject,
            'session': session,
            'mean_FD': round(mean_fd, 4),
            'FD>0.5_count': high_fd_count,
            'FD>0.5_%': round(high_fd_percentage * 100, 2),
            'FAIL': failed,
            'file': file
        })

    except Exception as e:
        print(f" Fehler bei Datei {file}: {e}")

# In DataFrame umwandeln
results_df = pd.DataFrame(results)

# Ausgabe
print("\n===== Zusammenfassung =====")
print(results_df.to_string(index=False))

# Als CSV speichern
output_file = os.path.join(base_dir, "FD_QC_Summary.csv")
results_df.to_csv(output_file, index=False)
print(f"\n Ergebnisse gespeichert in: {output_file}")



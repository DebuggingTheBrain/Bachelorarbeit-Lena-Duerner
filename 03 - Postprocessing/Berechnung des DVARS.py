"""
Titel: DVARS-Qualitätskontrolle für fMRIPrep-Ausgaben  
Autor: Lena Dürner  
Datum: 2025-09-01  

Beschreibung:  
Dieses Skript durchsucht fMRIPrep-Ausgaben nach Confounds-Dateien (`*desc-confounds_timeseries.tsv`)  
und berechnet für jede Datei Qualitätsmetriken auf Basis der **DVARS**-Spalte:  
- Standardabweichung der DVARS  
- Median der DVARS  
- Anzahl von Spikes oberhalb des 1.5-fachen Medians  

Ein Run wird als **FAIL** markiert, wenn die Standardabweichung > 4.5 ist oder mehr als 10 Spikes auftreten.  
Fehlende DVARS-Spalten führen ebenfalls automatisch zu einem Ausschluss.  

Abhängigkeiten:  
    - Python 3.10  
    - pandas >= 2.0  

Input:  
    - `<root_dir>/sub-*/ses-*/func/*desc-confounds_timeseries.tsv`  

Output:  
    - `dvars_with_fail_flag.csv` (enthält Subject, Session, DVARS-Metriken und FAIL-Flag)  

Verwendung:  
    python check_dvars_fail.py  
"""


import os
import glob
import pandas as pd

# Root-Verzeichnis anpassen
root_dir = r'F:\FMRIPREPRESULT2'

# Suche alle relevanten confounds.tsv-Dateien
tsv_files = glob.glob(os.path.join(root_dir, "sub-*", "ses-*", "func", "*desc-confounds_timeseries.tsv"))

results = []

for file in tsv_files:
    try:
        df = pd.read_csv(file, sep="\t")
        subject = file.split(os.sep)[-4]
        session = file.split(os.sep)[-3]

        if 'dvars' in df.columns:
            dvars = pd.to_numeric(df['dvars'], errors='coerce').dropna()
            std_dvars = dvars.std()
            median_dvars = dvars.median()
            high_dvars_spikes = (dvars > (1.5 * median_dvars)).sum()

            # Ausschluss-Kriterien
            failed = (std_dvars > 4.5) or (high_dvars_spikes > 10)

        else:
            std_dvars = None
            high_dvars_spikes = None
            failed = True  # Wenn keine DVARS-Spalte vorhanden → Ausschluss aus Sicherheit

        results.append({
            'subject': subject,
            'session': session,
            'std_dvars': round(std_dvars, 4) if std_dvars is not None else 'n/a',
            '#high_dvars_spikes': high_dvars_spikes,
            'FAIL': failed,
            'file': file
        })

    except Exception as e:
        print(f" Fehler bei Datei {file}: {e}")

# Speichern als CSV
output_df = pd.DataFrame(results)
output_df.to_csv("dvars_with_fail_flag.csv", index=False)

print(" Fertig! Datei 'dvars_with_fail_flag.csv' enthält jetzt auch die FAIL-Kennzeichnung.")


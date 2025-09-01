"""
Titel: Umbenennung von komprimierten Sequenz-Dateien
Autor: Lena Dürner
Datum: 2025-09-01

Beschreibung:
    Dieses Skript durchsucht ein Hauptverzeichnis rekursiv nach .7z-Dateien,
    deren Namen einem bestimmten Muster folgen (z. B. *_T1_001.7z, *_T4_002.7z).
    Die Dateien werden so umbenannt, dass nur ein einheitlicher Name pro Tag
    bleibt (z. B. *_T1.7z, *_T4.7z). Dadurch werden doppelte Varianten mit
    unterschiedlichen Nummerierungen konsolidiert.

Abhängigkeiten:
    - Python 3.10
    - os (Standardbibliothek)
    - re (Standardbibliothek)

Input:
    - Hauptverzeichnis mit Unterordnern und komprimierten Dateien
      (z. B. "F:\\Dataset")

Output:
    - Umbenannte .7z-Dateien im gleichen Verzeichnis
"""


import os
import re

# Hauptordner
root_dir = r'F:\Dataset'

# Muster: Alles bis _T1 oder _T4, danach eine Zahl, dann .7z
pattern = re.compile(r'^(.*_T[14])_[0-9]+\.7z$')

# Durchlaufe alle Unterordner
for dirpath, _, filenames in os.walk(root_dir):
    for filename in filenames:
        if filename.endswith('.7z'):
            match = pattern.match(filename)
            if match:
                new_filename = match.group(1) + '.7z'
                old_path = os.path.join(dirpath, filename)
                new_path = os.path.join(dirpath, new_filename)

                # Umbenennen, falls noch nicht passiert
                if old_path != new_path:
                    print(f"📝 Umbenennen:\n  {old_path}\n→ {new_path}")
                    os.rename(old_path, new_path)

print("\n Alle passenden .7z-Dateien wurden umbenannt.")


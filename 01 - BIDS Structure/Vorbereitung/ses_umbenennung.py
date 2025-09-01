"""
Titel: Vereinheitlichung von Sequenz-Ordnernamen
Autor: Lena Dürner
Datum: 2025-09-01

Beschreibung:
    Dieses Skript durchsucht rekursiv ein Hauptverzeichnis und benennt alle
    Unterordner mit Sequenzangaben um. Ordner, die "T1" im Namen enthalten,
    werden in "ses-T1" umbenannt, Ordner mit "T4" im Namen in "ses-T4".
    Dadurch entsteht eine konsistente und standardisierte Ordnerstruktur.

Abhängigkeiten:
    - Python 3.10
    - os (Standardbibliothek)

Input:
    - Hauptverzeichnis mit Unterordnern (z. B. "F:\\Dataset")

Output:
    - Umbenannte Ordner im Format "ses-T1" bzw. "ses-T4"
"""

import os

# Definiere den Pfad zum Hauptordner
hauptordner = r'F:\Dataset'

# Durchlaufe alle Unterordner des Hauptordners
for root, dirs, files in os.walk(hauptordner):
    for dir_name in dirs:
        # Wenn "T1" im Namen des Ordners ist, Umbenennung zu "ses-T1"
        if 'T1' in dir_name:
            # Berechnung (komplett zu "ses-T1")
            neuer_name = 'ses-T1'
            # Erstelle den vollständigen alten und neuen Pfad
            alter_pfad = os.path.join(root, dir_name)
            neuer_pfad = os.path.join(root, neuer_name)
            # Benenne den Ordner um
            os.rename(alter_pfad, neuer_pfad)
            print(f"Ordner umbenannt: {alter_pfad} -> {neuer_pfad}")
        
        # Wenn "T4" im Namen des Ordners ist, Umbenennung zu "ses-T4"
        elif 'T4' in dir_name:
            # Berechne den neuen Namen des Ordners (komplett zu "ses-T4")
            neuer_name = 'ses-T4'
            # Erstelle den vollständigen alten und neuen Pfad
            alter_pfad = os.path.join(root, dir_name)
            neuer_pfad = os.path.join(root, neuer_name)
            # Benenne den Ordner um
            os.rename(alter_pfad, neuer_pfad)
            print(f"Ordner umbenannt: {alter_pfad} -> {neuer_pfad}")


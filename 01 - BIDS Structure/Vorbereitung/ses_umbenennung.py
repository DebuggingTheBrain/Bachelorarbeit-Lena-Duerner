import os

# Definiere den Pfad zum Hauptordner
hauptordner = r'F:\Dataset'

# Durchlaufe alle Unterordner des Hauptordners
for root, dirs, files in os.walk(hauptordner):
    for dir_name in dirs:
        # Wenn "T1" im Namen des Ordners ist, benenne ihn um zu "ses-T1"
        if 'T1' in dir_name:
            # Berechne den neuen Namen des Ordners (komplett zu "ses-T1")
            neuer_name = 'ses-T1'
            # Erstelle den vollständigen alten und neuen Pfad
            alter_pfad = os.path.join(root, dir_name)
            neuer_pfad = os.path.join(root, neuer_name)
            # Benenne den Ordner um
            os.rename(alter_pfad, neuer_pfad)
            print(f"Ordner umbenannt: {alter_pfad} -> {neuer_pfad}")
        
        # Wenn "T4" im Namen des Ordners ist, benenne ihn um zu "ses-T4"
        elif 'T4' in dir_name:
            # Berechne den neuen Namen des Ordners (komplett zu "ses-T4")
            neuer_name = 'ses-T4'
            # Erstelle den vollständigen alten und neuen Pfad
            alter_pfad = os.path.join(root, dir_name)
            neuer_pfad = os.path.join(root, neuer_name)
            # Benenne den Ordner um
            os.rename(alter_pfad, neuer_pfad)
            print(f"Ordner umbenannt: {alter_pfad} -> {neuer_pfad}")

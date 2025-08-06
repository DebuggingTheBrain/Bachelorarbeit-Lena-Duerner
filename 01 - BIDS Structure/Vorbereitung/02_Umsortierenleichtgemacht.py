import os
import shutil

# Pfad zum Dataset-Ordner mit allen Patienten
hauptordner = r"F:\Dataset"

# Liste der gewünschten Tags
tags = ["T1", "T4"]  # Hier kannst du später einfach T2, FLAIR, etc. hinzufügen

# Gehe alle Patientenordner durch
for patientenordner in os.listdir(hauptordner):
    pfad_patient = os.path.join(hauptordner, patientenordner)

    if os.path.isdir(pfad_patient):
        print(f"\n📂 Verarbeite: {patientenordner}")

        # Liste aller Dateien in diesem Patientenordner
        for datei in os.listdir(pfad_patient):
            dateipfad = os.path.join(pfad_patient, datei)

            if os.path.isfile(dateipfad):
                for tag in tags:
                    # Wenn Datei den aktuellen Tag enthält
                    if tag in datei:
                        # Suche nach passendem Unterordner für diesen Tag
                        for unterordner in os.listdir(pfad_patient):
                            unterordnerpfad = os.path.join(pfad_patient, unterordner)

                            if os.path.isdir(unterordnerpfad) and tag in unterordner:
                                # Verschiebe Datei
                                neues_ziel = os.path.join(unterordnerpfad, datei)
                                shutil.move(dateipfad, neues_ziel)
                                print(f"✔️  {datei} -> {unterordner} (Tag: {tag})")
                                break

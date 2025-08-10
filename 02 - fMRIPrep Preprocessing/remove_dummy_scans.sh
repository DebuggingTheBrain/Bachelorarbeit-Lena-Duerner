#!/bin/bash

# Verzeichnis mit BIDS-Daten (angepasst für Windows unter WSL/Git Bash)
BIDS_DIR="/mnt/f/RESULTVER2"

# Logdatei
LOGFILE="$BIDS_DIR/dummy_removal_log.txt"
echo "Dummy-Scan Removal Log - $(date)" > "$LOGFILE"

# Finde alle funktionellen NIfTI-Dateien (*.nii.gz)
find "$BIDS_DIR" -type f -name "*_bold.nii.gz" | while read nii; do
    echo "Bearbeite Datei: $nii" | tee -a "$LOGFILE"

    # Volumen vor dem Schneiden
    VOL_PRE=$(fslinfo "$nii" | grep '^dim4' | awk '{print $2}')
    echo "Volumen vor dem Schneiden: $VOL_PRE" | tee -a "$LOGFILE"

    if [ "$VOL_PRE" -le 5 ]; then
        echo "Übersprungen: Weniger oder genau 5 Volumen." | tee -a "$LOGFILE"
        continue
    fi

    # Neuer Dateiname
    TMP_NII="${nii%.nii.gz}_trimmed.nii.gz"

    # Schneide Dummy-Scans weg
    fslroi "$nii" "$TMP_NII" 5 -1

    # Volumen danach
    VOL_POST=$(fslinfo "$TMP_NII" | grep '^dim4' | awk '{print $2}')
    echo "Volumen nach dem Schneiden: $VOL_POST" | tee -a "$LOGFILE"

    # Ersetze Original
    mv "$TMP_NII" "$nii"
    echo "Datei ersetzt." | tee -a "$LOGFILE"
    echo "---------------------------------------------" | tee -a "$LOGFILE"
done

echo "Alle Dateien verarbeitet." | tee -a "$LOGFILE"

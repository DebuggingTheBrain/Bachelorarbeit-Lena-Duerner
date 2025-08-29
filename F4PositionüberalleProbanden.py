#!/bin/bash

# === INPUTS ===
SOURCE_TEMPLATE="/mnt/f/Normalisierung/tpl-MNI152Lin_res-01_T1w.nii.gz"
TARGET_TEMPLATE="/mnt/f/Normalisierung/tpl-MNI152NLin2009cAsym_res-01_T1w.nii.gz"
WARP_PREFIX="mniOld_to_mni2009c"

# Ursprünglicher Punkt (RAS) → hier eingeben:
RAS_X=49.726
RAS_Y=39.511
RAS_Z=54.574

# === Schritt 1: Registrierung falls nicht vorhanden ===
if [[ ! -f "${WARP_PREFIX}_1Warp.nii.gz" ]]; then
    echo "🌀 Starte Registrierung zwischen Templates..."
    antsRegistrationSyN.sh \
      -d 3 \
      -f "$TARGET_TEMPLATE" \
      -m "$SOURCE_TEMPLATE" \
      -o "${WARP_PREFIX}_" \
      -n 4
else
    echo "✔ Warp-Dateien vorhanden – Registrierung übersprungen."
fi

# === Schritt 2: RAS → LPS konvertieren ===
LPS_X=$(echo "-1 * $RAS_X" | bc -l)
LPS_Y=$(echo "-1 * $RAS_Y" | bc -l)
LPS_Z=$RAS_Z

echo "📍 Ursprünglich (RAS): $RAS_X $RAS_Y $RAS_Z"
echo "→ Konvertiert (LPS):  $LPS_X $LPS_Y $LPS_Z"

# === Schritt 3: Punkt in CSV speichern ===
echo "x,y,z" > points_LPS.csv
echo "$LPS_X,$LPS_Y,$LPS_Z" >> points_LPS.csv

# === Schritt 4: Transformation anwenden ===
antsApplyTransformsToPoints -d 3 \
  -i points_LPS.csv \
  -o points_2009c_LPS.csv \
  -t "${WARP_PREFIX}_1Warp.nii.gz" \
  -t "${WARP_PREFIX}_0GenericAffine.mat"

# === Schritt 5: Ergebnis laden und zurück in RAS konvertieren ===
if [[ -f points_2009c_LPS.csv ]]; then
    read -r _ < points_2009c_LPS.csv  # Kopfzeile überspringen
    read -r OUT_LINE < <(tail -n 1 points_2009c_LPS.csv)
    IFS=',' read -r OUT_LPS_X OUT_LPS_Y OUT_LPS_Z <<< "$OUT_LINE"

    OUT_RAS_X=$(echo "-1 * $OUT_LPS_X" | bc -l)
    OUT_RAS_Y=$(echo "-1 * $OUT_LPS_Y" | bc -l)
    OUT_RAS_Z=$OUT_LPS_Z

    echo ""
    echo "✅ Transformierte Koordinate in MNI2009c (RAS):"
    printf "x=%.3f, y=%.3f, z=%.3f\n" "$OUT_RAS_X" "$OUT_RAS_Y" "$OUT_RAS_Z"
else
    echo "❌ Fehler: Transformierte CSV (points_2009c_LPS.csv) wurde nicht erzeugt."
fi

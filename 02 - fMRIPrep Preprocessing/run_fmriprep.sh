#!/bin/bash

# ====== Benutzerdefinierte Eingaben ======
bids_root_dir="/mnt/f/RESULTVER2"
output_dir="/mnt/f/FMRIPREPRESULTFINAL"
fs_license="/mnt/c/Users/Herrmann_M/Desktop/license.txt"

nthreads=8
mem=28 # in GB

# ====== Speicher anpassen ======
mem=$(echo "${mem//[!0-9]/}") # Entfernt Nicht-Zahlen (z.B. "GB")
mem_mb=$(( (mem * 1024) - 5000 )) # 5GB Puffer

# ====== Arbeitsverzeichnis für fMRIPrep (wird innerhalb des Containers genutzt) ======
work_dir="/mnt/f/fmriprep_work"

# ====== Durchlaufe alle Subjekte im BIDS-Ordner ======
for subj_dir in "${bids_root_dir}"/sub-*; do
    subj=$(basename "$subj_dir")     # z.B. sub-SM2VP007
    subj=${subj#sub-}                # Entfernt "sub-"

    # ====== Prüfung: Wurde dieser VP schon verarbeitet? ======
    if [ -d "${output_dir}/sub-${subj}" ]; then
        echo "Skipping $subj – already processed."
        continue
    fi

    echo "Processing participant $subj..."

    docker run --rm -ti \
        -v "${bids_root_dir}:/data:ro" \
        -v "${output_dir}:/out" \
        -v "${fs_license}:/opt/freesurfer/license.txt:ro" \
        -v "${work_dir}:/work" \
        nipreps/fmriprep:latest \
        /data /out participant \
        --participant-label "$subj" \
        --output-spaces MNI152NLin2009cAsym T1w \
        --bold2anat-init t1w \
        --nthreads "$nthreads" \
        --mem_mb "$mem_mb" \
        --write-graph \
        --stop-on-first-crash \
        --notrack \
        --force syn-sdc \
        -w /work

    echo "Processing completed for participant $subj."
done

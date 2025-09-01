: '
Titel: Automatisierte MRIQC-Analyse für BIDS-Daten  
Autor: Lena Dürner  
Datum: 2025-09-01  

Beschreibung:  
Dieses Skript führt eine Qualitätskontrolle von fMRT-Daten mit **MRIQC** (Docker-Version) durch.  
Es iteriert über alle `sub-*` Ordner im BIDS-Verzeichnis, startet die participant-Level-Analyse  
mit definierter Thread- und Speicheranzahl und speichert die Ergebnisse für jedes Subjekt separat.  
Anschließend wird eine Gruppenanalyse auf allen Subjekten durchgeführt.  

Abhängigkeiten:  
    - Bash  
    - Docker  
    - MRIQC Docker-Image (`nipreps/mriqc:24.0.2` für Teilnehmer-Analysen,  
      `nipreps/mriqc:21.0.0rc2` für Gruppenanalyse)  

Input:  
    - BIDS-Verzeichnis: `$bidsdir/sub-*`  

Output:  
    - `$topdir/derivatives/mriqc/<subj>/` (Einzelergebnisse pro Subjekt)  
    - `$topdir/derivatives/mriqc/group_bold.html` (Gruppen-Reports)  

Verwendung:  
    bash run_mriqc.sh  
'


#!/bin/bash

topdir=/mnt/f/RESULTVER2
bidsdir=/mnt/f/RESULTVER2
nthreads=2
mem=10

outputdir=$topdir/derivatives/mriqc
mkdir -p $outputdir

for subjpath in $bidsdir/sub-*; do
  subj=$(basename $subjpath)
  echo "Starte MRIQC für $subj"
  mkdir -p $outputdir/$subj

  docker run -it --rm \
    -v $bidsdir:/data:ro \
    -v $outputdir/$subj:/out \
    nipreps/mriqc:24.0.2 /data /out participant \
    --participant-label ${subj#sub-} \
    --nprocs $nthreads \
    --omp-nthreads $nthreads \
    --mem-gb $mem \
    --float32 \
    --ants-nthreads $nthreads \
    --no-sub \
    --no-datalad-get \
    -w /out/work \
    -v

  if [ $? -ne 0 ]; then
    echo "MRIQC run failed für $subj"
  else
    echo "MRIQC erfolgreich für $subj"
  fi
done

echo "Starte Gruppenanalyse..."

docker run -it --rm \
  -v $bidsdir:/data:ro \
  -v $outputdir:/out \
  nipreps/mriqc:21.0.0rc2 /data /out group \
  --no-sub \
  --no-datalad-get \
  -v

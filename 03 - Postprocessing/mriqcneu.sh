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

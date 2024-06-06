#!/bin/bash
#
#SBATCH --job-name=nextflow_Chip-Seq
#SBATCH -c 1
#SBATCH --mem=8g
#SBATCH -t 2-00:00 # Runtime in D-HH:MM
#SBATCH --output=nextflow_head.out
#SBATCH --mail-user=ahk42@pitt.edu
#SBATCH --mail-type=ALL

unset TMPDIR

module purge
module load nextflow/23.10.1
module load singularity/3.9.6
export NXF_SINGULARITY_CACHEDIR=/ihome/crc/install/genomics_nextflow/nf-core-chipseq-2.0.0/singularity-images
export SINGULARITY_CACHEDIR=/ihome/crc/install/genomics_nextflow/nf-core-chipseq-2.0.0/singularity-images
export TMP="/bgfs/ialdiri/CR/VSX2_Chip-Seq/work"

nextflow run /ihome/crc/install/genomics_nextflow/nf-core-chipseq-2.0.0/workflow -profile htc -resume -params-file nf-params.json 
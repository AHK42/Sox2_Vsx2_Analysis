#!/bin/bash
#
#SBATCH --job-name=nextflow_BL
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
module load squashfs-tools/4.4

export NXF_SINGULARITY_CACHEDIR=/ihome/crc/install/genomics_nextflow/nf-core-cutandrun-3.2.2/singularity-images
export SINGULARITY_CACHEDIR=/ihome/crc/install/genomics_nextflow/nf-core-cutandrun-3.2.2/singularity-images
export NXF_LOG=/bgfs/ialdiri/CR/Sox2_Nextflow_Blacklist/nextflow.log

nextflow run /ihome/crc/install/genomics_nextflow/nf-core-cutandrun-3.2.2/workflow -profile htc -resume -params-file nf-params.json
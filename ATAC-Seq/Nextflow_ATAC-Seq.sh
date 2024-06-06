#!/bin/bash
#
#SBATCH --job-name=nextflow_ATAC
#SBATCH -c 1
#SBATCH --mem=8g
#SBATCH -t 2-00:00 # Runtime in D-HH:MM
#SBATCH --output=nextflow_head.out
#SBATCH --error=nextflow_head.err 
#SBATCH --mail-user=ahk42@pitt.edu
#SBATCH --mail-type=ALL

# Load necessary modules
module purge
module load nextflow/23.04.2
module load singularity/3.9.6

export NXF_SINGULARITY_CACHEDIR=/ihome/crc/install/genomics_nextflow/nf-core-atacseq-2.0/singularity-images
export SINGULARITY_CACHEDIR=/ihome/crc/install/genomics_nextflow/nf-core-atacseq-2.0/singularity-images
# Run the nf-core ATAC-Seq pipeline
nextflow run /ihome/crc/install/genomics_nextflow/nf-core-atacseq-2.0/workflow -profile htc -resume -params-file nf-params.json
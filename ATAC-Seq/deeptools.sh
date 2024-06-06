#!/bin/bash 
#SBATCH -t 04:00:00
#SBATCH --job-name=ATACDeeptools
#SBATCH -c 16
#SBATCH --mem=119g
#SBATCH --output=ATACDeeptools.out 
#SBATCH --error=ATACDeeptools.err         
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=ahk42@pitt.edu
module load gcc/8.2.0
module load python/anaconda3.10-2022.10
source activate deeptools

# Step 1: Generate bigWig files from BAM files
# Define paths and constants
BAM_DIR="/bgfs/ialdiri/ATAC-Seq/Sox2_ATAC-Seq/outDir/bowtie2/merged_library"
BIGWIG_DIR="/bgfs/ialdiri/ATAC-Seq/Sox2_ATAC-Seq/bamCovBigWig"
BLACKLIST="/bgfs/ialdiri/Genomes/mm10-blacklist.v2.liftover.mm39.bed"
CHROM_SIZE="2650000000"
WINDOW_SIZE=10

# Bam files to process
BAM_FILES=("WT1_REP1.mLb.clN.sorted.bam" "WT2_REP1.mLb.clN.sorted.bam" "KO1_REP1.mLb.clN.sorted.bam" "KO2_REP1.mLb.clN.sorted.bam")

mkdir -p $BIGWIG_DIR

# Loop over BAM files to generate bigWig files
for BAM in "${BAM_FILES[@]}"; do
    SAMPLE_NAME=$(basename "$BAM" | cut -d. -f1)
    bamCoverage \
        --bam "$BAM_DIR/$BAM" \
        --outFileName "$BIGWIG_DIR/${SAMPLE_NAME}.bigWig" \
        --binSize $WINDOW_SIZE \
        --normalizeUsing RPGC \
        --effectiveGenomeSize $CHROM_SIZE \
        --binSize $WINDOW_SIZE \
        --ignoreForNormalization chrX \
        --blackListFileName $BLACKLIST \
        --numberOfProcessors max \
        --verbose 
done
# Step 2: Generate matricies from bigWig files and then plot results
# Define paths and files
BIGWIG_FILES=("$BIGWIG_DIR/WT1_REP1.bigWig" "$BIGWIG_DIR/WT2_REP1.bigWig" "$BIGWIG_DIR/KO1_REP1.bigWig" "$BIGWIG_DIR/KO2_REP1.bigWig")
GENE_ANNOTATION="/bgfs/ialdiri/Genomes/mm39.ncbiRefSeq.gtf.gz"

# Recreate Pluto Plot
computeMatrix reference-point --referencePoint TSS -b 2000 -a 2000 \
    -S "${BIGWIG_FILES[@]}" \
    -R $GENE_ANNOTATION \
    --binSize $WINDOW_SIZE \
    -o pluto_matrix.gz \
    --outFileSortedRegions sorted_regions.bed \
    --sortRegions descend \
    --sortUsing mean \
    --missingDataAsZero \
    --verbose -p max --skipZeros --smartLabels

plotHeatmap -m pluto_matrix.gz -out Sox2_ATAC-Seq_Pluto_heatmap.png \
    --colorList white,#3442ab  \
    --refPointLabel "TSS" --verbose \
    -T "Sox2 Knockout" \
    --averageTypeSummaryPlot mean

# Change reference to center
computeMatrix reference-point --referencePoint center -b 2000 -a 2000 \
    -S "${BIGWIG_FILES[@]}" \
    -R /bgfs/ialdiri/ATAC-Seq/Sox2_ATAC-Seq/outDir/bowtie2/merged_library/macs2/narrow_peak/consensus_summits.bed \
    --binSize $WINDOW_SIZE \
    -o matrix.gz \
    --outFileSortedRegions sorted_regions.bed \
    --sortRegions descend \
    --sortUsing mean \
    --missingDataAsZero \
    --verbose -p max --skipZeros --smartLabels

plotHeatmap -m matrix.gz -out Sox2_ATAC-Seq_heatmap.png \
    --colorMap Blues  \
    --refPointLabel "Center" --verbose \
    -T "Sox2 Knockout" \
    --averageTypeSummaryPlot mean --legendLocation lower-center

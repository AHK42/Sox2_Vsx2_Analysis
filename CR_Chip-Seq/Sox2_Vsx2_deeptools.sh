#!/bin/bash 
#SBATCH -t 08:00:00
#SBATCH --job-name=Sox2_VSX2
#SBATCH -c 16
#SBATCH --mem=119g
#SBATCH --output=SoxVsx%j.out 
#SBATCH --error=SoxVsx%j.err         
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=ahk42@pitt.edu

# Load necessary modules
module purge
module load gcc/8.2.0
module load python/anaconda3.10-2022.10

# Activate the conda environment
source activate deeptools

# Define paths and variables used by both TFs
BLACKLIST="/ihome/crc/install/genomics_nextflow/nf-core-cutandrun-3.2.2/workflow/assets/blacklists/GRCm39-blacklist.bed"
CHROM_SIZE=2650000000
WINDOW_SIZE=10
GENE_ANNOTATION="/bgfs/ialdiri/Genomes/mm39.ncbiRefSeq.gtf.gz"
PEAK_FILES_DIR="/bgfs/ialdiri/Sox2_Vsx2/Sox2_Vsx2_Peaks"

# Define paths and variables to each individual TF
# Sox2
SOX2_BAM_DIR="/bgfs/ialdiri/CR/Sox2CR/results/02_alignment/bowtie2/target/dedup"
SOX2_BIGWIG_DIR="/bgfs/ialdiri/Sox2_Vsx2/Sox2BW"
SOX2_BAM_FILES=("SOX2_S1_R1.target.dedup.sorted.bam" "SOX2_S3_R1.target.dedup.sorted.bam" "SOX2_NB_S2_R1.target.dedup.sorted.bam" "SOX2_NB_S4_R1.target.dedup.sorted.bam")

# Vsx2
VSX2_BAM_DIR="/bgfs/ialdiri/CR/VSX2_Chip-Seq/outDir/bowtie2/mergedLibrary"
VSX2_BIGWIG_DIR="/bgfs/ialdiri/Sox2_Vsx2/Vsx2BW"
VSX2_BAM_FILES=("Vsx2_Sample1.mLb.clN.sorted.bam" "Vsx2_Sample3.mLb.clN.sorted.bam" "Vsx2_Sample2.mLb.clN.sorted.bam" "Vsx2_Sample4.mLb.clN.sorted.bam")

# Create the output directory if it doesn't exist
mkdir -p $SOX2_BIGWIG_DIR 
mkdir -p $VSX2_BIGWIG_DIR

# # STEP 1: Generate BigWig files for each TF
# # Sox2
# for BAM in "${SOX2_BAM_FILES[@]}"; do
#    SAMPLE_NAME=$(basename "$BAM" | cut -d. -f1)
#    bamCoverage \
#        --bam "$SOX2_BAM_DIR/$BAM" \
#        --outFileName "$SOX2_BIGWIG_DIR/${SAMPLE_NAME}.bigWig" \
#        --binSize $WINDOW_SIZE \
#        --normalizeUsing RPGC \
#        --effectiveGenomeSize $CHROM_SIZE \
#        --ignoreForNormalization chrX \
#        --blackListFileName $BLACKLIST \
#        --numberOfProcessors max \
#        --verbose \
#        --extendReads
# done

# # Vsx2 - no extend reads for ChIP data
# for BAM in "${VSX2_BAM_FILES[@]}"; do
#     SAMPLE_NAME=$(basename "$BAM" | cut -d. -f1)
#     bamCoverage \
#         --bam "$VSX2_BAM_DIR/$BAM" \
#         --outFileName "$VSX2_BIGWIG_DIR/${SAMPLE_NAME}.bigWig" \
#         --binSize $WINDOW_SIZE \
#         --normalizeUsing RPGC \
#         --effectiveGenomeSize $CHROM_SIZE \
#         --ignoreForNormalization chrX \
#         --blackListFileName $BLACKLIST \
#         --numberOfProcessors max \
#         --verbose
# done

# STEP 2: Use BigWig files to generate matrices and plot results
# Define paths and files to BigWig Files
SOX2_BIGWIG_FILES=("$SOX2_BIGWIG_DIR/SOX2_S1_R1.bigWig" "$SOX2_BIGWIG_DIR/SOX2_S3_R1.bigWig")
VSX2_BIGWIG_FILES=("$VSX2_BIGWIG_DIR/Vsx2_Sample_1.bigWig" "$VSX2_BIGWIG_DIR/Vsx2_Sample_3.bigWig")

# # Recreate Sox2 Pluto Tornado Plot
# computeMatrix reference-point --referencePoint TSS -b 2000 -a 2000 \
#     -S "${VSX2_BIGWIG_FILES[@]}"  \
#     -R "$GENE_ANNOTATION" \
#     --binSize $WINDOW_SIZE \
#     -o sox2_pluto_matrix.gz \
#     --sortRegions descend \
#     --sortUsing mean \
#     --missingDataAsZero \
#     --verbose -p max --skipZeros --smartLabels

# plotHeatmap -m sox2_pluto_matrix.gz -out sox2_pluto_heatmap.png \
#     --colorList white,#3442ab \
#     --refPointLabel "TSS" --verbose \
#     -T "Sox2 Pluto Test Tornado Plot" \
#     --averageTypeSummaryPlot mean

# # Recreate Vsx2 Pluto Tornado Plot
# computeMatrix reference-point --referencePoint TSS -b 2000 -a 2000 \
#     -S "${VSX2_BIGWIG_FILES[@]}"  \
#     -R "$GENE_ANNOTATION" \
#     --binSize $WINDOW_SIZE \
#     -o vsx2_pluto_matrix.gz \
#     --sortRegions descend \
#     --sortUsing mean \
#     --missingDataAsZero \
#     --verbose -p max --skipZeros --smartLabels

# plotHeatmap -m vsx2_pluto_matrix.gz -out vsx2_pluto_heatmap.png \
#     --colorList white,#3442ab \
#     --refPointLabel "TSS" --verbose \
#     -T "Vsx2 Pluto Test Tornado Plot" \
#     --averageTypeSummaryPlot mean

# Create Tornado Plot with different peak files
computeMatrix reference-point --referencePoint center -b 2000 -a 2000 \
    -S "${VSX2_BIGWIG_FILES[@]}" \
    -R "$PEAK_FILES_DIR/sox2_vsx2_shared_peaks.bed" "$PEAK_FILES_DIR/sox2_unique_peaks.bed" "$PEAK_FILES_DIR/vsx2_unique_peaks.bed" \
    --binSize $WINDOW_SIZE \
    -o sox2_vsx2_overlap_matrix.gz \
    --sortRegions descend \
    --sortUsing mean \
    --missingDataAsZero \
    --verbose -p max --skipZeros --smartLabels

plotHeatmap -m sox2_vsx2_overlap_matrix.gz -out mm39sox2_vsx2_overlap_heatmap.png \
    --colorList white,#3442ab \
    --refPointLabel "center" --verbose \
    -T "Sox2 and Vsx2 Peaks" \
    --averageTypeSummaryPlot mean

# Genomic Occupancy and signal enrichment plots (profilePlots)

# Sox2 Binding 
computeMatrix reference-point --referencePoint center -b 2000 -a 2000 \
    -S "${SOX2_BIGWIG_FILES[@]}"  \
    -R "$PEAK_FILES_DIR/sox2_vsx2_shared_peaks.bed" "$PEAK_FILES_DIR/sox2_unique_peaks.bed" "$PEAK_FILES_DIR/vsx2_unique_peaks.bed" \
    --binSize $WINDOW_SIZE \
    -o sox2_binding_matrix.gz \
    --sortRegions descend \
    --sortUsing mean \
    --missingDataAsZero \
    --verbose -p max --skipZeros --smartLabels

plotProfile -m sox2_binding_matrix.gz \
 -out sox2_binding.png \
 --plotType heatmap \
 --colors RdBu_r \
 --yMin 0 --yMax 18

 plotProfile -m sox2_binding_matrix.gz \
 -out sox2_signal.png 
 
 # Vsx2 Binding 
computeMatrix reference-point --referencePoint center -b 2000 -a 2000 \
    -S "${VSX2_BIGWIG_FILES[@]}" \
    -R "$PEAK_FILES_DIR/sox2_vsx2_shared_peaks.bed" "$PEAK_FILES_DIR/sox2_unique_peaks.bed" "$PEAK_FILES_DIR/vsx2_unique_peaks.bed" \
    --binSize $WINDOW_SIZE \
    -o vsx2_binding_matrix.gz \
    --sortRegions descend \
    --sortUsing mean \
    --missingDataAsZero \
    --verbose -p max --skipZeros --smartLabels

plotProfile -m vsx2_binding_matrix.gz \
 -out vsx2_binding.png \
 --plotType heatmap \
 --colors RdBu_r \
 --yMin 0 --yMax 18

 plotProfile -m vsx2_binding_matrix.gz \
 -out vsx2_signnal.png 
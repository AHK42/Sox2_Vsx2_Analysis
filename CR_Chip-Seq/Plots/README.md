# SOX2 CUT&RUN and Vsx2 ChIP-Seq Plots

## Changes

CR_Chip-Seq Plots

All plots that end in "_new_peaks" are plots updated with the new unique peak files generated with 'bedtools intersect'. 

ATAC-Seq

The old heatmap of the WT and KO ATAC data is named "summits_heatmap". The color was changed. This plot was generated with the summit files instead of the normal peak files. These files have a 1bp peak at the summit of the original peak compared to the range in the normal peak files. Ive attached both of these peak files. 
The new plot "Sox2_ATAC_consensus_peak_heatmap.png" was generated using the normal peak files. 

## New Plots

Sox2_ATAC_WT_Bound_heatmap.png 

Sox2_ATAC_WT_Unbound_heatmap.png

These plots were created using bedtools intersect with "Sox2_ATAC_WT_consensus_peaks.bed" and "sox2_consensus.bed" to create unbound and bound files. 


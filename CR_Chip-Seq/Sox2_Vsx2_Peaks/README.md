# SOX2 CUT&RUN and Vsx2 ChIP-Seq Peak Overlap Analysis

The following contains the workflow to generate all of the peak used in this analysis. The original narrowPeak files were outputted from the [nfcore/cutandrun](https://nf-co.re/cutandrun/3.2.2) and [nfcore/chipseq](https://nf-co.re/chipseq/2.0.0) pipelines ran on the [Pitt CRC HTC cluster](https://crc.pitt.edu/). 

## Prerequisites 

**Linux or Mac OS**

[**Miniconda**](https://docs.anaconda.com/free/miniconda/miniconda-install/)

## Workflow 

Start by setting up a conda enviroment for bedtools using the command prompt if not done already.

Add the bioconda channel, as most of the packages used will come from here.
```
conda config --add channels bioconda
```

Create a new enviroment and install bedtools to it.
```
conda create -n bedtools-env bedtools
```

Activate the enviroment.
```
conda activate bedtools-env
```

Navigate to the folder that contains the peak files 
```
cd path/to/peak/files
```

Concatenate narrowPeak files to merge samples together
```
cat SOX2_S1_R1.macs2_peaks.narrowPeak SOX2_S3_R1.macs2_peaks.narrowPeak > sox2_all_peaks.bed
cat Vsx2_Sample1_peaks.narrowPeak Vsx2_Sample3_peaks.narrowPeak > vsx2_all_peaks.bed 
```

Sort both peak files
```
sort -k1,1 -k2,2n sox2_all_peaks.bed > sox2_all_peaks_sorted.bed
sort -k1,1 -k2,2n vsx2_all_peaks.bed > vsx2_all_peaks_sorted.bed
```

Merge peak files to combine redundant peaks
```
bedtools merge -i sox2_all_peaks_sorted.bed > sox2_consensus_peaks.bed
bedtools merge -i vsx2_all_peaks_sorted.bed > vsx2_consensus_peaks.bed
```

Intersect the files to find shared peaks between the two
```
bedtools intersect -a sox2_consensus_peaks.bed -b vsx2_consensus_peaks.bed > sox2_vsx2_shared_peaks.bed
```

Subtract the files from each other to find peaks unique to each TF
```
bedtools intersect -wa -a sox2_consensus.bed -b vsx2_consensus.bed | uniq > sox2_vsx2_shared_peaks.bed 
bedtools intersect -wa -a sox2_consensus.bed -b vsx2_consensus.bed -v | uniq > sox2_unique_peaks.bed 
bedtools intersect -wa -a vsx2_consensus.bed -b sox2_consensus.bed -v | uniq > vsx2_unique_peaks.bed 
```

Deactivate conda enviroment
```
conda deactivate 
```

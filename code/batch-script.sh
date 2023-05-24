#!/bin/bash
. preprocess.sh; trim_adaptors DRIP 1 forward_DRIP_1.fq.gz reverse_DRIP_1.fq.gz
. preprocess.sh; trim_adaptors DRIP 2 forward_DRIP_2.fq.gz reverse_DRIP_2.fq.gz
. preprocess.sh; trim_adaptors DRIP 3 forward_DRIP_3.fq.gz reverse_DRIP_3.fq.gz
. preprocess.sh; align_reads DRIP 1 forward_pair_DRIP_1.sam reverse_pair_DRIP_1.sam
. preprocess.sh; align_reads DRIP 2 forward_pair_DRIP_2.sam reverse_pair_DRIP_2.sam
. preprocess.sh; align_reads DRIP 3 forward_pair_DRIP_3.sam reverse_pair_DRIP_3.sam
. preprocess.sh; sam2sorted_bam DRIP 1 aligned_DRIP_1.sam
. preprocess.sh; sam2sorted_bam DRIP 2 aligned_DRIP_2.sam
. preprocess.sh; sam2sorted_bam DRIP 3 aligned_DRIP_3.sam
. preprocess.sh; mark_duplicates DRIP 1 sorted_DRIP_1.bam
. preprocess.sh; mark_duplicates DRIP 2 sorted_DRIP_2.bam
. preprocess.sh; mark_duplicates DRIP 3 sorted_DRIP_3.bam
. preprocess.sh; strand_specific_bam DRIP 1 marked_duplicates_DRIP_1.bam
. preprocess.sh; strand_specific_bam DRIP 2 marked_duplicates_DRIP_2.bam
. preprocess.sh; strand_specific_bam DRIP 3 marked_duplicates_DRIP_3.bam

# Preprocessed treatment DRIP.

. preprocess.sh; trim_adaptors RNaseH 1 forward_RNaseH_1.fq.gz reverse_RNaseH_1.fq.gz
. preprocess.sh; trim_adaptors RNaseH 2 forward_RNaseH_2.fq.gz reverse_RNaseH_2.fq.gz
. preprocess.sh; trim_adaptors RNaseH 3 forward_RNaseH_3.fq.gz reverse_RNaseH_3.fq.gz
. preprocess.sh; align_reads RNaseH 1 forward_pair_RNaseH_1.sam reverse_pair_RNaseH_1.sam
. preprocess.sh; align_reads RNaseH 2 forward_pair_RNaseH_2.sam reverse_pair_RNaseH_2.sam
. preprocess.sh; align_reads RNaseH 3 forward_pair_RNaseH_3.sam reverse_pair_RNaseH_3.sam
. preprocess.sh; sam2sorted_bam RNaseH 1 aligned_RNaseH_1.sam
. preprocess.sh; sam2sorted_bam RNaseH 2 aligned_RNaseH_2.sam
. preprocess.sh; sam2sorted_bam RNaseH 3 aligned_RNaseH_3.sam
. preprocess.sh; mark_duplicates RNaseH 1 sorted_RNaseH_1.bam
. preprocess.sh; mark_duplicates RNaseH 2 sorted_RNaseH_2.bam
. preprocess.sh; mark_duplicates RNaseH 3 sorted_RNaseH_3.bam
. preprocess.sh; strand_specific_bam RNaseH 1 marked_duplicates_RNaseH_1.bam
. preprocess.sh; strand_specific_bam RNaseH 2 marked_duplicates_RNaseH_2.bam
. preprocess.sh; strand_specific_bam RNaseH 3 marked_duplicates_RNaseH_3.bam

# Preprocessed treatment RNaseH.

. preprocess.sh; trim_adaptors Input 1 forward_Input_1.fq.gz reverse_Input_1.fq.gz
. preprocess.sh; trim_adaptors Input 2 forward_Input_2.fq.gz reverse_Input_2.fq.gz
. preprocess.sh; trim_adaptors Input 3 forward_Input_3.fq.gz reverse_Input_3.fq.gz
. preprocess.sh; align_reads Input 1 forward_pair_Input_1.sam reverse_pair_Input_1.sam
. preprocess.sh; align_reads Input 2 forward_pair_Input_2.sam reverse_pair_Input_2.sam
. preprocess.sh; align_reads Input 3 forward_pair_Input_3.sam reverse_pair_Input_3.sam
. preprocess.sh; sam2sorted_bam Input 1 aligned_Input_1.sam
. preprocess.sh; sam2sorted_bam Input 2 aligned_Input_2.sam
. preprocess.sh; sam2sorted_bam Input 3 aligned_Input_3.sam
. preprocess.sh; mark_duplicates Input 1 sorted_Input_1.bam
. preprocess.sh; mark_duplicates Input 2 sorted_Input_2.bam
. preprocess.sh; mark_duplicates Input 3 sorted_Input_3.bam
. preprocess.sh; strand_specific_bam Input 1 marked_duplicates_Input_1.bam
. preprocess.sh; strand_specific_bam Input 2 marked_duplicates_Input_2.bam
. preprocess.sh; strand_specific_bam Input 3 marked_duplicates_Input_3.bam

# Preprocessed treatment Input.

. peak-ops.sh; call_peaks 'DRIP' RNaseH 1 f
# Writes to intermed/macs2/fRNaseH_1_summits.bed
. peak-ops.sh; call_peaks 'DRIP' Input 1 f
# Writes to intermed/macs2/fInput_1_summits.bed
. peak-ops.sh; call_peaks 'DRIP' RNaseH 1 r
# Writes to intermed/macs2/rRNaseH_1_summits.bed
. peak-ops.sh; call_peaks 'DRIP' Input 1 r
# Writes to intermed/macs2/rInput_1_summits.bed
. peak-ops.sh; call_peaks 'DRIP' RNaseH 2 f
# Writes to intermed/macs2/fRNaseH_2_summits.bed
. peak-ops.sh; call_peaks 'DRIP' Input 2 f
# Writes to intermed/macs2/fInput_2_summits.bed
. peak-ops.sh; call_peaks 'DRIP' RNaseH 2 r
# Writes to intermed/macs2/rRNaseH_2_summits.bed
. peak-ops.sh; call_peaks 'DRIP' Input 2 r
# Writes to intermed/macs2/rInput_2_summits.bed
. peak-ops.sh; call_peaks 'DRIP' RNaseH 3 f
# Writes to intermed/macs2/fRNaseH_3_summits.bed
. peak-ops.sh; call_peaks 'DRIP' Input 3 f
# Writes to intermed/macs2/fInput_3_summits.bed
. peak-ops.sh; call_peaks 'DRIP' RNaseH 3 r
# Writes to intermed/macs2/rRNaseH_3_summits.bed
. peak-ops.sh; call_peaks 'DRIP' Input 3 r
# Writes to intermed/macs2/rInput_3_summits.bed

# Experiment peaks called.

. peak-ops.sh; intersect_peaks_two macs2/fRNaseH_1_summits.bed macs2/fInput_1_summits.bed 
# Writes to filtered_peaks_fRNaseH_1-fInput_1.bed
. peak-ops.sh; intersect_peaks_two macs2/rRNaseH_1_summits.bed macs2/rInput_1_summits.bed 
# Writes to filtered_peaks_rRNaseH_1-rInput_1.bed
. peak-ops.sh; intersect_peaks_two macs2/fRNaseH_2_summits.bed macs2/fInput_2_summits.bed 
# Writes to filtered_peaks_fRNaseH_2-fInput_2.bed
. peak-ops.sh; intersect_peaks_two macs2/rRNaseH_2_summits.bed macs2/rInput_2_summits.bed 
# Writes to filtered_peaks_rRNaseH_2-rInput_2.bed
. peak-ops.sh; intersect_peaks_two macs2/fRNaseH_3_summits.bed macs2/fInput_3_summits.bed 
# Writes to filtered_peaks_fRNaseH_3-fInput_3.bed
. peak-ops.sh; intersect_peaks_two macs2/rRNaseH_3_summits.bed macs2/rInput_3_summits.bed 
# Writes to filtered_peaks_rRNaseH_3-rInput_3.bed

# Peaks intersected across groups.

. peak-ops.sh; intersect_peaks_three forward filtered_peaks_fRNaseH_1-fInput_1.bed filtered_peaks_fRNaseH_2-fInput_2.bed filtered_peaks_fRNaseH_3-fInput_3.bed
# Writes to output/filtered_peaks_forward.bed
. peak-ops.sh; intersect_peaks_three reverse filtered_peaks_rRNaseH_1-rInput_1.bed filtered_peaks_rRNaseH_2-rInput_2.bed filtered_peaks_rRNaseH_3-rInput_3.bed
# Writes to output/filtered_peaks_reverse.bed

# Peaks intersected across replicates.


#!/bin/bash
#export PATH="~/bin:$PATH"
#export PATH=$PATH:~/Desktop/Spring_2023/drip-seq/tools
set -e
set -u
set -o pipefail

# Posix compatible include statements
. preprocess.sh # preprocessing functions
. peak-ops.sh # peak calling and intersection functions
. visuals.sh # visualization functions

TOOLS_PATH="~/desktop/spring_2023/drip-seq/tools" #to access JAR files
REPS={1..3}
TREATMENTS=('DRIP' 'RNaseH' 'Input')

function main {
  #TREATMENTS=($1 $2 $3)
  preprocess_all 
  call_exp_peaks
  
  intersect_exp_peaks_across_groups
  intersect_exp_peaks_across_reps

  all_bigwig_summaries
  all_plot_correlations
}
#------------- abstracted experiment-specific calls ----------------------#

function preprocess_all {
  for treatment in "${TREATMENTS[@]}"
  do 
    trim_adaptors_across_reps $treatment
    align_reads_across_reps $treatment
    sam2sorted_bam_across_reps $treatment
    mark_duplicates_across_reps $treatment
    strand_specific_bam_across_reps $treatment
  done
}

function call_exp_peaks {
  # TODO: unhardcode
  for rep_num in $reps
  do 
    call_peaks 'DRIP' 'RNaseH' $rep_num 'f'
    call_peaks 'DRIP' 'RNaseH' $rep_num 'r'

    call_peaks 'DRIP' 'Input' $rep_num 'f'
    call_peaks 'DRIP' 'Input' $rep_num 'r'
  done
}

function intersect_exp_peaks_across_groups {
  for rep_num in $reps
  do 
    # todo: confirm macs2 naming convention. think its ${strand_direction}_${treatment}_${rep_num}_summits.bed
    # todo: figure out if need to keep separated by strands at this point
    # intersect_peaks correct usage: intersect_peaks <group A> <group B> <file A> <file B> <indir> <outdir>
    intersect_peaks_two "macs2/fRNaseH_${rep_num}_summits.bed" \
                        "macs2/fInput_${rep_num}_summits.bed" \

    intersect_peaks_two "macs2/rRNaseH_${rep_num}_summits.bed" \
                        "macs2/rInput_${rep_num}_summits.bed" \
  done
  # outputs to "filtered_peaks_${versus_A}-${versus_B}.bed"
}

function intersect_exp_peaks_across_reps {
    intersect_peaks_three 
      'forward' \
      "filtered_peaks_fRNaseH_1-fInput_1.bed" \
      "filtered_peaks_fRNaseH_2-fInput_2.bed" \
      "filtered_peaks_fRNaseH_3-fInput_3.bed" \
    #populates output/filtered_peaks_forward.bed

    intersect_peaks_three 
      'reverse' \
      "filtered_peaks_rRNaseH_1-rDRIP_1.bed" \
      "filtered_peaks_rRNaseH_2-rDRIP_2.bed" \
      "filtered_peaks_rRNaseH_3-rDRIP_3.bed" \
    #populates output/filtered_peaks_reverse.bed

}

function all_bam2bigwigs {

}

function all_bigwig_summaries {
  all_bam2bigwigs
}

function all_plot_correlations {

}

main # call main with command line input: main "$@" 
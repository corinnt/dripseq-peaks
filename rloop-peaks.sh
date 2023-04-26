#!/bin/bash
#export PATH="~/bin:$PATH"
export PATH=$PATH:~/Desktop/Spring_2023/drip-seq/tools

. preprocess.sh # include preprocess file, Posix compatible

TOOLS_PATH="~/desktop/spring_2023/drip-seq/tools" #to access JAR files
REPS={1..3}
TREATMENTS=('DRIP' 'RNaseH' 'Input')

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
    call_peaks 'DRIP' 'RNaseH' $rep_num "forward"
    call_peaks 'DRIP' 'RNaseH' $rep_num "reverse"

    call_peaks 'DRIP' 'Input' $rep_num "forward"
    call_peaks 'DRIP' 'Input' $rep_num "reverse"
  done
}

function intersect_exp_peaks_across_groups {
  for rep_num in $reps
  do 
    # todo: figure out macs2 naming convention. in meantime can use prefix? ${strand_direction}_${treatment}_${rep_num}
    # todo: figure out if need to keep separated by strands at this point
    # intersect_peaks correct usage: intersect_peaks <group A> <group B> <file A> <file B> <outdir>
    intersect_peaks 'fDRIP-RNaseH' 'fDRIP-Input' $rep_num "forward_RNaseH_${rep_num}.bam" "forward_Input_${rep_num}.bam" #forward
    intersect_peaks 'rDRIP-RNaseH' 'rDRIP-Input' $rep_num "reverse_RNaseH_${rep_num}.bam" "reverse_Input_${rep_num}.bam" #reverse
  done
}

#----------- cross-treatment functions-----------------#

# 6. MACs2 (v2.1.1) to call peaks of DRIP versus Input using broad peak settings, 
# 7. again calling with DRIP versus RNase H-treated DRIP
# https://hbctraining.github.io/Intro-to-ChIPseq/lessons/05_peak_calling_macs.html
function call_peaks {
  if [ $# != 4 ]; then
    echo  "call_peaks correct usage: call_peaks <treatment> <control> <rep num> <strand direction"
  fi 
  local treatment=$1
  local control=$2

  local rep_num=$3
  local strand_direction=$4 
  # DRIP.bam
  # DRIP_input.bam

  # protocol just specified -f BAMPE –g 1.4e+08 which would use bandwidth of 300, mfold of 5 50, -q of 0.05
  macs2 callpeak
  -t "intermed/${strand_direction}_${treatment}.bam" \
  -c "intermed/${strand_direction}_${control}.bam" \
  -f BAMPE -bw 250                                        # format, bandwidth
  -g dm -n "${strand_direction}_vs${control}_${rep_num}"  # genome size, name for files
  –mfold 10 30 -q 0.01                                    # mfold range, qvalue/minimum FDR for peak detection
  --outdir intermed/macs2 
  2> intermed/macs2/peak-log.log \
  --broad \
  
  echo "Peaks called for ${treatment} vs ${control} saved to intermed/macs2, rep num ${rep_num}"
}

# 8. BEDTools intersect to retain peaks present in both 
# 9. BEDTools to retain only peaks present in both replicates
# function to be called to compare across treatment groups and across replicates
function intersect_peaks{
  if [ $# != 5 ]; then
    echo  "intersect_peaks correct usage: intersect_peaks <group A> <group B> <file A> <file B> <outdir>"
  fi 
  local versus_A=$1
  local versus_B=$2
  local input_A_file=$3
  local input_B_file=$4
  local outdir=$5

  local output_bed="filtered_peaks_${versus_A}-${versus_B}.bed"

  cd $outdir
  touch $output_bed
  cd ..

  bedtools intersect 
  -a "intermed/${input_A_file}"
  -b "intermed/${input_B_file}" - u > "${outdir}/$output_bed" 

  echo "Peak intersect ${versus_A} vs ${versus_B} saved to ${output_bed}, rep ${rep_num}"
}
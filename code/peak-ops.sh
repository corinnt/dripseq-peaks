#!/bin/bash

# ----------- peak calling + intersection functions -------------- #

# 6. MACs2 (v2.1.1) to call peaks of DRIP versus Input using broad peak settings, 
# 7. again calling with DRIP versus RNase H-treated DRIP
# https://hbctraining.github.io/Intro-to-ChIPseq/lessons/05_peak_calling_macs.html
function call_peaks {
  if [ $# != 4 ]; then
    echo  "call_peaks correct usage: call_peaks <treatment> <control> <strand direction> <rep num> "
  fi 
  local treatment=$1
  local control=$2

  local strand_direction=$3
  local rep_num=$4

  # protocol just specified -f BAMPE –g 1.4e+08 which would use bandwidth of 300, mfold of 5 50, -q of 0.05
  macs2 callpeak
  -t "intermed/${strand_direction}_${treatment}.bam" \
  -c "intermed/${strand_direction}_${control}.bam" \
  -f BAMPE -bw 250                                        # format, bandwidth
  -g dm -n "${control}_${strand_direction}${rep_num}"  # genome size, name for files
  –mfold 10 30 -q 0.01                                    # mfold range, qvalue/minimum FDR for peak detection
  --outdir intermed/macs2
  2> intermed/macs2/peak-log.log \
  --broad \
  
  echo "Peaks called for ${treatment} vs ${control} saved to intermed/macs2/${control}_${strand_direction}${rep_num}_summits.bed"
}

# 8. BEDTools intersect to retain peaks present in both 
# function to be called to compare across treatment groups 
function intersect_peaks_two {
  if [ $# != 2 ] then 
    echo  "intersect_peaks_two correct usage: intersect_peaks <file A> <file B> <strand direction> <rep_num>"
  fi 

  local input_A_file=$1
  local input_B_file=$2
  local strand_direction=$3
  local rep_num=$4

  local output_bed="filtered_peaks_${direction}${rep}.bed"

  cd ../$outdir
  touch $output_bed
  cd ../code
  
  bedtools intersect 
    -a "intermed/${input_A_file}" \
    -b "intermed/${input_B_file}" - u \
    > "intermed/$output_bed"  

  echo "Peak intersect saved to ${output_bed}"
}

# 9. BEDTools to retain only peaks present in both replicates
# function to be called to compare across across replicates
intersect_peaks_three {
  if [ $# != 4 ] then 
    echo  "intersect_peaks_three correct usage: intersect_peaks <direction> <file A> <file B> <file C>"
  fi 

  local direction=$1
  local input_A_file=$2
  local input_B_file=$3
  local input_C_file=$4

  local output_bed="filtered_peaks_${direction}.bed"
  
  cd ../$outdir
  touch $output_bed
  cd ../code
  
  bedtools intersect 
    -a "intermed/${input_A_file}" \
    -b "intermed/${input_B_file}" "intermed/${input_C_file}" - u \
    > "output/$output_bed"  

    echo "Peak intersect across ${direction} replicates saved to ${output_bed}"
}
#!/bin/bash
export PATH="~/bin:$PATH"

TOOLS_PATH="~/desktop/spring_2023/drip-seq/tools"
#TREAT=NONE
#REP=0
REPS={1..3}
TREATMENTS=('DRIP' 'RNaseH' 'Input')

#------------- abstracted experiment-specific calls ----------------------#
function preprocess_across_treatments{
  for treatment in "${TREATMENTS[@]}"
  do 
    trim_adaptors_across_replicates $treatment
    align_reads_across_replicates $treatment
    sam2bam_across_replicates $treatment
    mark_duplicates_across_replicates $treatment
  done
}

function call_peaks{


}
#------------ per-treatment, preprocessing functions -----------------#
# Given a treatment, trims adaptors across the 3 replicates in that treatment 
function trim_adaptors_across_replicates{
  local treatment=$1
  for rep_num in $reps
  do 
    trim_adaptors $treatment $rep_num data
  done
}
# Given a treatment, aligns paired reads across the 3 replicates in that treatment 
function align_reads_across_replicates{
  local treatment=$1
  for rep_num in 1 2 3
  do 
    #todo: need to align unpaired as well?
    align_reads $treatment $rep_num "forward_pair_${treatment}_${rep_num}.sam" "reverse_pair_${treatment}_${rep_num}.sam"
  done
}

function sam2bam_across_replicates{
  local treatment=$1
  for rep_num in 1 2 3
  do 
    sam2sorted_bam $treatment $rep_num "forward_pair_${treatment}_${rep_num}.sam"
    sam2sorted_bam $treatment $rep_num "reverse_pair_${treatment}_${rep_num}.sam"
  done
}

function mark_duplicates_across_replicates{
  local treatment=$1
  for rep_num in 1 2 3
  do 
    mark_duplicates $treatment $rep_num forward_pair
    mark_duplicates $treatment $rep_num reverse_pair
  done
}
#--------------------- protocol per-step functions -----------------------#

# 1. trim adaptors + remove low-quality reads w Trimmomatic 
# fq.gz files are FASTQ compressed with GZIP
function trim_adaptors {
  # was this ussing chipSEQ steps 1-3?
  #  ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:2:True
  # two input files are specified (of type gzipp'ed FASTQ fq.gz), and 4 output files, 
  # 2 for the 'paired' output where both reads survived the processing,
  # and 2 for corresponding 'unpaired' output where a read survived, but the partner read did not.
  local treatment=$1
  local rep_num=$2
  local data_dir=$3

  local in_forward_file="${data_dir}/${treatment}_forw_${rep_num}"
  local in_reverse_file="${data_dir}/${treatment}_rev_${rep_num}"

  cd intermed
  tags=("forward_pair" "forward_unpair" "reverse_pair" "reverse_unpair")
  for tag in "${tags[@]}"
  do 
    touch "${tag}_${treatment}_${rep_num}.fq.gz"
  done
  cd ..
  
  local reverse_unpair_path="intermed/reverse_unpair_${treatment}_${rep_num}"
  local out_forward_pair="intermed/forward_pair_${treatment}_${rep_num}"
  local forward_unpair_path="intermed/forward_unpair_${treatment}_${rep_num}"
  local reverse_pair_path="intermed/reverse_pair_${treatment}_${rep_num}"

  #to use trimmomatic
  java -jar "${TOOLS_PATH}/Trimmomatic-0.39/trimmomatic-0.39.jar" PE -phred33 \
  "$in_forward_file" "$in_reverse_file" \
  "$out_forward_pair_path" "$out_forward_unpair_path" \
  "$out_reverse_pair_path" "$out_forward_unpair_path" \
  ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 \
  LEADING:3 \
  TRAILING:3 \
  SLIDINGWINDOW:4:15 \
  MINLEN:36
  # TODO: check steps
  echo "Adaptors trimmed from ${in_forward_file} and ${in_reverse_file}, ${treatment}, ${rep_num}"
}

# 2. align reads to drosophila w/ bowtie2 (v 2.3.1)
function align_reads {
  # might want to include -no-discordant
  # this is currently using relative path of 
  local treatment=$1
  local rep_num=$2
  local forward_reads_path=$3
  local reverse_reads_path=$4

  cd intermed
  touch "aligned_${treatment}_${rep_num}.sam"
  cd ..

  local output_sam_path="intermed/aligned_${treatment}_${rep_num}.sam"

  bowtie2 -x "BDGP6" \
  -1 "$forward_reads_path" \
  -2 "$reverse_reads_path" \
  -fr -no-mixed --no-unal \
  -S "$output_sam_path"

  echo "Reads aligned for ${forward_reads_path} and ${reverse_reads_path}; ${treatment}, ${rep_num}"
}

# 3. Samtools to convert SAM → BAM; 
#    Sort BAM files
#    Index BAM files; writes to 
# http://www.htslib.org/doc/samtools-index.html
function sam2sorted_bam {
  local treatment=$1
  local rep_num=$2
  local in_sam=$3

  local out_sorted_bam="sorted_bam_${treatment}_${rep_num}.bam"
  local index_bai="index_${treatment}_${rep_num}.bai"

  temp_out_bam=$(mktemp)

  samtools view -b "$in_sam" > $temp_out_bam
  samtools sort $temp_out_bam -o "$out_sorted_bam"
  samtools index "$out_sorted_bam" -o "$index_bai"

  rm $temp_out_bam
  echo "SAM ${in_sam} to sorted + indexed BAM; ${treatment}, ${rep_num}"
}

# 4. Picard to mark duplicates to filter PCR duplicates
# http://broadinstitute.github.io/picard/
# java -jar ~/desktop/spring_2023/drip-seq/tools/picard.jar -h
function mark_duplicates{
  #TODO
  local treatment=$1
  local rep_num=$2
  local input_tag=$3

  local input_bam="${input_tag}_${treatment}_${rep_num}.bam"
  cd intermed
  touch "marked_duplicates_${input_tag}_${treatment}_${rep_num}.bam"
  touch "marked_dup_metrics_${input_tag}_${treatment}_${rep_num}.txt"
  cd ..

  local marked_duplicates="marked_duplicates_${treatment}_${rep_num}.bam"
  local marked_dup_metrics="marked_dup_metrics_${treatment}_${rep_num}.txt"

  java -jar "${TOOLS_PATH}/picard.jar" MarkDuplicates \
      I="$input_bam" \
      O="$marked_duplicates" \
      M="$marked_dup_metrics"

  echo "Duplicates marked in ${input_bam}; ${treatment}, ${rep_num}"
}
# 5. generate strand-specific BAM files 
function strand_specific_bam{ 
  #numbers following view -f are bitflags to filter by
  local treatment=$1
  local rep_num=$2
  local in_bam=$3

  local out_forward="out_forward_${in_bam}.bam"
  local out_reverse="out_reverse_${in_bam}.bam"

  temp_forward99=$(mktemp)
  temp_forward147=$(mktemp)
  temp_reverse83=$(mktemp)
  temp_reverse163=$(mktemp)

  #forward strand: 
  samtools view -f 99 "$in_bam" -o $temp_forward99
  samtools view -f 147 "$in_bam" -o $temp_forward147
  samtools merge -o "$out_forward" $temp_forward99 $temp_forward147

  #reverse strand: 
  samtools view -f 83 "$in_bam" -o $temp_reverse83
  samtools view -f 163 "$in_bam" -o $temp_reverse163
  samtools merge -o "$out_reverse" $temp_reverse83 $temp_reverse163

  rm $temp_forward99
  rm $temp_forward147
  rm $temp_reverse83
  rm $temp_reverse163

  echo "Strand-specific BAM files generated for ${in_bam};  ${treatment}, ${rep_num}"
}

# 6. MACs2 (v2.1.1) to call peaks of DRIP versus Input using broad peak settings, 
# 7. again calling with DRIP versus RNase H-treated DRIP
# https://hbctraining.github.io/Intro-to-ChIPseq/lessons/05_peak_calling_macs.html
function call_peaks {
  local treatment=$1
  local control=$2
  local rep_num=$3
  local treatment_path=$4 # DRIP.bam
  local control_path=$5   # DRIP_input.bam

  macs2 callpeak
  -t "$treatment_path" \
  -c "$control_path" \
  -f BAMPE -g 1.4e+08 -n DRIP
  --outdir intermed/macs2 
  2> intermed/macs2/peak-log.log \
  --broad \
  
  echo "Peaks called for ${treatment} vs ${control} saved to intermed/macs2, rep num ${rep_num}"
}

# 8. BEDTools intersect to retain peaks present in both 
# 9. BEDTools to retain only peaks present in both replicates
# function to be called to compare across treatment groups and across replicats
function intersect_peaks{
  local versus_A=$1
  local versus_B=$2
  local input_A_path=$3
  local input_B_path=$4
  local rep_num=$5
  local output_bed="output/intersect_peaks_${versus_A}-${versus_B}_${rep_num}.bed"

  bedtools intersect 
  -a "$input_A_path"
  -b "$input_B_path" - u > "$output_bed" 

  echo "Peak intersect ${versus_A} vs ${versus_B} saved to ${output_bed}, rep #${rep_num}"
}
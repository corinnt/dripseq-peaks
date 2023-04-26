#!/bin/bash
#export PATH="~/bin:$PATH"
export PATH=$PATH:~/Desktop/Spring_2023/drip-seq/tools

TOOLS_PATH="~/desktop/spring_2023/drip-seq/tools" #to access JAR files
REPS={1..3}
TREATMENTS=('DRIP' 'RNaseH' 'Input')

#------------- abstracted experiment-specific calls ----------------------#
function preprocess_across_treatments{
  for treatment in "${TREATMENTS[@]}"
  do 
    trim_adaptors_across_reps $treatment
    align_reads_across_reps $treatment
    sam2sorted_bam_across_reps $treatment
    mark_duplicates_across_reps $treatment
    strand_specific_bam_across_reps $treatment
  done
}

function call_exp_peaks{
  # TODO: unhardcode
  for rep_num in $reps
  do 
    call_peaks 'DRIP' 'RNaseH' $rep_num "forward"
    call_peaks 'DRIP' 'RNaseH' $rep_num "reverse"

    call_peaks 'DRIP' 'Input' $rep_num "forward"
    call_peaks 'DRIP' 'Input' $rep_num "reverse"
  done
}

function intersect_exp_peaks_across_groups{
  for rep_num in $reps
  do 
    # todo: figure out macs2 naming convention. in meantime can use prefix? ${strand_direction}_${treatment}_${rep_num}
    # todo: figure out if need to keep separated by strands at this point
    # intersect_peaks correct usage: intersect_peaks <group A> <group B> <file A> <file B> <outdir>
    intersect_peaks 'fDRIP-RNaseH' 'fDRIP-Input' $rep_num "forward_RNaseH_${rep_num}.bam" "forward_Input_${rep_num}.bam" #forward
    intersect_peaks 'rDRIP-RNaseH' 'rDRIP-Input' $rep_num "reverse_RNaseH_${rep_num}.bam" "reverse_Input_${rep_num}.bam" #reverse
  done
}
#------------ per-treatment, preprocessing functions -----------------#
# Given a treatment, trims adaptors across the 3 replicates in that treatment 
function trim_adaptors_across_reps{
  local treatment=$1
  for rep_num in $reps
  do 
    trim_adaptors $treatment $rep_num "data"
  done
}
# Given a treatment, aligns paired reads across the 3 replicates in that treatment 
# Creates per rep "intermed/aligned_${treatment}_${rep_num}.sam"
function align_reads_across_reps{
  local treatment=$1
  for rep_num in $reps
  do 
    #todo: need to align unpaired as well?
    align_reads $treatment $rep_num "forward_pair_${treatment}_${rep_num}.sam" "reverse_pair_${treatment}_${rep_num}.sam"
  done
}

function sam2sorted_bam_across_reps{
  local treatment=$1
  for rep_num in $reps
  do 
    sam2sorted_bam $treatment $rep_num "aligned_${treatment}_${rep_num}.sam"
  done
}

function mark_duplicates_across_reps{
  local treatment=$1
  for rep_num in $reps
  do 
    mark_duplicates $treatment $rep_num "sorted_${treatment}_${rep_num}.bam"
  done
}

function strand_specific_bam_across_reps{
  local treatment=$1
  for rep_num in $reps
  do 
    strand_specific_bam $treatment $rep_num "marked_duplicates_${treatment}_${rep_num}.bam"
  done
}

#--------------------- protocol per-step functions -----------------------#

# 1. trim adaptors + remove low-quality reads w Trimmomatic 
# fq.gz files are FASTQ compressed with GZIP
function trim_adaptors {
  #  ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:2:True
  # two input files are specified (of type gzipp'ed FASTQ fq.gz), and 4 output files, 
  # 2 for the 'paired' output where both reads survived the processing,
  # and 2 for corresponding 'unpaired' output where a read survived, but the partner read did not.
  if [ $# != 3 ]; then
    echo  "trim_adaptors correct usage: trim_adaptors <treatment> <rep_num> <data_dir>"
  fi 
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
  if [ $# != 4 ]; then
    echo  "align_reads correct usage: align_reads <treatment> <rep_num> <forward_reads_file> <reverse_reads_file>"
  fi 
  local treatment=$1
  local rep_num=$2

  local forward_reads_file=$3
  local reverse_reads_file=$4

  local output_sam_path="intermed/aligned_${treatment}_${rep_num}.sam"
  cd intermed
  touch "$output_sam_path"
  cd ..

  bowtie2 -x "BDGP6" \
  -1 "intermed/${forward_reads_file}" \
  -2 "intermed/${reverse_reads_file}" \
  -fr -no-mixed --no-unal \
  -S "$output_sam_path"
  #-S File to write SAM alignments to

  echo "Reads aligned for ${forward_reads_file} and ${reverse_reads_file}; ${treatment}, ${rep_num}"
}

# 3. Samtools to convert SAM → BAM; 
#    Sort BAM files
#    Index BAM files; writes to 
# http://www.htslib.org/doc/samtools-index.html
function sam2sorted_bam {
  if [ $# != 3 ]; then
    echo  "sam2sorted_bam correct usage: sam2sorted_bam <treatment> <rep_num> <input_sam>"
  fi 
  local treatment=$1
  local rep_num=$2
  local in_sam=$3

  local out_sorted_bam="sorted_${treatment}_${rep_num}.bam"
  local index_bai="indexed_${treatment}_${rep_num}.bai"
  cd intermed
  touch "${out_sorted_bam}"
  touch "${index_bai}"
  cd ..

  temp_out_bam=$(mktemp)

  samtools view -b "intermed/$in_sam" > $temp_out_bam
  samtools sort $temp_out_bam -o "intermed/$out_sorted_bam"
  samtools index "intermed/$out_sorted_bam" -o "intermed/$index_bai"

  rm $temp_out_bam
  echo "SAM ${in_sam} to sorted + indexed BAM; ${treatment}, ${rep_num}"
}

# 4. Picard to mark duplicates to filter PCR duplicates
# http://broadinstitute.github.io/picard/
# java -jar ~/desktop/spring_2023/drip-seq/tools/picard.jar -h
function mark_duplicates{
  if [ $# != 3 ]; then
    echo  "mark_duplicates correct usage: mark_duplicates <treatment> <rep_num> <input_bam>"
  fi 
  local treatment=$1
  local rep_num=$2
  local input_bam=$3

  local marked_duplicates="marked_duplicates_${treatment}_${rep_num}.bam"
  local marked_dup_metrics="marked_dup_metrics_${treatment}_${rep_num}.txt"
  cd intermed
  touch "$marked_duplicates"
  touch "$marked_dup_metrics"
  cd ..

  java -jar "${TOOLS_PATH}/picard.jar" MarkDuplicates \
      I="$input_bam" \
      O="$marked_duplicates" \
      M="$marked_dup_metrics"

  echo "Duplicates marked in ${input_bam}; ${treatment}, ${rep_num}"
}
# 5. generate strand-specific BAM files 
function strand_specific_bam{ 
  if [ $# != 3 ]; then
    echo  "strand_specific_bam correct usage: strand_specific_bam <treatment> <rep_num> <input_bam>"
  fi 
  local treatment=$1
  local rep_num=$2
  local in_bam=$3

  local out_forward="forward_${treatment}_${rep_num}.bam"
  local out_reverse="reverse_${treatment}_${rep_num}.bam"
  cd intermed
  touch "$out_forward"
  touch "$out_reverse"
  cd ..

  temp_forward99=$(mktemp)
  temp_forward147=$(mktemp)
  temp_reverse83=$(mktemp)
  temp_reverse163=$(mktemp)

  # numbers following view -f are bitflags to filter by

  # forward strand: 
  samtools view -f 99 "$in_bam" -o $temp_forward99
  samtools view -f 147 "$in_bam" -o $temp_forward147
  samtools merge -o "intermed/${out_forward}" $temp_forward99 $temp_forward147

  #reverse strand: 
  samtools view -f 83 "$in_bam" -o $temp_reverse83
  samtools view -f 163 "$in_bam" -o $temp_reverse163
  samtools merge -o "intermed/${out_reverse}" $temp_reverse83 $temp_reverse163

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
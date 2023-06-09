#!/bin/bash

DM6_PATH = "/gpfs/data/shared/databases/refchef_refs/drosophila-melanogaster-bdgp6rel9/bowtie2_index_2_3_0"

#---------------- preprocessing functions to be performed on all files -----------------------#

# 1. trim adaptors + remove low-quality reads w Trimmomatic 
# fq.gz files are FASTQ compressed with GZIP
function trim_adaptors {
  #  ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:2:True
  # two input files are specified (of type gzipp'ed FASTQ fq.gz), and 4 output files, 
  # 2 for the 'paired' output where both reads survived the processing,
  # and 2 for corresponding 'unpaired' output where a read survived, but the partner read did not.
  if [ $# != 4 ]; then
    echo  "trim_adaptors correct usage: trim_adaptors <treatment> <rep_num> <in_forward_file> <in_reverse_file>"
  fi 
  local treatment=$1
  local rep_num=$2
  local in_forward_file="data/${in_forward_file}"
  local in_reverse_file="data/${in_reverse_file}"

  cd ../intermed
  tags=("forward_pair" "forward_unpair" "reverse_pair" "reverse_unpair")
  for tag in "${tags[@]}"
  do 
    touch "${tag}_${treatment}_${rep_num}.fq.gz"
  done
  cd ../code
  
  local reverse_unpair_path="intermed/reverse_unpair_${treatment}_${rep_num}.fq.gz"
  local out_forward_pair="intermed/forward_pair_${treatment}_${rep_num}.fq.gz"
  local forward_unpair_path="intermed/forward_unpair_${treatment}_${rep_num}.fq.gz"
  local reverse_pair_path="intermed/reverse_pair_${treatment}_${rep_num}.fq.gz"

  #to use trimmomatic
  java -jar "Trimmomatic-0.39/trimmomatic-0.39.jar" PE -phred33 \
  "$in_forward_file" "$in_reverse_file" \
  "$out_forward_pair_path" "$out_forward_unpair_path" \
  "$out_reverse_pair_path" "$out_forward_unpair_path" \
  ILLUMINACLIP:TruSeq3-PE.fa:2:30:15 \
  # LEADING:3 \ not included in GenPipes
  TRAILING:30 \
  #SLIDINGWINDOW:4:15 \
  MINLEN:50
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
  cd ../intermed
  touch "$output_sam_path"
  cd ../code

  bowtie2 -x $DM6_PATH \
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

  cd ../intermed
  touch "${out_sorted_bam}"
  touch "${index_bai}"
  cd ../code

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
function mark_duplicates {
  if [ $# != 3 ]; then
    echo  "mark_duplicates correct usage: mark_duplicates <treatment> <rep_num> <input_bam>"
  fi 
  local treatment=$1
  local rep_num=$2
  local input_bam=$3

  local marked_duplicates="marked_duplicates_${treatment}_${rep_num}.bam"
  local marked_dup_metrics="marked_dup_metrics_${treatment}_${rep_num}.txt"
  cd ../intermed
  touch "$marked_duplicates"
  touch "$marked_dup_metrics"
  cd ../code

  java -jar "${TOOLS_PATH}/picard.jar" MarkDuplicates \
      I="$input_bam" \
      O="$marked_duplicates" \
      M="$marked_dup_metrics"

  echo "Duplicates marked in ${input_bam}; ${treatment}, ${rep_num}"
}

# 5. generate strand-specific BAM files 
function strand_specific_bam { 
  if [ $# != 3 ]; then
    echo  "strand_specific_bam correct usage: strand_specific_bam <treatment> <rep_num> <input_bam>"
  fi 
  local treatment=$1
  local rep_num=$2
  local in_bam=$3

  local out_forward="forward_${treatment}_${rep_num}.bam"
  local out_reverse="reverse_${treatment}_${rep_num}.bam"
  cd ../intermed
  touch "$out_forward"
  touch "$out_reverse"
  cd ../code

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
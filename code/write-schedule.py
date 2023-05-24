import sys

def main(treatments, reps):
    """
    Outputs the cluster pattern in terminal and writes graphviz graph to given dot file

    Parameters: 
        :param treatments: tuple of strings - all treatment groups (ie 'RNasH, DRIP, Input)
        :param reps: int - number of replicates for each treatment

    Returns: NA

    Side affects: 
    Writes 
    """
    write("#!/bin/bash")

    preprocess(treatments, reps) 
    call_exp_peaks(reps)
  
    intersect_exp_peaks_across_groups()
    intersect_exp_peaks_across_reps()

def write(text, newline=True):
    with open('batch-script.sh', mode='wt') as script:
        if newline: text += "\n"
        script.write(text)

def preprocess(treatments, reps):
  for treatment in treatments:
      # these functions will need to be converted to writing the commands for each rep to call trim_adaptors, etc
    trim_adaptors_across_reps(treatment, reps) 
    align_reads_across_reps(treatment, reps)
    sam2sorted_bam_across_reps(treatment, reps)
    mark_duplicates_across_reps(treatment, reps)
    strand_specific_bam_across_reps(treatment, reps)

def call_exp_peaks(reps):
    # TODO: unhardcode controls
    directions = ('f, r')
    controls = ('RNaseH', 'Input')
    for rep in range(reps):
        for direction in directions:
            for control in controls:
                command = ". peak-ops.sh; call_peaks 'DRIP' " + control + " " + rep + " " + direction
                write(command)
                
def intersect_exp_peaks_across_groups(reps):
    # todo: confirm macs2 naming convention. think its ${strand_direction}_${treatment}_${rep_num}_summits.bed
    # intersect_peaks usage: intersect_peaks <group A> <group B> <file A> <file B> <indir> <outdir>
    directions = ('f, r')
    controls = ('RNaseH', 'Input')
    for rep in range(reps):
        for direction in directions:
            command = ". peak-ops.sh; intersect_peaks_two"
            write(command, newline=False)
            for control in controls:
                file = "macs2/" + direction + control + "_" + rep + "_summits.bed"
                write(file, newline=False)
            write("")
    # outputs to "filtered_peaks_${versus_A}-${versus_B}.bed"

def intersect_exp_peaks_across_reps():
    #TODO: FIX / CONVERT
    intersect_peaks_three('forward', 
      "filtered_peaks_fRNaseH_1-fInput_1.bed", 
      "filtered_peaks_fRNaseH_2-fInput_2.bed", 
      "filtered_peaks_fRNaseH_3-fInput_3.bed")
    #populates output/filtered_peaks_forward.bed

    intersect_peaks_three('reverse', 
      "filtered_peaks_rRNaseH_1-rDRIP_1.bed", 
      "filtered_peaks_rRNaseH_2-rDRIP_2.bed", 
      "filtered_peaks_rRNaseH_3-rDRIP_3.bed")
    #populates output/filtered_peaks_reverse.bed

#------------ per-treatment, preprocessing functions -----------------#
# Given a treatment, trims adaptors across the 3 replicates in that treatment 

def trim_adaptors_across_reps(treatment, reps):
  for rep in reps:
    forward_file = "forward_" + treatment + "_" + rep + ".fq.gz"
    reverse_file = "reverse_" + treatment + "_" + rep + ".fq.gz"
    command = ". preprocess.sh; trim_adaptors " + treatment + " " + rep + " " + forward_file + " " + reverse_file
    write(command)
        #trim_adaptors treatment rep_num forward_file reverse_file

# Given a treatment, aligns paired reads across the 3 replicates in that treatment 
# Creates per rep "intermed/aligned_${treatment}_${rep_num}.sam"
def align_reads_across_reps(treatment, reps):
  for rep in range(reps):
    file_suffix = "_pair_" + treatment + "_" + rep + ".sam"
    command = ". preprocess.sh; align_reads " + treatment + " " + rep + " forward" + file_suffix + " reverse" + file_suffix
    write(command)

def sam2sorted_bam_across_reps(treatment, reps):
  for rep in range(reps):
      file = "aligned_" + treatment + "_" + rep + ".sam"
      command = ". preprocess.sh; sam2sorted_bam " + treatment + " " + rep + " " + file
      write(command)


def mark_duplicates_across_reps(treatment, reps):
    for rep in reps:
        file = "sorted_" + treatment + "_" + rep + ".bam"
        command = ". preprocess.sh; mark_duplicates " + treatment + " " + rep + " " + file
        write(command)

def strand_specific_bam_across_reps(treatment, reps):
    for rep in range(reps):
        file = "marked_duplicates_" + treatment + "_" + rep + ".bam"
        command = ". preprocess.sh; strand_specific_bam " + treatment + " " + rep + " " + file
        write(command)

        
if __name__ == "__main__":
    reps : int = open(sys.argv[1],'r').readlines()
    treatments = ('DRIP', 'RNaseH', 'Input')
    #treatments = sys.argv[2]
    main(reps, treatments)
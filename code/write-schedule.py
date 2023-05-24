import sys

def main(reps, treatments):
    """
    Outputs the cluster pattern in terminal and writes graphviz graph to given dot file

    Parameters: 
        :param reps: int of number of replicates of each treatment
        :param treatments: tuple of strings of all treatment groups (ie 'RNasH, DRIP, Input)

    Returns: NA

    Side affects: 
    Writes 
    """
    with open ('batch-script.sh', mode='wt') as script:
        script.write("#!/bin/bash")

    preprocess() 
    call_exp_peaks()
  
    intersect_exp_peaks_across_groups()
    intersect_exp_peaks_across_reps()


def preprocess(treatments):
  for treatment in treatments:
      # these functions will need to be converted to writing the commands for each rep to call trim_adaptors, etc
    trim_adaptors_across_reps(treatment) 
    align_reads_across_reps(treatment)
    sam2sorted_bam_across_reps(treatment)
    mark_duplicates_across_reps(treatment)
    strand_specific_bam_across_reps(treatment)

def call_exp_peaks(reps):
  # TODO: unhardcode
  for rep in range(reps):
    call_peaks('DRIP','RNaseH', rep, 'f')
    call_peaks('DRIP', 'RNaseH', rep, 'r')

    call_peaks('DRIP', 'Input', rep, 'f')
    call_peaks('DRIP', 'Input',rep, 'r')

def intersect_exp_peaks_across_groups(reps):
  for rep_num in range(reps):
    # todo: confirm macs2 naming convention. think its ${strand_direction}_${treatment}_${rep_num}_summits.bed
    # todo: figure out if need to keep separated by strands at this point
    # intersect_peaks correct usage: intersect_peaks <group A> <group B> <file A> <file B> <indir> <outdir>
    intersect_peaks_two("macs2/fRNaseH_${rep_num}_summits.bed", 
                        "macs2/fInput_${rep_num}_summits.bed")

    intersect_peaks_two("macs2/rRNaseH_${rep_num}_summits.bed", 
                        "macs2/rInput_${rep_num}_summits.bed")
  # outputs to "filtered_peaks_${versus_A}-${versus_B}.bed"

def intersect_exp_peaks_across_reps():
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


        
if __name__ == "__main__":
    reps : int = open(sys.argv[1],'r').readlines()
    treatments = sys.argv[2]
    main(reps, treatments)
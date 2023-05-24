import sys

def main(treatments, reps):
    """
    Outputs the cluster pattern in terminal and writes graphviz graph to given dot file

    Parameters: 
        :param treatments: tuple of strings - all treatment groups (ie 'RNasH, DRIP, Input)
        :param reps: list of strings - range of replicate numbers for each treatment

    Side effects: 
        Writes all bash commands for analysis to batch-script.sh
    """
    controls = ('RNaseH', 'Input') #TODO: unhardcode
    with open('batch-script.sh', mode='wt') as script:
        script.write("#!/bin/bash\n")

    preprocess(treatments, reps) 
    call_exp_peaks(controls, reps)
    intersect_peaks_across_groups(controls, reps)
    intersect_peaks_across_reps(reps)

def write(command, comment=None, newline=True):
    """ Writes command to batch-script.sh with optional comment and following newline
        :param command: string - text to write to script
        :param comment: string - optional text to follow command; formatting "# comment...." included
        :param newline: bool - optional newline after both command and opt comment; defaults to yes newline
    """
    with open('batch-script.sh', mode='a') as script:
        if comment: command += "\n# " + comment
        if newline: command += "\n"
        script.write(command)

def preprocess(treatments, reps):
    """ Preprocesses all FASTQ files by treatment
        :param treatments: tuple of strings - all treatment groups (ie 'RNasH, DRIP, Input)
        :param reps: int - number of replicates for each treatment
    """
    for treatment in treatments:
        trim_adaptors_across_reps(treatment, reps) 
        align_reads_across_reps(treatment, reps)
        sam2sorted_bam_across_reps(treatment, reps)
        mark_duplicates_across_reps(treatment, reps)
        strand_specific_bam_across_reps(treatment, reps)
        write("", comment="Preprocessed treatment " + treatment + ".\n")

def call_exp_peaks(controls, reps):
    """ Calls peaks of DRIP vs RNaseH and DRIP vs Input
        :param controls: tuple of controls being compared with DRIP
        :param reps: int - number of replicates for each treatment
    """
    directions = ('f', 'r')
    for rep in reps:
        for direction in directions:
            for control in controls:
                command = ". peak-ops.sh; call_peaks 'DRIP' " + control + " " + rep + " " + direction
                comment = "Writes to intermed/macs2/" + direction + control + "_" + rep + "_summits.bed"
                write(command, comment=comment)
    write("", comment="Experiment peaks called.\n")
                
def intersect_peaks_across_groups(controls, reps):
    """ Intersects peaks between DRIP vs control 1 and DRIP vs control 2
        :param controls: tuple of controls being compared with DRIP
        :param reps: int - number of replicates for each group

        NOTE: intersect_peaks usage: intersect_peaks_two <file A> <file B>
    """
    # todo: confirm macs2 naming convention. think its ${strand_direction}_${treatment}_${rep_num}_summits.bed
    directions = ('f', 'r')
    for rep in reps:
        for direction in directions:
            command = ". peak-ops.sh; intersect_peaks_two "
            comment = "Writes to filtered_peaks_"
            for control in controls:
                file = "macs2/" + direction + control + "_" + rep + "_summits.bed"
                command += file + " "
                comment += direction + control + "_" + rep + "-"
            write(command, comment = comment[0:-1] + ".bed")
    # outputs to "filtered_peaks_${versus_A}-${versus_B}.bed"
    write("", comment="Peaks intersected across groups.\n")

def intersect_peaks_across_reps(reps):
    """ Intersects peaks between across replicates with same variables. 
        Results in final two BED files in output/ directory.
        :param reps: int - number of replicates for each group
    """
    for direction in ("forward", "reverse"):
        command = ". peak-ops.sh; intersect_peaks_three " + direction
        for rep in reps:
            direct = direction[0]
            file =  " filtered_peaks_" + direct + "RNaseH_" + rep +  "-" + direct + "Input_" + rep + ".bed"
            command += file
        comment = "Writes to output/filtered_peaks_" + direction + ".bed"
        write(command, comment=comment)
    write("", comment="Peaks intersected across replicates.\n")

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
  for rep in reps:
    file_suffix = "_pair_" + treatment + "_" + rep + ".sam"
    command = ". preprocess.sh; align_reads " + treatment + " " + rep + " forward" + file_suffix + " reverse" + file_suffix
    write(command)

def sam2sorted_bam_across_reps(treatment, reps):
  for rep in reps:
      file = "aligned_" + treatment + "_" + rep + ".sam"
      command = ". preprocess.sh; sam2sorted_bam " + treatment + " " + rep + " " + file
      write(command)


def mark_duplicates_across_reps(treatment, reps):
    for rep in reps:
        file = "sorted_" + treatment + "_" + rep + ".bam"
        command = ". preprocess.sh; mark_duplicates " + treatment + " " + rep + " " + file
        write(command)

def strand_specific_bam_across_reps(treatment, reps):
    for rep in reps:
        file = "marked_duplicates_" + treatment + "_" + rep + ".bam"
        command = ". preprocess.sh; strand_specific_bam " + treatment + " " + rep + " " + file
        write(command)

        
if __name__ == "__main__":
    rep_range = range(int(sys.argv[1]))
    reps = [str(num + 1) for num in rep_range]
    treatments = ('DRIP', 'RNaseH', 'Input')
    #treatments = sys.argv[2]
    main(treatments, reps)
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

    functions()
        

    

if __name__ == "__main__":
    reps : int = open(sys.argv[1],'r').readlines()
    treatments = sys.argv[2]
    main(reps, treatments)
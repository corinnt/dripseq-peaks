# Pipeline to identify R-loop peaks from DRIP-seq data

*Work in progress! BIOL1960 Independent Study project under Dr. Erica Larschan*
## Table of Contents

[To-Do](https://github.com/corinnt/dripseq-peaks#to-do)

[Use Instructions](https://github.com/corinnt/dripseq-peaks#use-instructions)

[Environment and Dependencies Info](https://github.com/corinnt/dripseq-peaks#environment-and-dependencies-info)

[Workflow Illustration](https://github.com/corinnt/dripseq-peaks#workflow-illustration-in-progress)


## To-Do:


**Dependency Management and Oscar Compatibility**
- compile `bedtools` and `samtools` from source
- confirm Oscar will be able to use -x64 rosetta environment
- finish SLURM batch script for Oscar
- finish Oscar README use instructions
- check if Oscar already has commandline tools

**Next Directions**
- test on data from original paper [RNA-DNA strand exchange by the Drosophila Polycomb complex PRC2](https://www.nature.com/articles/s41467-020-15609-x)
- workflow visualization for README
- visualization calls in `main`

**Complete**
- compile documentation on packages and tools
- individual package functions/operations
- find package JAR files, executables, and bioconda availabilities
- develop abstraction scheme
- fix `.gitignore`
- figure out how to create conda env w/ x86-64 arch 
- look into Oscar compatability
- finish parsing input and intermediate files for `mark_duplicates`
- add deepTools to conda env
- finish preprocessing calls to `align_reads`, convert SAM to sorted BAM, and mark PCR duplicates
- finish call peaks between treatments
- finish function to intersect peaks across replicates
- General use instructions for Oscar
- deal with discrepancy between the protocol and the paper for macs2 settings -> using the more restrictive/detailed paper settings
- for Picard `mark_duplicates`, `REMOVE_DUPLICATES` or `REMOVE_SEQUENCING_DUPLICATES` or none at all? -> none
- decide between using GenPipes or Trimmomatic to trim adaptors and perform quality control -> Trimmomatic 
- how to get FASTA files for adapter trimming? -> TruSeq3-PE.fa
- replicate peak visualizations w/ deepTools multiBigwigSummary and plotCorrelation (Pearson)


## Use Instructions:
The script assumes 3 replicates `REPS={1..3}` and treatments `TREATMENTS=('DRIP' 'RNaseH' 'Input')`. 

### On Local Machine: 

1. Activate the virtual environment `rloops-x64`

&nbsp;&nbsp;&nbsp;&nbsp;  For first time set-up, run `conda env create -f rloops-x64.yml` in terminal

&nbsp;&nbsp;&nbsp;&nbsp;  Otherwise, run `conda activate rloops-x64` in terminal

2. Input data should be placed in data/ directory with the following naming convention:

    forward_< treament >_< replicate number >

    reverse_< treament >_< replicate number >

&nbsp;&nbsp;&nbsp;&nbsp; ex) forward_DRIP_1.fq.gz, reverse_DRIP_1.fq.gz

If different file names are preferred, this pattern can be changed in the `preprocess.sh` file in `trim_adaptors_across_reps`. 

3. Uncomment 3 line of `/code/rloop-peaks.sh` (adds /tools directory to system path variable - not needed for Oscar)

`export PATH=$PATH:~/<path>/<path>/drip-seq/tools`

3. Run from inside the `drip-seq` directory:

    `./rloop-peaks.sh` 


### On Oscar, Brown's shared compute cluster:
*These directions are still a work in progress.*
1. Use `ssh` to connect to connect to Oscar:
<!--- Make code --->
    ssh <username>@ssh.ccv.brown.edu


2. Copy over the `drip-seq` directory from your computer to Oscar in order to make the FASTQ files, script, and environment available:

Method 1:

In Finder, `cmd-K` to open the **Connect to Server** window.

Enter `smb://smb.ccv.brown.edu/home/<username>` and press **Connect**.




Method 2:
<!--- Make code --->
    scp -r /path/to/source/file <username>@ssh.ccv.brown.edu:/path/to/destination/file

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; the `-r` flag is for recursive, so it will copy over the subdirectories and files inside the folder.


3. Load the `anaconda` module from Oscar:
<!--- This might be module load anaconda/3-5.2.0 if this (recommended) version doesn't work --->
    module load anaconda/2022.05 

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; If this is the first time you've loaded anaconda, first run:

    conda init bash

<!--- TODO --->

4. Add the `/tools` directory to the environment variable:
<!--- Make code --->
    export my_variable=my_value
Or is this what's at the top of the file?
[TODO: details under "Passing environment variables to a batch job"](https://docs.ccv.brown.edu/oscar/submitting-jobs/batch)

5. Build and activate the conda environment:
<!--- Make code --->
    conda env create -f rloops-x64.yml

    conda activate rloops-x64

6. In terminal, run the batch script:
<!--- Make code --->
    sbatch scheduler.sh

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [How to adjust the batch script arguments](https://docs.ccv.brown.edu/oscar/submitting-jobs/batch)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; *You can run the `myq` command to check the status (pending or running) of the job in the queue.* 

7. Once the job is complete, at a minimum, copy the output files from `~/scratch` to `~/data` so the output won't be deleted after 30 days.

8. You can also copy the files from OSCAR to your local computer:
<!--- Make code --->
    scp <username>@ssh.ccv.brown.edu:/path/to/source/file /path/to/destination/file

## Environment and Dependencies Info:
The Conda environment `rloops-x64` allows an M1 Mac to use the packages intended for an x86-64 architecture. 
Once activated, it allows access to the packages `bowtie2`, `macs2`, and `deepTools`.

The JAR files for Trimmomatic and samtools as well as the executables for bedtools and picard should be added to the `tools/` directory (not committed). 

## Workflow illustration (in progress)

![alt text](workflow-illustration.png?raw=true)
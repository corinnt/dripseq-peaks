# Pipeline to identify R-loop peaks from DRIP-seq data

*Work in progress! BIOL1960 Directed Research project under Dr. Erica Larschan*
## Table of Contents

[To-Do](https://github.com/corinnt/dripseq-peaks#to-do)

[Use Instructions](https://github.com/corinnt/dripseq-peaks#use-instructions)

[Environment and Dependencies Info](https://github.com/corinnt/dripseq-peaks#environment-and-dependencies-info)

[Workflow Illustration](https://github.com/corinnt/dripseq-peaks#workflow-illustration-in-progress)


## To-Do:

**Dependency Management and Oscar Compatibility**
- add Slurm commands to batch script - go to COBRE hours if needed
- finalize Oscar README use instructions

**Visualizations**
- visualization calls in `main` once we get clarifications from other lab
- add viz info to README illustration

**Next Directions**
- figure out cloud compute keys for SRA toolkit
- move original paper data onto Oscar [RNA-DNA strand exchange by the Drosophila Polycomb complex PRC2](https://www.nature.com/articles/s41467-020-15609-x)

    data availability: `data table > s2 cells > samples 'More' > last 6 links > for each click SRA`
    
    use [SRA toolkit](https://github.com/ncbi/sra-tools/wiki/HowTo:-fasterq-dump) to download large files 

- test on data from original paper 


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
- clarify which comparison groups/intersections to use in viz -> intersect across replicates not treatments
- compile `bedtools` and `samtools` from source -> nvm, will use tools in OSCAR
- workflow illustration for README
- convert to using python script to write Slurm batch script
- check which tools OSCAR has with `module avail bed*` -> all but macs2
- confirm Oscar will be able to use -x64 rosetta environment or that all the tools are already on Oscar  -> it won't, must make new w/ macs2
- fix `TOOLS_PATH` variable in `rloop-peaks.sh`or delete if Oscar has Trimmomatic on path -> latter
- swap DM6 reference genome for path in Oscar


## Use Instructions:
The script assumes 3 replicates `REPS={1..3}` and treatments `TREATMENTS=('DRIP' 'RNaseH' 'Input')`. 

### On Oscar, Brown's shared compute cluster:

*These directions are still a work in progress.*

**1. Data should be placed in the data/ directory with the following naming convention:**

    forward_< treament >_< replicate number >

    reverse_< treament >_< replicate number >

&nbsp;&nbsp;&nbsp;&nbsp; ex) forward_DRIP_1.fq.gz, reverse_DRIP_1.fq.gz

If different file names are preferred, this pattern can be changed in the `code/preprocess.sh` file in the function `trim_adaptors_across_reps`. 

**2. Use `ssh` to connect to connect to Oscar:**
<!--- Make code --->
    ssh <username>@ssh.ccv.brown.edu

**3. Copy over the `drip-seq` directory from your computer to Oscar in order to make the FASTQ files, script, and environment available:**

Method 1:

In Finder, `cmd-K` to open the **Connect to Server** window.

Enter `smb://smb.ccv.brown.edu/home/<username>` and press **Connect**.

You may need to [connect to the Brown VPN](https://docs.ccv.brown.edu/oscar/connecting-to-oscar/cifs) if you are off campus. 

Method 2:
<!--- Make code --->
    scp -r /path/to/source/file <username>@ssh.ccv.brown.edu:/path/to/destination/file

The `-r` flag is for recursive, so it will copy over the subdirectories and files inside the folder.

**4. Load the `anaconda` module from Oscar:**

If this is the first time you've loaded anaconda, first run, `conda init bash`, then `exit` in order to make the changes take effect. You will have to log in to Oscar again.

In terminal:
<!--- This might be module load anaconda/3-5.2.0 if this (recommended) version doesn't work --->
    module load anaconda/2022.05 

**5. Build and activate the conda environment:**
<!--- Make code --->
    conda env create -f rloops-oscar.yml # if this is the first time 

    conda activate rloops-oscar

**6. In terminal, run the batch script:**
<!--- Make code --->
    sbatch scheduler.sh

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [How to adjust the batch script arguments](https://docs.ccv.brown.edu/oscar/submitting-jobs/batch)

You can run the `myq` command to check the status (pending or running) of the job in the queue.

**7. Once the job is complete, at a minimum, copy the output files from `~/scratch` to `~/data` so the output won't be deleted after 30 days.**

**8. You can also copy the files from Oscar to your local computer with:**
<!--- Make code --->
    scp <username>@ssh.ccv.brown.edu:/path/to/source/file /path/to/destination/file

## Environment and Dependencies Info:

The Conda environment `rloops-oscar` allows a user on Oscar to use the necessary packages. 
Once activated, it allows access to the packages `bowtie2`, `macs2`, and `deepTools`.

The packages `Trimmomatic`, `samtools`, `Picard`, and `bedtools` are already available on Oscar. 

## Workflow illustration (in progress)

![alt text](workflow-illustration.png?raw=true)
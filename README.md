# Pipeline to identify R-loop peaks from DRIP-seq data

### Work in progress! BIOL1640 Independent Study project under Dr. Erica Larschan

### To-Do:

**Preprocessing Functions**
- for `mark_duplicates`, `REMOVE_DUPLICATES` or `REMOVE_SEQUENCING_DUPLICATES` or none at all?
- decide between using GenPipes or Trimmomatic to trim adaptors and perform quality control

**Workflow Functions**
- deal with discrepancy between the protocol and the paper for macs2 settings

**Dependency Management**
- see if `bedtools-2.30.0` release will run
- else try compiling bedtools from source
- else 
    switch to Docker image instead of Conda env;
    use brew install bedtools
- confirm Oscar will use -x64 arch

**Next Directions**
- test on data from original paper [RNA-DNA strand exchange by the Drosophila Polycomb complex PRC2](https://www.nature.com/articles/s41467-020-15609-x)
- replicate peak visualizations w/ deepTools multiBigwigSummary and plotCorrelation (Pearson)

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
- Write use instructions for Oscar

## Use Instructions:
Local: 

1. Activate the virtual environment `rlooppeaks-x64`

&nbsp;&nbsp;&nbsp;&nbsp;  For first time set-up, run `conda env create -f rloops-x64.yml` in terminal

&nbsp;&nbsp;&nbsp;&nbsp;  Otherwise, run `conda activate rloops-x64` in terminal

2. Input data should be placed in data/ directory with the following naming convention:

    forward_< treament >_< replicate number >

    reverse_< treament >_< replicate number >

&nbsp;&nbsp;&nbsp;&nbsp; ex) forward_DRIP_1.fq.gz, reverse_DRIP_1.fq.gz

If different file names are preferred, this pattern can be changed in the `preprocess.sh` file in `trim_adaptors_across_reps`. 

3. Run from inside the `drip-seq` directory:

    `./rloop-peaks.sh` 

Assumed to have 3 replicates `REPS={1..3}` and treatments `TREATMENTS=('DRIP' 'RNaseH' 'Input')`. 

OSCAR (Brown's shared compute cluster)
1. For the first time using OSCAR, ssh in to connect:

`ssh <username>@ssh.ccv.brown.edu`


2. Copy over the FASTQ files and script from your computer:

`scp /path/to/source/file <username>@ssh.ccv.brown.edu:/path/to/destination/file`


3. Load the `anaconda` module from OSCAR:
<!--- This might be module load anaconda/3-5.2.0 if this (recommended) version doesn't work --->
`module load anaconda/2022.05` 

If this is the first time you've loaded anaconda, first run:

`conda init bash`

<!--- TODO --->

4. Add the `/tools` directory to the environment variable:

`export my_variable=my_value`

[TODO: details under "Passing environment variables to a batch job"](https://docs.ccv.brown.edu/oscar/submitting-jobs/batch)

5. Build and activate the conda environment:

`conda env create -f rloops-x64.yml`
`conda activate rloops-x64`

6. In terminal, run the batch script:

`sbatch scheduler.sh`

To confirm! Running a batch script keeps the script from running on the login node. 

[How to adjust the job script params](https://docs.ccv.brown.edu/oscar/submitting-jobs/batch)

You can run the `myq` command to check the status (pending or running) of the job in the queue. 

7. Once complete, at a minimum, copy the output files from `~/scratch` to `~/data` so the output won't be deleted after 30 days.

8. You can also copy the files from OSCAR to your local computer:
`scp <username>@ssh.ccv.brown.edu:/path/to/source/file /path/to/destination/file`

## Environment and Dependencies Info:
The Conda environment `rloops-x64` allows an M1 Mac to use the packages intended for an x86-64 architecture. 
Once activated, it allows access to the packages `bowtie2`, `macs2`, and `deepTools`.

The JAR files for Trimmomatic and samtools and executables for bedtools and picard should be added to the `tools/` directory (not committed). 
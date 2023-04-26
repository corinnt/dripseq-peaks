# Pipeline to identify R-loop peaks from DRIP-seq data

### Work in progress! BIOL1640 Independent Study project under Dr. Erica Larschan

### To-Do:

**Preprocessing Functions**
- for `mark_duplicates`, `REMOVE_DUPLICATES` or `REMOVE_SEQUENCING_DUPLICATES` or none at all?
- decide between using GenPipes or Trimmomatic to trim adaptors and perform quality control

**Workflow Functions**
- finish call peaks between treatments
- intersect peaks across replicates
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
- Write use instructions for Oscar

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

Assumed to have replicates `REPS={1..3}` and treatments `TREATMENTS=('DRIP' 'RNaseH' 'Input')`. 

Oscar:

    TBD

## Environment and Dependencies Info:
The Conda environment `rloops-x64` allows an M1 Mac to use the packages intended for an x86-64 architecture. 
Once activated, it allows access to the packages `bowtie2`, `macs2`, and `deepTools`.

The JAR files for Trimmomatic and samtools and executables for bedtools and picard should be added to the `tools/` directory (not committed). 
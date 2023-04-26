# Pipeline to identify R-loop peaks from DRIP-seq data

### Work in progress! BIOL1640 Independent Study project under Dr. Erica Larschan

### To-Do:

**Individual Functions**
- for `mark_duplicates`, `REMOVE_DUPLICATES` or `REMOVE_SEQUENCING_DUPLICATES` or none at all?
- decide between using GenPipes or Trimmomatic to trim adaptors and perform quality control
- deal with discrepancy between the protocol and the paper for macs2 settings

**Workflow Functions**
- finish call peaks between treatments
- intersect peaks across replicates

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
- Use instructions for Oscar

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
(tab)  For first time set up, run `conda env create -f rloops-x64.yml` in terminal
(tab)  Otherwise, run `conda activate rloops-x64` in terminal
2. Input data should be placed in data/ directory with the following naming convention
(tab) forw_<treatment>_<replicate number>
(tab) rev_<treatment>_<replicate number>

3. Run 

Oscar:


## Environment Info:
The Conda environment `rloops-x64` is 
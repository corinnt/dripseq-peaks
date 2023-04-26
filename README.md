# Pipeline to identify R-loop peaks from DRIP-seq data.

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

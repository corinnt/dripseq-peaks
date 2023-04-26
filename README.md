## Pipeline to identify R-loop peaks from DRIP-seq data.

### Work in progress! BIOL1640 Independent Study project under Dr. Erica Larschan

### To-Do:

*Individual Functions*
- finish parsing input and intermediate files for mark_duplicates
- decide between using GenPipes or Trimmomatic to trim adaptors and perform quality control

*Workflow Functions*
- finish preprocessing calls to align_reads, convert SAM to sorted BAM, and mark PCR duplicates
- call peaks between treatments and intersect peaks across replicates

*Dependency Management*
- see if bedtools-2.30.0 release will run
- try compiling bedtools from source
- if not, 
    switch to Docker image instead of Conda env;
    use brew install bedtools

*Next Directions*
- test on data from original paper [RNA-DNA strand exchange by the Drosophila Polycomb complex PRC2](https://www.nature.com/articles/s41467-020-15609-x)
- replicate peak visualizations

*Complete*
- compile documentation on packages and tools
- individual package functions/operations
- develop abstraction scheme
- fix .gitignore
- figure out how to create conda env w/ x86-64 arch

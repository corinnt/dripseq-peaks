#!/bin/bash


# how to choose how much time?
#SBATCH --time=1:00:00

# use more than one node if MPI enabled (it's not)
#SBATCH -N 1
# how to choose number cores? 
#SBATCH -c 1
#SBATCH -J  rloop-peaks

# need to fix this output path. want -e error file as well?
#SBATCH -o rloop-peaks-%j.out

./rloop-peaks.sh
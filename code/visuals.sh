#!/bin/bash

# Given a BAM file, writes a bigWig file 
# using deepTools bamCoverage w/ bin size 10 and normalized with Reads Per Kilobase per Million mapped reads
function bam2bigwig {
    local bamfile=$1
    local bigwigfile="output/${bamfile%%.*}.bw"

    bamCoverage -b $bamfile -o $bigwigfile –binSize 10 --normalizeUsing RPKM

  echo "Bigwig file "${bigwigfile%%.*}" generated for "$bamfile""
}

# given two bigwig files, computes the average scores for each of the files in every genomic region 
# uses multiBigwigSummary with bin size 1000
function bigwig_summary_two {
    local bw1path=$1 
    local bw2path=$2

    local bw1file=${bw1path##*/}
    local bw2file=${bw2path##*/}

    local output="output/${bw1file%%.*}_${bw2file%%.*}.npz"

    multiBigwigSummary bins -b $bw1path $bw2path --binSize 1000 -o $output

  echo "MultiBigwigSummary generated for ${bw1} and ${bw2}."
}

function bigwig_summary_three {
    local bw1path=$1 
    local bw2path=$2
    local bw3path=$3
    
    local bw1file=${bw1path##*/}
    local bw2file=${bw2path##*/}
    local bw3file=${bw3path##*/}

    local output="output/${bw1file%%.*}_${bw2file%%.*}_${bw3file%%.*}.npz"

    multiBigwigSummary bins -b $bw1path $bw2path $bw3path --binSize 1000 -o "$output"

  echo "MultiBigwigSummary "${output%%.*}" generated for ${bw1}, ${bw2}, and ${bw3}."
}

function plot_correlation {
    local datapath=$1

    local datafile=${datapath##*/}
    local plot="output/${datafile%%.*}_plot.pdf"


    plotCorrelation --corData "$datafile" \
                    --corMethod pearson \
                    --whatToPlot scatterplot \
                    -o $plot

    echo "Correlation plot $plot generated."
}
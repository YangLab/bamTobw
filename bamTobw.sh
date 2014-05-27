#!/usr/bin/env bash
# Author: Xiao-Ou Zhang <kepbod@gmail.com>
# Description: Convert BAM files to bigWig files

function help {
    echo "bamTobw.sh -- convert stranded sequencing BAM file to bigWig file"
    echo "Usage: bamTobw.sh -b <bamlist> [-s] [-d]"
    echo "-b <bamlist> -- file contains bam files (one file per line)"
    echo "-s -- if set, related files will be scaled to HPB"
    echo "-d -- if set, bam file will be divide into strand plus and strand minus"
    exit 0
}

function bam_divide {
    local bam_file=$1
    local name=$2.bam
    local flag=$3
    echo "Creat $name" | tee -a bamTobw.log
    if (( $flag )); then
        samtools view -f 16 -h -b -o $name $bam_file
    else
        samtools view -F 16 -h -b -o $name $bam_file
    fi
    samtools index $name
}

function bam_to_bedgraph {
    local bam_file=$1.bam
    local name=$2.bedgraph
    local chrom_sizes=$3
    local scale_flag=$4
    local flag=$5
    # count total reads using samtools idxstats, it reads infomation from heads of BAM files
    local count=$(samtools idxstats $bam_file | perl -ane '$a+=$F[2];END{print "$a"}')
    # determine read length using a perl script borrowed from Shanshan Zhu
    local read_length=$(samtools view $bam_file | perl -lane 'print scalar(split //,$F[9]) and last if $F[5]=~/^[\dM]*$/;')
    local ratio=1
    if (( $scale_flag )); then
        ratio=`echo "scale=8;r=1000000000/$count/$read_length;if(length(r)==scale(r)) print 0;print r" | bc`
    fi
    if !(( $flag )); then
        ratio=-$ratio
    fi
    echo "Convert $bam_file to $name" | tee -a bamTobw.log
    echo "read counts: $count" | tee -a bamTobw.log
    echo "read length: $read_length" | tee -a bamTobw.log
    echo "scale ratio: $ratio" | tee -a bamTobw.log
    # round signal value with a simple perl script
    genomeCoverageBed -bg -split -ibam $bam_file -g $chrom_sizes -scale $ratio |perl -alne '$"="\t"; $F[-1]=int($F[-1]+0.5); print "@F"'> $name
}

function bedgraph_to_bw {
    local bedgraph_file=$1.bedgraph
    local name=$1.bw
    local chrom_sizes=$2
    echo "Convert $bedgraph_file to $name" | tee -a bamTobw.log
    echo "bedGraphToBigWig $bedgraph_file $chrom_sizes $name" | tee -a bamTobw.log
    bedGraphToBigWig $bedgraph_file $chrom_sizes $name
}

scale_flag=0
stranded_flag=0

while getopts ":b:sd" optname; do
    case $optname in
        b)
            bam_list=$OPTARG;;
        s)
            scale_flag=1;;
        d)
            stranded_flag=1;;
        :)
            help;;
        ?)
            help;;
    esac
done

if [[ !(-e "$bam_list") ]]; then
    help
fi

echo "Start bamTobw.sh at "`date` | tee -a bamTobw.log
echo "Parameters you input:" | tee -a bamTobw.log
echo "bam list file: $bam_list" | tee -a bamTobw.log
if (( $scale_flag )); then
    echo "convert to HPB: Yes" | tee -a bamTobw.log
else
    echo "convert to HPB: No" | tee -a bamTobw.log
fi
if (( $stranded_flag )); then
    echo "stranded: Yes" | tee -a bamTobw.log
else
    echo "stranded: No" | tee -a bamTobw.log
fi

while read line; do
    echo "Deal with $line at "`date` | tee -a bamTobw.log
    echo "Index $line" | tee -a bamTobw.log
    samtools index $line
    prefix=${line%%.bam}
    samtools idxstats $line | perl -alne 'print "$F[0]\t$F[1]" if $F[0]!~/\*/' > chrom_sizes.tmp
    chrom_sizes=chrom_sizes.tmp
    if (( $stranded_flag )); then
        plus_name=$prefix'_plusS'
        minus_name=$prefix'_minusS'
        echo "Divide bam into strand plus bam and strand minus bam" | tee -a bamTobw.log
        bam_divide $line $plus_name 1
        bam_divide $line $minus_name 0
        echo "Convert bam to bedgraph" | tee -a bamTobw.log
        bam_to_bedgraph $plus_name $plus_name $chrom_sizes $scale_flag 1
        bam_to_bedgraph $minus_name $minus_name $chrom_sizes $scale_flag 0
        echo "Convert bedgraph to bw" | tee -a bamTobw.log
        bedgraph_to_bw $plus_name $chrom_sizes
        bedgraph_to_bw $minus_name $chrom_sizes
    else
        line=$prefix
        echo "Convert bam to bedgraph" | tee -a bamTobw.log
        bam_to_bedgraph $line $prefix $chrom_sizes $scale_flag 1
        echo "Convert bedgraph to bw" | tee -a bamTobw.log
        bedgraph_to_bw $prefix $chrom_sizes
    fi
    rm chrom_sizes.tmp
done < $bam_list
echo "End bamTobw.sh at "`date` | tee -a bamTobw.log

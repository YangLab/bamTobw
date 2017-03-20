bamTobw
=======

Convert BAM files to bigWig files with a simple command

Advantage
=========

* Enable to scale expression signals to HPB (Hits Per Billion-mapped-bases). More information about HPB refer to [Zhu S*, Xiang JF*, Tian C, Chen LL# and Yang L#. Prediction of constitutive A-to-I editing sites from human transcriptomes in the absence of genomic sequences. BMC Genomics, 2013, 14:206](http://www.biomedcentral.com/1471-2164/14/206).
* Enable to divide the BAM file according to the strand information of each read

Usage
=====

```bash
bamTobw.sh -- convert stranded sequencing BAM file to bigWig file
Usage: bamTobw.sh -b <bamlist> [-s] [-d] [-l <readlength>]
-b <bamlist> -- file contains bam files (one file per line)
-s -- if set, related files will be scaled to HPB
-d -- if set, bam file will be divide into strand plus and strand minus
-l <readlength> -- you could assign it instead of reading from bam file
```

Requirements
============

* [samtools](http://samtools.sourceforge.net)
* [UCSC utilities](http://hgdownload.cse.ucsc.edu/admin/exe)
* [bedtools](https://github.com/arq5x/bedtools2)

Note
====

For stranded sequencing, the default sequencing protocl is dUTP methods. More discussions please refer to [issue #1](https://github.com/YangLab/bamTobw/issues/1).

This tool is suitable for different sequencing types and trimmed reads. See [issue #2](https://github.com/YangLab/bamTobw/issues/2).

License
=======

Copyright (C) 2014 YangLab.
See the [LICENSE](https://github.com/YangLab/bamTobw/blob/master/LICENSE)
file for license rights and limitations (MIT).

bamTobw
=======

Convert BAM files to bigWig files with a simple command

Usage
=====

```bash
bamTobw.sh -- convert stranded sequencing BAM file to bigWig file
Usage: bamTobw.sh -b <bamlist> [-s] [-d]
-b <bamlist> -- file contains bam files (one file per line)
-s -- if set, related files will be scaled to HPB
-d -- if set, bam file will be divide into strand plus and strand minus
```

Requirements
============

* (samtools)[http://samtools.sourceforge.net/]
* (UCSC utilities)[http://hgdownload.cse.ucsc.edu/admin/exe/]
* (bedtools)[https://github.com/arq5x/bedtools2]

License
=======

Copyright (C) 2014 YangLab.
See the (LICENSE)[https://github.com/YangLab/bamTobw/blob/master/LICENSE]
file for license rights and limitations (MIT).

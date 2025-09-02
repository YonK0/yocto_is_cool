Using bootling kernel boot graph (from boot-time-slides.pdf):

Copy and paste the output of the dmesg command to a file (let’s call it boot.log)
On your workstation, run the scripts/bootgraph.pl script in the kernel sources:
scripts/bootgraph.pl boot.log > boot.svg

Need to use something like inkscape to open the svg !
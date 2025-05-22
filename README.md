# overlaid_gaussians

gaussians.sh takes a list in the format:

meam1 stdev1

mean2 stdev2

...

from stdin, creates overlaid gaussians in xmgrace format and returns them to stdout.

This is useful for example in umbrella sampling.
I used it with GROMACS and PLUMED in a pipe like this:

``for AT in $(seq 0.5 0.025 3.5); do awk '! /^#/ {print $2}' $AT/COLVAR${AT} 2>/dev/null | datamash mean 1 pstdev 1; done | gaussians.sh | xmg -``

where each directory \$AT contained the biased simulation for one window and the COLVAT\${AT} file with the time series of the collective variable in column 2.
The resulting plot shows the overlap of the windows.

Required software:
 - datamash
 - xmgrace (only for plotting afterwards)

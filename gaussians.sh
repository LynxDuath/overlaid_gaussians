#!/usr/bin/env bash

######################################
#                                    #
#   This is gaussians!               #
#   It takes a list in the format:   #
#   meam1 stdev1                     #
#   mean2 stdev2                     #
#   ...                              #
#   from pipe and creates overlaid   #
#   gaussians in xmgrace format.     #
#                                    #
######################################
<<'COMMENT'
# vars
while [ $# -gt 0 ]; do
	case $1 in
		-id)
			read indir <&1
			shift
			;;
		-od)
			outdir=$2
			shift
			;;
		-n)
			ndxfile=$2
			shift
			;;
		-*)
			echo "Wrong flag provided. Exiting!"
			exit
			;;
		*)
			echo "Unknown argument provided. Exiting!"
			exit
			;;
	esac
	shift
done

# default vars
if [ -z $indir ]; then
	indir=.
fi
if [ -z $outdir ]; then
	outdir=.
fi
if [ -z $ndxfile ]; then
	ndxfile=index.ndx
fi
COMMENT
pi=$(echo "4*a(1)" | bc -l)

#do
inlist=$(cat | sort)
min_mu=$(echo "$inlist" | datamash -W min 1)
max_mu=$(echo "$inlist" | datamash -W max 1)
min_sigma=$(echo "$inlist" | datamash -W first 2)
max_sigma=$(echo "$inlist" | datamash -W last 2)

lower_limit=$(echo $min_mu $min_sigma | awk '{printf "%.3f", $1-3*$2}')
upper_limit=$(echo $max_mu $max_sigma | awk '{printf "%.3f", $1+3*$2}')

empty_table=$(seq $lower_limit 0.001 $upper_limit | awk '{printf "%7f %7f\n", $1, 0}')
full_table=$(echo "$empty_table")

for i in $(seq $(echo "$inlist" | wc -l)); do
	read -r mu sigma <<< $(echo "$inlist" | sed "${i}p;d")
	table="$(echo "$empty_table" | awk -v mu=$mu -v sigma=$sigma -v pi=$pi '{expo=($1-mu)^2/(2*sigma*sigma); if (expo<=32) {printf "%7f %7f\n", $1, $2+exp(-expo)/(sqrt(2*pi)*sigma)} else {printf "%7f %7f\n", $1, $2}}')"
	full_table="$(paste <(echo "$full_table") <(echo "$table") | awk '{printf "%7f %7f\n", $1+$3, $2+$4}')"
	echo "@target G0.S${i}"
	echo "@type xy"
	echo "$table"
	echo "&"
done
# echo "$table"

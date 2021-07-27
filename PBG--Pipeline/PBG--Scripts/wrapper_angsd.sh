#!/bin/bash
set -e
start=`date +%s.%N`

### ANGSD wrapper script to parallelize
# Version: v0.1.3
# - splits input regions into N_THREADS files
# - runs ANGSD in parallel
# - merges output
# - optionaly, make some plots
#
# Usage:
#    wrapper_angsd.sh [ANGSD OPTIONS] [-doPlots {0123}] [-debug {012}]



#################
### Variables ###
#################
# Check if GNU parallel is installed
if [[ ! `type -P parallel` ]]; then
    echo "ERROR: GNU parallel binary not found in \$PATH." >&2
    exit -1
fi

# Check if ANGSD is installed
if [[ ! $ANGSD_BIN ]] || [[ ! -f $ANGSD_BIN ]] || [[ ! -x $ANGSD_BIN ]]; then
    if [[ ! `type -P angsd` ]]; then
        echo "ERROR: ANGSD binary not found in \$PATH or in \$ANGSD_BIN." >&2
        exit -1
    else
	ANGSD_BIN=`type -P angsd`
    fi
fi
ANGSD_PATH=`dirname $ANGSD_BIN`

# Check if BEDTOOLS is installed
if [[ ! `type -P bedtools` ]]; then
    echo "ERROR: BEDTOOLS binary not found in \$PATH." >&2
    exit -1
fi

# Check GAWK version
GAWK_VERSION=`gawk --version | awk -F "[ ,.]" 'NR==1{print $3}'`
if [[ $GAWK_VERSION -lt 4 ]]; then
    echo "ERROR: GAWK version not supported. Please update GNU awk (to at least v4.0)." >&2
    exit -1
fi

# Set TMP folder
if [ -z $TMP_DIR ]; then
    TMP_DIR=$HOME/scratch
fi
TMP_DIR=$TMP_DIR/angsd_$USER

# Set number of threads
N_THREADS=1



#################
### Functions ###
#################
in_array() {
    idx=""
    local CNT=0
    local hay needle=$1
    shift
    for hay; do
        CNT=$((CNT+1))
#	if [[ $hay == $needle ]]; then               # Case-sensitive comparison
	if [ "${hay,,}" = "${needle,,}" ]; then      # Case-insensitive comparison
            idx=$CNT
            return 0
        fi
    done
    return 0
}

# Merge GZip files, keeping the header (assumes that header is the same on all files)
hzcat() {
    zcat $@ | awk 'h == $0{next} NR==1{h=$0} {print}' | gzip -c --best
}



#######################
### Check arguments ###
#######################
mkdir -p $TMP_DIR
args=( $@ )
ID=$TMP_DIR/angsd_$RANDOM


### Script specific options
# Check if "plot" option specified. This option is specific from this script and, as such, it is not passed to ANGSD.
# -doPlots 0 = won't make any plots
# -doPlots 1 = will plot depthGlobal data (requires -doDepth)
# -doPlots 2 = will plot depthSample data (requires -doDepth)
# -doPlots 3 = will plot both depthGlobal and depthSample data (requires -doDepth)
in_array "-doPlots" "${args[@]}"
PLOT=0
if [[ $idx -ne 0 ]]; then
    PLOT=${args[$idx]}
    args[$((idx-1))]=""
    args[$idx]=""    
fi

# DEBUG mode; does not remove files when it ends
# -debug 0 = disables debug mode
# -debug 1 = dry-run mode (tests input and number of threads actually used)
# -debug 2 = debug mode (separate LOG file for each ANGSD run and does not delete temp files)
in_array "-debug" "${args[@]}"
DEBUG=0
if [[ $idx -ne 0 ]]; then
    DEBUG=${args[$idx]}
    args[$((idx-1))]=""
    args[$idx]=""
fi

### ANGSD options
# Check if region option is set
in_array "-r" "${args[@]}"
if [[ $idx -ne 0 ]]; then
    echo "ERROR: no point in parallelized when -r option is set!" >&2
    exit -1
fi


# Check for -bam argument
in_array "-b" "${args[@]}"
if [[ $idx -eq 0 ]]; then
    in_array "-bam" "${args[@]}"
fi
if [[ $idx -ne 0 ]]; then
    BAM_LIST=${args[$idx]}
else
    echo "ERROR: could not find argument for input BAM files (-bam)" >&2
    exit -1
fi


# find -nThreads argument
in_array "-P" "${args[@]}"
if [[ $idx -eq 0 ]]; then
    in_array "-nThreads" "${args[@]}"
fi
if [[ $idx -eq 0 ]]; then
    echo "ERROR: could not find argument for number of threads (-P / -nThreads)" >&2
    exit -1
fi
N_THREADS=${args[$idx]}
args[$idx]=2


# find -out argument
in_array "-out" "${args[@]}"
if [[ $idx -eq 0 ]]; then
    echo "ERROR: could not find argument for output file (-out)" >&2
    exit -1
fi
out_idx=$idx
OUT=${args[$out_idx]}
mkdir -p `dirname $OUT`

# find -ref argument
in_array "-ref" "${args[@]}"
if [[ $idx -ne 0 ]]; then
    if [ ! -s ${args[$idx]}.fai ]; then
        echo "ERROR: could not find REFERENCE index file" >&2
        exit -1
    fi
else
    echo "ERROR: could not find REFERENCE sequence (-ref)" >&2
    exit -1
fi
ref_idx=$idx


# find -rf argument
in_array "-rf" "${args[@]}"
if [[ $idx -ne 0 ]]; then
    if [ ! -s ${args[$idx]} ]; then
	echo "ERROR: could not find -rf file" >&2
	exit -1
    fi
    # Convert '-rf' file into BED
    gawk 'NR==FNR{x[$1]=$2} NR!=FNR{sep=index($1,":"); chr=substr($1,1,sep-1); split(substr($1,sep+1),pos,"-",seps); if(pos[1]=="")pos[1]=1; if(pos[2]=="")pos[2]=(length(seps)==0 && pos[1]>1 ? pos[1] : x[chr]); print chr"\t"pos[1]-1"\t"pos[2]}' ${args[$ref_idx]}.fai ${args[$idx]} > $ID.reg.bed
else
    awk '{print $1"\t"0"\t"$2}' ${args[$ref_idx]}.fai > $ID.reg.bed
    args+=('-rf')
    args+=('reg_file.tmp')
    idx=$((${#args[@]}-1))
fi
reg_idx=$idx

in_array "-doThetas" "${args[@]}"
if [[ $idx -ne 0 ]]; then
    echo "ERROR: option '-doThetas' is not supported by this wrapper. Please use vanilla ANGSD instead." >&2
    exit -1
fi

# Split dataset based on chr/scaffold/contig size
REF_SIZE=`awk -F'\t' '{sum+=$3-$2} END{print sum}' $ID.reg.bed`
# If "-doSaf", then chromosomes cannot be split
in_array "-doSaf" "${args[@]}"
if [[ $idx -ne 0 ]]; then
    echo 'INFO: making chunks but NOT splitting regions (slower but required by "-doSaf")' >&2
    awk -v id=$ID. -v max_size=$((REF_SIZE/N_THREADS)) 'BEGIN{size=0; i=0} {size+=$3-$2; print $1":"$2+1"-"$3 > sprintf("%s%010d",id,i)} size>max_size{size=0; i++}' $ID.reg.bed
else
    echo "INFO: making chunks splitting regions (faster)" >&2
    bedtools makewindows -b $ID.reg.bed -w 100 | split -d -a 10 -l $((REF_SIZE/N_THREADS/100)) - $ID.split_
    for FILE in $ID.split_*
    do
	mergeBed -i $FILE | awk '{print $1":"$2+1"-"$3}' > ${FILE//split_/}
    done
fi
if [[ $DEBUG -eq 1 ]]; then
    echo "[DRY-RUN]: can only use `ls $ID.[0-9]* | wc -l` threads to analyze `cat $ID.[0-9]* | wc -l` regions."
    rm -f $ID.*
    exit 0
fi



######################
### Run each chunk ###
######################
echo "==> Running ANGSD by chunk." >&2
LOG=''
for CHUNK in $ID.[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]
do
    if [[ $DEBUG -ne 0 ]]; then
	LOG="2> $CHUNK.log"
    fi

    args[$reg_idx]=$CHUNK
    args[$out_idx]=$CHUNK.out_tmp
    echo $ANGSD_BIN ${args[@]} $LOG
done | \parallel -j $N_THREADS --halt soon,fail=1 --joblog $ID.parallel.log
# Parse JOB's exit codes
EXIT_CODE=`awk 'BEGIN{exit_code=0} NR>1 && $7!=0 {exit_code=$7; exit} END{print exit_code}' $ID.parallel.log`
if [[ $EXIT_CODE -ne 0 ]]; then
    echo "ERROR: ANGSD terminated with errors" >&2
    exit $EXIT_CODE
fi



#####################
### Merge outputs ###
#####################
echo "==> Merging output files." >&2
# doQsDist
in_array "-doQsDist" "${args[@]}"
if [[ $idx -ne 0 ]]; then
    awk 'NR==1{print} FNR>1{x[$1]+=$2} END{ for(i=0;i<length(x);i++){print i"\t"x[i]} }' $ID.*.out_tmp.qs > $OUT.qs
fi

# dumpCounts
in_array "-dumpCounts" "${args[@]}"
if [[ $idx -ne 0 ]]; then
    hzcat $ID.*.out_tmp.pos.gz > $OUT.pos.gz
    zcat $OUT.pos.gz | cut -f 1,2 | sort -T $TMP_DIR --parallel $N_THREADS | uniq -d | perl -n -e 'die("ERROR: duplicated lines when merging \"dumpCounts\".")'

    if [[ ${args[$idx]} -ge 2 ]]; then
	hzcat $ID.*.out_tmp.counts.gz > $OUT.counts.gz
    fi
fi

# doDepth
in_array "-doDepth" "${args[@]}"
if [[ $idx -ne 0 ]]; then
    awk '{for(i=1;i<=NF;i++) x[i]+=$i } END{ for(i=1;i<=NF;i++) printf x[i]"\t"; print"" }' $ID.*.out_tmp.depthGlobal > $OUT.depthGlobal &
    #awk '{for(i=1;i<=NF;i++) x[FNR][i]+=$i } END{ for(j=1;j<=FNR;j++){for(i=1;i<=NF;i++) printf x[j][i]"\t"; print""} }' $ID.*.out_tmp.depthSample > $OUT.depthSample
    perl -an -e '$l++; if($file ne $ARGV){$l=0; $file=$ARGV}; for($i=0;$i<=$#F;$i++){$x[$l][$i]+=$F[$i]} END{ for($i=0;$i<=$#x;$i++){print(join("\t",@{$x[$i]})."\n")} }' $ID.*.out_tmp.depthSample > $OUT.depthSample

    if [[ $PLOT -ne 0 ]]; then
	# To avoid excessive memory usage, if X-axis greater then $MAX, subsample
	MAX=10000
	if [[ $((PLOT & 1)) -eq 1 ]]; then
	    # Plot Global depth
	    MAX_X=`awk '{sum=sumT=0; for(i=1;i<NF;i++)sumT+=$i; for(i=1;i<NF;i++){sum+=$i; if(sum>sumT*0.98){print i; next}} }' $OUT.depthGlobal`
	    awk '{print "Global\t"$0}' $OUT.depthGlobal | awk 'BEGIN{print "ID\tDepth\tN_Sites\tVar"} { for(i=2; i<=NF; i++) print $1"\t"(i-2)"\t"$i"\tDepth" }' | head -n $((MAX_X+1)) | awk -v max_x=$MAX_X -v max=$MAX 'NR==1 || rand() < max/max_x' | Rscript --vanilla --slave `dirname "${BASH_SOURCE[0]}"`/plot_data.R -t bar --plot_x Depth --plot_y N_Sites --plot_size 2,5 -o $OUT.Global.pdf
	fi

	if [[ $((PLOT & 2)) -eq 2 ]]; then
	    cat $BAM_LIST | xargs -I {} basename {} ".realigned.bam" > $ID.BAM.id
	    # Plot per Sample depth
	    MAX_X=`awk '{sum=sumT=0; for(i=1;i<NF;i++)sumT+=$i; for(i=1;i<NF;i++){sum+=$i; if(sum>sumT*0.90){print i; next}} }' $OUT.depthSample | sort -gr | head -n 1`
	    paste $ID.BAM.id $OUT.depthSample | awk 'BEGIN{print "ID\tDepth\tN_Sites\tVar"} { for(i=2; i<=NF; i++) print $1"\t"(i-2)"\t"$i"\tDepth" }' | awk -v max_x=$MAX_X -v max=$MAX 'NR==1 || ($2 <= max_x && rand() < max/max_x)' | Rscript --vanilla --slave `dirname "${BASH_SOURCE[0]}"`/plot_data.R -t bar --plot_x Depth --plot_y N_Sites --plot_size 1,6 -o $OUT.Sample_0.pdf

	    MAX_X=`awk '{sum=sumT=0; for(i=2;i<NF;i++)sumT+=$i; for(i=2;i<NF;i++){sum+=$i; if(sum>sumT*0.90){print i; next}} }' $OUT.depthSample | sort -gr | head -n 1`
	    paste $ID.BAM.id $OUT.depthSample | awk 'BEGIN{print "ID\tDepth\tN_Sites\tVar"} { for(i=3; i<=NF; i++) print $1"\t"(i-2)"\t"$i"\tDepth" }' | awk -v max_x=$MAX_X -v max=$MAX 'NR==1 || ($2 <= max_x && rand() < max/max_x)' | Rscript --vanilla --slave `dirname "${BASH_SOURCE[0]}"`/plot_data.R -t bar --plot_x Depth --plot_y N_Sites --plot_size 1,6 -o $OUT.Sample_1.pdf
	fi
    fi
fi

# doSnpStat
in_array "-doSnpStat" "${args[@]}"
if [[ $idx -ne 0 ]]; then
    hzcat $ID.*.out_tmp.snpStat.gz > $OUT.snpStat.gz
    zcat $OUT.snpStat.gz | cut -f 1,2 | sort -T $TMP_DIR --parallel $N_THREADS | uniq -d | perl -n -e 'die("ERROR: duplicated lines when merging \"doSnpStat\".")'
fi

# doGlf
in_array "-doGlf" "${args[@]}"
if [[ $idx -ne 0 ]]; then
    if [[ ${args[$idx]} -eq 2 ]]; then
	hzcat $ID.*.out_tmp.beagle.gz > $OUT.beagle.gz
	zcat $OUT.beagle.gz | cut -f 1 | sort -T $TMP_DIR --parallel $N_THREADS | uniq -d | perl -n -e 'die("ERROR: duplicated lines when merging \"doGlf\".")'
    else
	find $ID.*.out_tmp.glf.gz -not -empty | sort -V | xargs cat > $OUT.glf.gz
    fi

    if [[ ${args[$idx]} -eq 3 ]]; then
	hzcat $ID.*.out_tmp.glf.pos.gz > $OUT.glf.pos.gz
	zcat $OUT.glf.pos.gz | cut -f 1,2 | sort -T $TMP_DIR --parallel $N_THREADS | uniq -d | perl -n -e 'die("ERROR: duplicated lines when merging \"doGlf\".")'
    fi
fi

# doMaf
in_array "-doMaf" "${args[@]}"
if [[ $idx -ne 0 ]]; then
    hzcat $ID.*.out_tmp.mafs.gz > $OUT.mafs.gz
    zcat $OUT.mafs.gz | cut -f 1,2 | sort -T $TMP_DIR --parallel $N_THREADS | uniq -d | perl -n -e 'die("ERROR: duplicated lines when merging \"doMaf\".")'
fi

# doThetas
in_array "-doThetas" "${args[@]}"
if [[ $idx -ne 0 ]]; then
    hzcat $ID.*.out_tmp.thetas.gz > $OUT.thetas.gz # Not supported anymore since thetas output format changed
    zcat $OUT.thetas.gz | cut -f 1,2 | sort -T $TMP_DIR --parallel $N_THREADS | uniq -d | perl -n -e 'die("ERROR: duplicated lines when merging \"doThetas\".")'
else
    # doSaf
    in_array "-doSaf" "${args[@]}"
    if [[ $idx -ne 0 ]]; then
	$ANGSD_PATH/misc/realSFS cat $ID.*.out_tmp.saf.idx -outnames $OUT
    fi
fi

# HWE_pval
in_array "-HWE_pval" "${args[@]}"
if [[ $idx -ne 0 ]]; then
    hzcat $ID.*.out_tmp.hwe.gz > $OUT.hwe.gz
    zcat $OUT.hwe.gz | cut -f 1,2 | sort -T $TMP_DIR --parallel $N_THREADS | uniq -d | perl -n -e 'die("ERROR: duplicated lines when merging \"doHWE_pval\".")'
fi

# doGeno
in_array "-doGeno" "${args[@]}"
if [[ $idx -ne 0 ]]; then
    find $ID.*.out_tmp.geno.gz -not -empty | sort -V | xargs cat > $OUT.geno.gz
fi

# doPlink
in_array "-doPlink" "${args[@]}"
if [[ $idx -ne 0 ]]; then
    cat $ID.0000000001.out_tmp.tfam > $OUT.tfam
    cat $ID.*.out_tmp.tped > $OUT.tped
fi

# doVcf
in_array "-doVcf" "${args[@]}"
if [[ $idx -ne 0 ]]; then
    zgrep '#' $ID.0000000001.out_tmp.vcf.gz > $OUT.vcf
    zcat $ID.*.out_tmp.vcf.gz | awk '!/^#/' >> $OUT.vcf
    bgzip --threads $N_THREADS --force $OUT.vcf
fi

# doHaploCall
in_array "-doHaploCall" "${args[@]}"
if [[ $idx -ne 0 ]]; then
    zcat $ID.*.out_tmp.haplo.gz | awk '/chr\tpos\tmajor\tind0/ && NR>1{next} {print}' | pigz -p $N_THREADS > $OUT.haplo.gz
#    cat $ID.*.out_tmp.haplo.gz > $OUT.haplo.gz
    zcat $OUT.haplo.gz | cut -f 1,2 | sort -T $TMP_DIR --parallel $N_THREADS | uniq -d | perl -n -e 'die("ERROR: duplicated lines when merging \"doHaploCall\".")'
fi

# doAsso
in_array "-doAsso" "${args[@]}"
if [[ $idx -ne 0 ]]; then
    zcat $ID.*.out_tmp.lrt0.gz | awk '/Chromosome\tPosition\tMajor\tMinor\tFrequency\tLRT/ && NR>1{next} {print}' | pigz -p $N_THREADS > $OUT.lrt0.gz
#    cat -f $ID.*.out_tmp.lrt0.gz > $OUT.lrt0.gz
    zcat $OUT.lrt0.gz | cut -f 1,2 | sort -T $TMP_DIR --parallel $N_THREADS | uniq -d | perl -n -e 'die("ERROR: duplicated lines when merging \"doAsso\".")'
fi



# Clean-up
mv $ID.0000000001.out_tmp.arg $OUT.arg
if [[ $DEBUG -eq 0 ]]; then
    rm -f $ID.[0-9]*
fi



# Print running time
end=`date +%s.%N`
echo "==> ANGSD run $ID finished in "$( echo "$end - $start" | bc -l )" seconds." >&2
exit 0

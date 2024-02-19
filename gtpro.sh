#!/usr/bin/bash

###############  config  ###############
ENV='/ldfssz1/ST_META/share/User/chenjh356/anaconda3/envs/sv/bin'
WORKDIR='/hwfssz1/ST_HEALTH/P18Z10200N0127/yuzixuan/reference/yzxtest/gtpro/2.19'
TMP='/hwfssz1/ST_HEALTH/P18Z10200N0127/yuzixuan/reference/yzxtest/gtpro/2.19/tmp'
GT_PRO_DATABASE='/hwfssz1/ST_HEALTH/P18Z10200N0127/AUTO/chenjh356/SV/GT_Pro_database/db922_new'
GT_Pro_Res='/hwfssz1/ST_HEALTH/P18Z10200N0127/yuzixuan/reference/yzxtest/gtpro/2.19/rusult'
TMPDIR='/hwfssz1/ST_HEALTH/P18Z10200N0127/yuzixuan/reference/yzxtest/gtpro/2.19/tmpdir'
SUCCEED=$WORKDIR/finished.txt

export PATH=$ENV:$PATH
export TMPDIR=$TMPDIR
cd "$TMP" || exit
while :
do
    store=$(df . | awk 'NR==2 {value=$4 / (1024*1024); printf "%d", value}')
    if [ "$store" -gt 1000 ]; then
        break
    else
        sleep 3600
    fi
done


cd $WORKDIR/ || exit
sampleid=$1
fq1=$(cat $WORKDIR/jobslist.txt | grep "$sampleid" | awk '{print $2}')
fq2=$(cat $WORKDIR/jobslist.txt | grep "$sampleid" | awk '{print $3}')
###############    GT-Pro    ###############
GT_Pro genotype -t 8 -d $GT_PRO_DATABASE -o $GT_Pro_Res/"$sampleid" $fq1 $fq2

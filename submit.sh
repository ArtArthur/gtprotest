############################################################
#                      Config Section                      #
############################################################
WORKDIR='/hwfssz1/ST_HEALTH/P18Z10200N0127/yuzixuan/reference/yzxtest/gtpro/2.19'
ENV='/ldfssz1/ST_META/share/User/chenjh356/anaconda3/envs/sv/bin'
JOBS=$WORKDIR/jobslist.txt
SUCCEED=$WORKDIR/finished.txt
TMP='/hwfssz1/ST_HEALTH/P18Z10200N0127/yuzixuan/reference/yzxtest/gtpro/2.19/tmp'
TMPDIR='/hwfssz1/ST_HEALTH/P18Z10200N0127/yuzixuan/reference/yzxtest/gtpro/2.19/tmp/tmpdir'
ROW=$2
JOBSLIST=$(awk 'NR%2=='"$ROW"' {print $1}' $JOBS)
LOGS=$WORKDIR/logs
LIMIT=$1
TOTAL=$(awk 'NR%2=='"$ROW"' {print $1}' $JOBS | wc -l)


export TMPDIR=$TMPDIR

function jobcount_check () {
    submit_num=$(qstat | grep -c jobs)
    job_id=$(mktemp)
    sort_job=$(mktemp)
    file_id=$(mktemp)
    cd $TMP || exit
    ls -l *.fastq 2>/dev/null | awk '{print $9}' | cut -d '_' -f 1 | sort -u | grep -oE '[0-9]+' > "$file_id"
    alljobs=$(qstat | grep jobs | awk '{print $1}')
    for jid in $alljobs
    do
        qstat -j "$jid" | grep job_args | awk '{print $2}' >> "$job_id"
    done
    sort "$job_id" > "$sort_job"
    submit_id=$(cat "$job_id")
    intersection=$(comm -12 "$sort_job" "$file_id" | grep -v "^$")
    file_count=$(cat "$file_id" | wc -l)
    count=$(echo "$intersection" | wc -l)
    rm "$job_id" "$file_id" "$sort_job"
    job_total=$(($submit_num+$file_count-$count))
    if [ "$job_total" -lt "$LIMIT" ];then
        return 0
    else
        return 1
    fi
}


############################################################
#                        Main Section                      #
############################################################
while :
do
    jobcount_check
    run_jobcheck=$?
    finished_list=$(cat "$SUCCEED")
    for sampleid in $JOBSLIST
    do
        if [ $run_jobcheck -eq 0 ];then
            if [[ ! $finished_list =~ $sampleid ]];then
                if [[ ! $submit_id =~ $sampleid ]];then
                    cd $WORKDIR || exit
                    snum=$(cat $WORKDIR/yzx_submit.log | grep $sampleid | wc -l)

                        qsub -cwd -l vf=30g,num_proc=8 -P P18Z10200N0127 -binding linear:8 -q st.q -o $LOGS/"$sampleid".o.log -e $LOGS/"$sampleid".e.log $WORKDIR/gtpro2.sh "$sampleid"

                    now=$(date)
                    echo "[$now] $sampleid had been submited!"
                    jobcount_check
                    run_jobcheck=$?
                fi
            fi
        fi
        if [ $run_jobcheck -eq 1 ];then
            break
        fi
    done
    finished=$(cat "$SUCCEED" | wc -l)
    if [ "$finished" -eq "$TOTAL" ];then
        now=$(date)
        echo "[$now] All jobs done!"
        break
    fi
    sleep 7200s
done

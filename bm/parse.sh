#!/bin/bash

RUN_ID=$1

source ./config

echo -n "$RUN_ID,"
if [ "$NFS_CLIENT" == "1" ]; then
    exit
fi 

function get_mb_written() {
    devname=${1:5}
    dev_kb_after=$(cat iostat_after.dat | grep $devname | xargs | cut -d " " -f7)
    dev_kb_before=$(cat iostat_before.dat | grep $devname | xargs | cut -d " " -f7)
    echo -n $(((dev_kb_after-dev_kb_before)/1024))
}

function get_wiops_sum() {
	devname=${1:5}
	sum=0
	while read wiops; do
    		sum=$(python3 -c "print($sum+$wiops)")
	done < /tmp/wiops
	echo $sum
}
    
echo -n "$(get_mb_written ${dev}),$(get_mb_written ${JOURNAL_DEV}),$(get_wiops_sum $dev),$(get_wiops_sum $JOURNAL_DEV),"

cat iostat.dat | grep ${dev:5} | sed -r 's/[[:blank:]]+/,/g' | cut -d "," -f8 > /tmp/wiops
while read wiops; do
    dev_sum=$(python3 -c "print($sum+$wiops)")
done < /tmp/wiops

if [ "$NFS_SERVER" == "1" ]; then
    cd client-results
    echo -n "NFS=1,"
    source ./config
else
    echo -n "NFS=0."
fi
echo -n ":FC=$FAST_COMMIT:XFS=$XFS,$NUM_THREADS,$BENCHMARK,"
if [[ "$BENCHMARK" == filebench* ]]; then
    runtime=$(cat result.dat | grep "Run took" | xargs | cut -d " " -f4)
else
    runtime=60
fi
echo "$runtime"

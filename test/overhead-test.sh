#!/bin/bash

pushd $(dirname $0)

javac Busy.java

TIMESECONDS=7

function measure() {
  java Busy $NUMTHREADS $STACKDEPTH $TIMESECONDS 2>/tmp/no-prof.txt >/dev/null

  java Busy $NUMTHREADS $STACKDEPTH $TIMESECONDS 2>/tmp/prof.txt >/dev/null &
  JAVAPID=$!
  sleep 1
  ../profiler.sh -a start -p $JAVAPID
  sleep $(($TIMESECONDS-2))
  ../profiler.sh -a stop -p $JAVAPID
  sleep 1
  wait $JAVAPID 2>/dev/null

  BASELINE=$(tail -n +4 /tmp/no-prof.txt | head -n -4 | awk '{ total += $0 } END { printf "%12.3f", total/NR }')
  PROFILER=$(tail -n +4 /tmp/prof.txt    | head -n -4 | awk '{ total += $0 } END { printf "%12.3f", total/NR }')
  OVERHEAD=$(echo $BASELINE $PROFILER | awk '{ printf "%12.3f", (($1/$2)-1.0)*100.0 }')
  printf "%-12s %-12s %-12s\n" $BASELINE $PROFILER $OVERHEAD
}

trap 'echo "^C caught, exiting soon."' SIGINT

printf "%-8s %-8s %-12s %-12s %-12s\n" "THREADS" "DEPTH" "BASELINE" "PROFILER" "OVERHEAD%"
for NUMTHREADS in `seq 1 8`
do
  for STACKDEPTH in `seq 100 500 3100`
  do
    printf "%-8d %-8d " $NUMTHREADS $STACKDEPTH
    measure
  done
done

popd

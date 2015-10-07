#!/bin/bash
#
# The Bash shell script executes a command with a time-out.
# Upon time-out expiration SIGTERM (15) is sent to the process. If the signal
# is blocked, then the subsequent SIGKILL (9) terminates it.
#
# Based on the Bash documentation example.

# Hello Chet,
# please find attached a "little easier"  :-)  to comprehend
# time-out example.  If you find it suitable, feel free to include
# anywhere: the very same logic as in the original examples/scripts, a
# little more transparent implementation to my taste.
#
# Dmitry V Golovashkin <Dmitry.Golovashkin@sas.com>

scriptName="${0##*/}"

DEFAULT_TIMEOUT=9000 #ms
DEFAULT_INTERVAL=10000 #ms
DEFAULT_DELAY=10000 #ms

 

# Timeout.
timeout_ms=$DEFAULT_TIMEOUT
# Interval between checks if the process is still alive.
interval_ms=$DEFAULT_INTERVAL
# Delay between posting the SIGTERM signal and destroying the process by SIGKILL.
delay_ms=$DEFAULT_DELAY

function printUsage() {
    cat <<EOF

Synopsis
    $scriptName [-t timeout_ms] [-i interval_ms] [-d delay_ms] command
    Execute a command with a time-out.
    Upon time-out expiration SIGTERM (15) is sent to the process. If SIGTERM
    signal is blocked, then the subsequent SIGKILL (9) terminates it.

    -t timeout_ms
        Number of milliseconds to wait for command completion.
        Default value: $DEFAULT_TIMEOUT milliseconds.

    -i interval_ms
        Interval between checks if the process is still alive.
        Positive integer, default value: $DEFAULT_INTERVAL milliseconds.

    -d delay_ms
        Delay between posting the SIGTERM signal and destroying the
        process by SIGKILL. Default value: $DEFAULT_DELAY milliseconds.

As of today, Bash does not support floating point arithmetic (sleep does),
therefore all delay_ms/time values must be integers.
EOF
}

FullLine=$*
# Options.
while getopts ":t:i:d:" option; do
    case "$option" in
        t) timeout_ms=$OPTARG ;;
        i) interval_ms=$OPTARG ;;
        d) delay_ms=$OPTARG ;;
        *) printUsage; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

# $# should be at least 1 (the command to execute), however it may be strictly
# greater than 1 if the command itself has options.
if (($# == 0 || interval_ms <= 0)); then
    printUsage
    exit 1
fi

# kill -0 pid   Exit code indicates if a signal may be sent to $pid process.
(
    now="$(date +%s%N)"                   #start the clock
    interval_s="$(echo "scale=3; $interval_ms/1000" |bc)"
    delay_s="$(echo "scale=3; $delay_ms/1000" |bc)"
    elapsed_ms=0

    while ((elapsed_ms < timeout_ms)); do
        sleep ${interval_s}s
        kill -0 $$ || exit 0
        elapsed_ns="$(($(date +%s%N)-$now))"
        elapsed_ms="$(echo "$elapsed_ns/1000/1000" | bc)"
    done

    echo " " ; echo " "
    echo " \"$scriptName $FullLine\" Failed"
    echo " Timed out at $timeout_ms milliseconds" ; echo ' '


    # Be nice, post SIGTERM first.
    # The 'exit 0' below will be executed if any preceeding command fails.
    #kill childs
    childs="$(pstree -p $$ | tr "\n" " " |sed "s/[^0-9]/ /g" |sed "s/\s\s*/ /g")"
    kill -s SIGTERM $childs
    sleep "${delay_s}s"
    kill -s SIGKILL $childs

    #kill myself
    kill -s SIGTERM $$ && kill -0 $$ || exit 0
    sleep "${delay_s}s"
    kill -s SIGKILL $$
) 2> /dev/null &

exec "$@"

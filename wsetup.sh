#!/bin/bash

RESCHED_HRS=$(cat .prefs/RESCHED_HRS)
# This is XERAFIN initialization stuff. 

cleared_time=$(cat cleared_until)
now=$(date +%s)
HOURS_AHEAD_CNT=$((($cleared_time-$now)/3600))
HOURS_AHEAD_CNT=$(($HOURS_AHEAD_CNT+1))
if [ $HOURS_AHEAD_CNT -lt $RESCHED_HRS ] ; then
	HOURS_AHEAD_CNT=$RESCHED_HRS
fi

SCORE_START=$(./cardbox_score.sh)


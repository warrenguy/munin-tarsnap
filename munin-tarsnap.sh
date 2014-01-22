#!/bin/sh
#
# Munin plugin for Tarsnap
#
# https://github.com/warrenguy/munin-tarsnap
# 
# USAGE:
#
#   Add the following to your backup script (after tarsnap has run), or to a
#   cron job:
#
#     /usr/local/bin/tarsnap --print-stats > /path/to/tarsnap-stats.txt
#  
#   N.B.: ensure /path/to/munin-stats.txt is readable by munin-node. The
#   default path this script tries is /var/lib/munin/tarsnap-stats.txt
#
# CONFIGURATION:
#
#   [tarsnap]
#   env.STATSFILE /path/to/tarsnap-stats.txt
#
# AUTHOR:
#
#   Warren Guy <warren@guy.net.au>
#   https://warrenguy.me
#

STATSFILE=${STATSFILE=/var/lib/munin/tarsnap-stats.txt}

case $1 in
  config)
    cat <<'EOM'
multigraph tarsnap_total
graph_title Tarsnap total data
graph_vlabel bytes
graph_category tarsnap
total_size.label Total size
total_compressed.label Total size (compressed)

multigraph tarsnap_unique
graph_title Tarsnap unique data
graph_vlabel bytes
graph_category tarsnap
unique_size.label Unique data
unique_compressed.label Unique data (compressed)
EOM
    exit 0;;
esac

NUMBERS=`cat $STATSFILE | sed -e 's/All\ archives\ *//g' -e 's/(unique\ data)\ *//g' -e 's/^\ *//g' -e 's/\ /\n/g' |grep -v ^$ |egrep "[0-9]+"`
LINE=0
for NUMBER in $NUMBERS; do
  LINE=`expr $LINE + 1`
  case "$LINE" in
    1)  TOTALSIZE=$NUMBER ;;
    2)  TOTALCOMP=$NUMBER ;;
    3)  UNIQUESIZE=$NUMBER ;;
    4)  UNIQUECOMP=$NUMBER ;;
  esac
done

printf "multigraph tarsnap_total\ntotal_size.value %s\ntotal_compressed.value %s\n\n" $TOTALSIZE $TOTALCOMP
printf "multigraph tarsnap_unique\nunique_size.value %s\nunique_compressed.value %s\n" $UNIQUESIZE $UNIQUECOMP

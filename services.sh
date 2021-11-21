#!/bin/bash

# specify the file containing the output of og.sh
if [ $# -lt 1 ] ; then
    echo "please specify input file"
    exit -1
fi

infile="$1"

# make sure that the file exists
if [ ! -f "$infile" ] ; then
    echo "no such file: $infile"
    exit -1
fi

# sed:  lines from og.sh output that start with a tab contain port information
# sed:  we are only interested in open ports, so discard filtered or closed ports
# awk:  discard lines with insufficient information
# awk:  discard the first three fields, which are the port number, port state, and protocol
# sed:  discard lines that end with a question mark (e.g., "ftp?", "login?", "sql|imaps?")
# sed:  get rid of leading whitespace
# uniq: get a unique list of all services

cat "$infile" \
| sed -n '/^\t/p' \
| sed -E '/(filtered|closed)/d' \
| awk 'BEGIN{FS=","} {if(NF>2){print($0)}}' \
| awk 'BEGIN{FS=","} {for(i=3;i<=NF;i++){printf("%s ",$i);if(i==NF){print("");}}}' \
| sed '/.*?/d' \
| sed -E 's/^\s+//g' \
| uniq -u

#!/bin/bash
MODFILE=$1
DATE=$2
VERSION=$3
sed -e "1 s/DATE/$DATE/" -e "1 s/VERSION/$VERSION/" -e '1,5 s/^.SH "\([^"]\+\) - \([^"]\+\)"/.SH "NAME"\n\1 \\- \2\n.SH "SYNOPSIS"/' $MODFILE
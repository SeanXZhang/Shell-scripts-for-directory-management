#!/bin/bash

if [ -z $1 ]; then
    echo "restore: missing operand"
    exit 1
fi

file=$(basename $1)

if [ ! -f ~/deleted/$file ]; then
    echo "restore: cannot restore \`$1': No such file or directory"
    exit 1
fi

resLog=$(echo ~/.restore.info)

line=$(grep $file $resLog)
#echo "Line: $line"
#line=$(grep $1 ~/.restore.info)

pathOrig=$(dirname $line | cut -d ":" -f2)
#filenameOrig=$(echo $line | cut -d "_" -f1)
filenameOrig=$(basename $line)
#echo "Found: $pathOrig $filenameOrig"

if [ -f $pathOrig/$filenameOrig ]; then
    read -p "Do you want to overwrite?" opt
else
    mkdir -p $pathOrig
    mv ~/deleted/$file $pathOrig/$filenameOrig
    grep -v $line $resLog > $resLog.tmp
    mv $resLog.tmp $resLog
fi

case $opt in
y | Y | yes)
    echo "Replaced!"
    mv ~/deleted/$file $pathOrig/$filenameOrig
    grep -v $line $resLog > $resLog.tmp
    mv $resLog.tmp $resLog ;;
*)
    exit 1 ;;
esac
#!/bin/bash


# parameters check 
if [ "$#" -ne 2 ]; then
  echo "Illegal number of parameters!"
  exit 1
fi

writefile=$1
writestr=$2

echo ${writestr} | tee ${writefile} &>/dev/null
if [ ! -f ${writefile} ]; then
  echo "File could not be created!"
  exit 1
fi


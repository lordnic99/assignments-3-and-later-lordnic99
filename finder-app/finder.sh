#!/bin/sh


# parameters check 
if [ "$#" -ne 2 ]; then
  echo "Illegal number of parameters!"
  exit 1
fi

filesdir=$1
searchstr=$2

# directory check 
if [ ! -d ${filesdir} ]; then
  echo "Directory ${filesdir} DOES NOT exists!"
  exit 1
fi

file_count=$(find ${filesdir} -type f | wc -l)
line_count=$(grep -r ${searchstr} ${filesdir} 2> /dev/null | wc -l)

echo "The number of files are ${file_count} and the number of matching lines are ${line_count}"



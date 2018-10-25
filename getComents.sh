#!/bin/bash
#
# Get Comments
#
# Version 1.0 10/2018
#
# @rem:Searches coments in source files and build's a list of files containing them@@

# Builds list of files to search

buildFileList()
{
    echo "Buliding file list...."
    find . -name "*.c" > getComentsFileList
    find . -name "*.java" >> getComentsFileList
    find . -name "*.xml"  >> getComentsFileList
}


# Display text in blue color

textColorBlue()
{

printf "\e[37m"
}

# Reset all escape sequences (e.g. switch text color back to standart)

resetEscapes()
{
printf "\e[0m"
}

###############################
# Main
###############################

errors=0
answer=n
filesFound=0

if [ -f "getComentsErrorLog" ]
then
    rm getComentsErrorLog
fi

textColorBlue
echo
echo "Get comments..."
echo "Do you want to search for new files 'y' or use an existing file list 'n'?"
read answer

if [ "$answer" = "y" ] || [ "$answer" ="Y" ]
then
     buildFileList
else
    if [ "$answer" = "n" ] || [ "$answer" ="N" ]
    then
	if [ -f "getComentsFileList" ]
	then
	    echo "using existing 'result' list...."
	else
	    echo "No file list found. Building file list now!"
	    buildFileList
	fi
    fi
fi

resetEscapes
echo ""
echo "Begin of Directory:"

while read path
do
    echo "{"
    if [ -f $path ]
    then
	echo "$path"
	cat $path | egrep -o "(@rem:.+){1}({(.+)?})?(@@){1}"
	let "filesFound=filesFound+1"
    else
	echo "$0 error: file $path does not exist" >> getComentsErrorLog
    	echo ""
	let "errors=errors+1"
    fi
    echo "}"
done < getComentsFileList

textColorBlue
echo ""
if [ $errors -gt 0 ]
then
    echo "$0 done, with errors ($errors). See 'getComentsErrorLog'"
else
    echo "$0 done, no errors. Files with coments found:$filesFound"
    if [ $filesFound -eq 0 ]
    then
	echo "No files containing coments where found" >> getComentsFileList
    fi
fi
resetEscapes

# The following pattern works
# cat $(find . -name "*.c") | egrep -o "@comment:.+"

# The following pattern is not working....
# cat SampelCode.c | egrep "(@{1}((comment:)[\w\d ]{0,})(@[\w,]{0,}@){1}){1}"


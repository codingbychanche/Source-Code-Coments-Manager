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
    find . -name \*.c > getComentsFileList
    find . -name \*.java >> getComentsFileList
    find . -name \*.xml  >> getComentsFileList
    find . -name \*.sh  >> getComentsFileList
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
fi

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

resetEscapes

echo ""
while read path
do
    if [ -f "$path" ]
    then
	result="$(cat $path | egrep -o -n "(@rem:.+){1}({(.+)?})?(@@){1}")" # This is the sane search pattern used later to disply the result, if any.....
	if [ $? -eq 0 ] # @rem:Bash shell: '$?' contains the result of the last operation 0=OK// 1= Error or no result......@@
	then
	    echo "{"
	    echo "$path"
	    cat $path | egrep -o -n "(@rem:.+){1}({(.+)?})?(@@){1}"
	    let "filesFound=filesFound+1"
	    echo "}"
	fi
    else
	echo "$0 error: file $path does not exist" >> getComentsErrorLog
    	echo ""
	let "errors=errors+1"
    fi
done < getComentsFileList

textColorBlue
echo ""
if [ $errors -gt 0 ]
then
    echo "$0 done, with errors ($errors). See 'getComentsErrorLog'"
fi
echo "$0 done, no errors. Files with coments found:$filesFound"
resetEscapes

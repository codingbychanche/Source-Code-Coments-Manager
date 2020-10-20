#!/bin/bash
#
# Get Comments
#
# Version 1.4 12/2018
#
# @rem:Searches coments in source files and build's a list of files containing them@@


ComentsList="ComentsList.txt"

# Builds list of files to search

buildFileList()
{
    echo "Buliding file list...."
    find . -user Berthold -name \*.c > getComentsFileList
    find . -user Berthold -name \*.java >> getComentsFileList
    find . -user Berthold -name \*.xml  >> getComentsFileList
    find . -user Berthold -name \*.sh  >> getComentsFileList
}

# Count found files...
countFoundFiles()
{
    while read path
    do
	{
	    let "filesFound=filesFound+1"
	}
    done < getComentsFileList
    echo "Matching files found:$filesFound"
}

# Draw progress bar

drawProgressBar()
{
    echo Progress......
    for i in `seq 1 $numOfProgressElements`;
    do
	printf "-"
    done
}
echo ""

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
filesWithComentsFound=0

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

countFoundFiles

# Init and draw progress bar
let "numOfProgressElements=20"
let "step=filesFound/20"
let "stepCount=0"

drawProgressBar

# If present, remove existing comments list

if [ -f "commentsList.txt" ]
then
    echo Existing comments list deleted....
    rm commentsList.txt
fi

# Get files from file list and check them for comments...
resetEscapes
echo ""
while read path
do
    if [ -f "$path" ]
	then
        # Don't check if current file is this script..... 
	if [ "$path" != "$0" ]
	then
	    # It is not this script file, so, check file for coments

	    # Progress bar.....
	    if [ $stepCount -eq $step ]
	    then
		printf "#"
		let "stepCount=0"
	    fi
	    let "stepCount=stepCount+1"
	    
	    # Check if the current file contains comments....
            # This is the same search pattern used later to display the result, if any.....
 	    # @rem:File names with spaces. Note $path variable is enclosed by ". This way spaces are correctly idendified{bash}@@
	    result="$(cat "$path" | egrep -o -n "(@rem:.+){1}({(.+)?})?(@@){1}")"
	    if [ $? -eq 0 ] # @rem:Bash shell: '$?' contains the result of the last operation 0=OK// 1= Error or no result......@@
	    then

		# Current file contains comments, get them all...
		echo "{">>$ComentsList
		echo "$path">>$ComentsList
		cat "$path" | egrep -on "(@rem:.+){1}({(.+)?})?(@@){1}">>$ComentsList
		let "filesWithComentsFound=filesWithComentsFound+1"
		
		echo "}">>$ComentsList
	    fi
	else
	    echo "$0 error: file $path does not exist" >> getComentsErrorLog
    	    echo ""
	    let "errors=errors+1"
	fi
    fi
done < getComentsFileList

textColorBlue
echo ""
if [ "$errors" -gt 0 ]
then
    echo "$0 done, with errors ($errors). See 'getComentsErrorLog'"
else
    echo "$0 done, no errors."
    resetEscapes
fi
#!/bin/bash
#======================================================================================================================================================
# Script:		zipcrack.sh
# Version:		1.0
# Author:		David Barr
# Date Created:		##
# Last Modified:	##
# Brief:		"This script uses fcrackzip and a supplied dictionary file to try to unzip the contents of all zip files in the working
#			directory."
# Exit Codes:		0 - Success
# 			1 - Dictionary file name not specified
#			2 - fcrackzip is not installed
#			3 - unzip is not installed
#			4 - md5sum is not installed
#======================================================================================================================================================

VERSION="1.0"
AUTHOR="David Barr"

USAGE="Usage: ./zipcrack.sh [dictionary]"

if [ -z $1 ]; then
	echo "Error: Insufficient command line arguments.  Dictionary file name not specified!"
	echo "${USAGE}"
	exit 1
fi

command -v fcrackzip >/dev/null 2>&1 || { echo >&2 "fcrackzip is required but not installed.  Aborting."; exit 2; }
command -v unzip >/dev/null 2>&1 || { echo >&2 "unzip is required but not installed.  Aborting."; exit 3; }
command -v md5sum >/dev/null 2>&1 || { echo >&2 "md5sum is required but not installed.  Aborting."; exit 4; }

DICTIONARY=$1

FILES_PROCESSED=0
ZIP_FILES_DETECTED=0
FILES_EXTRACTED=0
FILES_NOT_EXTRACTED=0
FILES_SKIPPED=0

echo "zipcrack, version ${VERSION}, created by ${AUTHOR}"
echo "Script started at $(date) by user ${USER} on host $(hostname)"
DICTIONARY_MD5=($(md5sum ${DICTIONARY}))
DICTIONARY_WORDS=$(wc -l ${DICTIONARY} | awk '{print $1}')
echo "Specified dictionary file is ${DICTIONARY} with the MD5 hash ${DICTIONARY_MD5} and ${DICTIONARY_WORDS} words"

for FILE in ./*; do
	FILES_PROCESSED=$((FILES_PROCESSED+1))
	if file --mime-type ${FILE} | grep -q zip$; then
		ZIP_FILES_DETECTED=$((ZIP_FILES_DETECTED+1))
		PASSWORD=$(fcrackzip -D -p passwords -u ${FILE} | awk '{print $5}')
			if [ -z $PASSWORD ]; then
				echo "Archive :  ${FILE} password not found, no files extracted."
				FILES_NOT_EXTRACTED=$((FILES_NOT_EXTRACTED+1))
			else
				unzip -P ${PASSWORD} ${FILE}
				FILES_EXTRACTED=$((FILES_EXTRACTED+1))
			fi
	else
		echo "${FILE} is not zipped, skipping."
		FILES_SKIPPED=$((FILES_SKIPPED+1))
	fi
done

echo
echo "Files processed:         ${FILES_PROCESSED}"
echo "Zip files detected:      ${ZIP_FILES_DETECTED}"
echo "Non-zip files skipped:   ${FILES_SKIPPED}"
echo
echo "Zip files extracted:     ${FILES_EXTRACTED}"
echo "Zip files not extracted: ${FILES_NOT_EXTRACTED}"
echo
echo "Finished at $(date)."

exit 0



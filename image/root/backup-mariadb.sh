#!/bin/bash

function envValue() {
		local NAME=$1
		local ORG_VAL=$2
		local VAL=$(env | grep "^${NAME}=" | cut -d= -f2)
		if [ -z "$VAL" ]; then
			echo "${ORG_VAL}"
		else
			echo "${VAL}"
		fi
}

export -f envValue

function validate_param(){
	local PARAMETER_NAME
	local MESSAGE
	PARAMETER_NAME="$1"
	MESSAGE="$2"
	if [ -z "`envValue ${PARAMETER_NAME}`" ]; then
			echo -e >&2 "Error: Mandatory ${PARAMETER_NAME} enviroment variable is empty! ${MESSAGE}"
			EXIT_FLAG="true"
	fi
}

echo "Start of parameters validation ..."

validate_param "DB_PASSWORD"
validate_param "DB_USER"
validate_param "DB_HOST"
validate_param "DB_NAME"


if [ ! -z "$EXIT_FLAG" ]; then
	exit 1
fi

echo "DB_HOST='${DB_HOST}'"
echo "DB_USER='${DB_USER}'"
echo "DB_NAME='${DB_NAME}'"


FOUND_DATABASE=$(mysql -h $DB_HOST -u${DB_USER} -p${DB_PASSWORD} -Bse "show databases;" | grep  ${DB_NAME})

if [ -z "$FOUND_DATABASE" ]; then
	echo -e >&2 "Error: Database ${DB_NAME} not found!"
	exit 2
fi

BACKUP_DATESTAMP=$(date +"${DATE_FORMAT}")
BACKUP_FOLDER="${DATADIR}/${BACKUP_DATESTAMP}"
mkdir -p ${BACKUP_FOLDER}

BACKUP_TIMESTAMP=$(date +"${TIMESTAMP_FORMAT}")
BACKUP_SQL_FILE_PATH="${BACKUP_FOLDER}/${DB_NAME}-${BACKUP_TIMESTAMP}.sql"

echo "Backup path: ${BACKUP_SQL_FILE_PATH}"

echo "Backup started ... "
date

mysqldump -h $DB_HOST -u${DB_USER} -p${DB_PASSWORD}  ${DB_NAME} > ${BACKUP_SQL_FILE_PATH}
RESULT=$?

echo "Backup finished ... "
if [ ! -z "$ZIP_CMD" ]; then
		echo "Compressing backup started ... "
		$ZIP_CMD  $BACKUP_SQL_FILE_PATH
		echo "Backup compressed ... "
		RESULT=$?
fi

ls -al "${BACKUP_FOLDER}/${DB_NAME}-${BACKUP_TIMESTAMP}"*

exit $RESULT

# Local Variables:
# mode: shell-script
\# indent-tabs-mode: t
# tab-width: 2
# End:

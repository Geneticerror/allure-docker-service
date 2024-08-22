#!/bin/bash

EXEC_STORE_RESULTS_PROCESS=$1
PROJECT_ID=$2

# USED FROM API
ORIGIN=$3

PROJECT_REPORTS=$STATIC_CONTENT_PROJECTS/$PROJECT_ID/reports
if [ "$(ls $PROJECT_REPORTS | wc -l)" != "0" ]; then
    if [ -e "$PROJECT_REPORTS/latest" ]; then
        LAST_REPORT_PATH_DIRECTORY=$(ls -td $PROJECT_REPORTS/* | grep -wv $PROJECT_REPORTS/latest | grep -v $EMAILABLE_REPORT_FILE_NAME | head -1)
    else
        LAST_REPORT_PATH_DIRECTORY=$(ls -td $PROJECT_REPORTS/* | grep -v $EMAILABLE_REPORT_FILE_NAME | head -1)
    fi
fi

LAST_REPORT_DIRECTORY=$(basename -- "$LAST_REPORT_PATH_DIRECTORY")
#echo "LAST REPORT DIRECTORY >> $LAST_REPORT_DIRECTORY"

RESULTS_DIRECTORY=$STATIC_CONTENT_PROJECTS/$PROJECT_ID/results
if [ ! -d "$RESULTS_DIRECTORY" ]; then
    echo "Creating results directory for PROJECT_ID: $PROJECT_ID"
    mkdir -p $RESULTS_DIRECTORY
fi


echo "Generating report for PROJECT_ID: $PROJECT_ID"
cd $PROJECT_REPORTS/latest
swagger-coverage-commandline -s $RESULTS_DIRECTORY/swagger_doc_file.json -i $RESULTS_DIRECTORY -c $RESULTS_DIRECTORY/swagger_doc_config.json


if [ "$KEEP_HISTORY" == "TRUE" ] || [ "$KEEP_HISTORY" == "true" ] || [ "$KEEP_HISTORY" == "1" ] ; then
    if [[ "$EXEC_STORE_RESULTS_PROCESS" == "1" ]]; then
        $ROOT/storeAllureReport.sh $PROJECT_ID $BUILD_ORDER
    fi
fi

$ROOT/keepAllureLatestHistory.sh $PROJECT_ID

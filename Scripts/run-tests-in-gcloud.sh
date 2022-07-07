#!/bin/bash

set -x

RESULTS_DIR=/tmp/junit
TMP_RESULTS_DIR=$RESULTS_DIR-tmp

TEST_ARCHIVE="TestsArchive.zip"

LOG_FILE="output/gcloud_output.txt"

rm -rf "$RESULTS_DIR"
rm -rf "$TMP_RESULTS_DIR"
mkdir -p "$TMP_RESULTS_DIR"

(cd output/Build/Products/ && zip -r ../../$TEST_ARCHIVE *;)

gcloud --version

gcloud firebase test ios run \
        --test "output/$TEST_ARCHIVE" \
        --device model=iphonex,version=12.0 \
        --device model=iphonexs,version=12.0 \
        --device model=iphonexs,version=12.1 \
        --device model=ipad5,version=12.0 \
        --xcode-version=10.2 \
        --timeout=30m \
        --no-record-video 2>&1 | tee $LOG_FILE

EXIT_CODE=${PIPESTATUS[0]}
echo "gcloud finished with code $EXIT_CODE"

GS_FOLDER=`cat $LOG_FILE | grep "Raw results will be stored in your GCS bucket at" | sed "s/.*\/\(test-lab-.*\)\/.*/\1/"`
echo GS_FOLDER=$GS_FOLDER

gsutil -m cp -r "gs://$GS_FOLDER/*" "$TMP_RESULTS_DIR" || EXIT_CODE=$?
echo "gsutil finished with code $?"

find "$TMP_RESULTS_DIR" -name \*.zip -delete
tar czf output/Results.tgz -C "$TMP_RESULTS_DIR" .
find "$TMP_RESULTS_DIR" -type f ! -name \*.xml -delete
find "$TMP_RESULTS_DIR" -type d -empty -delete

mv "$TMP_RESULTS_DIR" "$RESULTS_DIR"

exit $EXIT_CODE

#!/bin/bash

set -ex

echo -e "\nRunning visual regression tests for $SITE_NAME with UUID $SITE_UUID..."

TOKEN=`curl -X POST "https://diffy.website/api/auth/key" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"key\":\"${DIFFY_KEY}\"}" | php -r 'echo json_decode(file_get_contents("php://stdin"))->token;'`

DIFF_ID=`curl -X POST "https://diffy.website/api/projects/${DIFFY_PROJECT}/compare" -H "accept: application/json" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d "{\"environments\":\"custom\",\"url1\":\"${LIVE_URL}\",\"url2\":\"${MULTIDEV_URL}\"}" | php -r 'echo str_replace("diff: ", "", json_decode(file_get_contents("php://stdin")));'`

DIFF_INFO=`curl -X GET "https://diffy.website/api/diffs/${DIFF_ID}" -H "accept: application/json" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" | php -r 'var_export(json_decode(file_get_contents("php://stdin")));'`

echo -e "${DIFF_ID}"

# Once we implement status and URL in full diff API call
# we will wait for diff to be completed and then download
# zip archive and upload to MULTIDEV site so admin can review.
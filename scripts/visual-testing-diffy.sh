#!/bin/bash

set -ex

echo -e "\nRunning visual regression tests for $SITE_NAME with UUID $SITE_UUID..."

TOKEN=`curl -X POST "https://diffy.website/api/auth/key" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"key\":\"${DIFFY_KEY}\"}" | php -r 'echo json_decode(file_get_contents("php://stdin"))->token;'`

#DIFF_ID=`curl -X POST "https://diffy.website/api/projects/${DIFFY_PROJECT}/compare" -H "accept: application/json" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d "{\"environments\":\"custom\",\"url1\":\"${LIVE_URL}\",\"url2\":\"${MULTIDEV_URL}\"}" | php -r 'echo str_replace("diff: ", "", json_decode(file_get_contents("php://stdin")));'`
DIFF_ID=3863

DIFF_INFO=`curl -X GET "https://diffy.website/api/diffs/${DIFF_ID}" -H "accept: application/json" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json"`
DIFF_URL=`echo "${DIFF_INFO}" | php -r 'echo json_decode(file_get_contents("php://stdin"))->archiveUrl;'`
COUNTER=0

while [ -z "${DIFF_URL}" ] && [ "$COUNTER" -le 60 ];
do
    sleep 5s
    DIFF_INFO=`curl -X GET "https://diffy.website/api/diffs/${DIFF_ID}" -H "accept: application/json" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json"`
    DIFF_URL=`echo "${DIFF_INFO}" | php -r 'echo json_decode(file_get_contents("php://stdin"))->archiveUrl;'`

    echo "Checking if diff archive was created: $COUNTER"
    COUNTER=$((COUNTER+1))
done

RESULT=`echo "${DIFF_INFO}" | php -r 'echo json_decode(file_get_contents("php://stdin"))->result;'`

# If there were differences -- upload report to auto-updates site for review.
if [ "$RESULT" -gt 0 ]; then
    wget "${DIFF_URL}" -P "${TMP_FOLDER}"
    FILENAME="${DIFF_URL##*/}"
    tar -xzf "${TMP_FOLDER}/${FILENAME}" -C "${TMP_FOLDER}"
    # Repeat two times to get rid of .gz and then .tar.
    FILENAME="${FILENAME%.*}"
    FILENAME="${FILENAME%.*}"
    # Upload report using rsync.
    rsync -rLvz --size-only --ipv4 --progress -e 'ssh -p 2222' "${TMP_FOLDER}/${FILENAME}" --temp-dir=~${TMP_FOLDER} $MULTIDEV.$SITE_UUID@appserver.$MULTIDEV.$SITE_UUID.drush.in:files/

    MULTIDEV_URL="https://${MULTIDEV}-${SITE_NAME}.pantheonsite.io"
    SLACK_MESSAGE="We have run auto-update on ${SITE_NAME} site and found visual differences. Report is available at . Updated site is https://${MULTIDEV}-${SITE_NAME}.pantheonsite.io."
    SLACK_ATTACHEMENTS="\"attachments\": [{\"fallback\": \"View the visual regression report\",\"color\": \"${RED_HEX}\",\"actions\": [{\"type\": \"button\",\"text\": \"Diffy Report\",\"url\":\"${MULTIDEV_URL}/sites/default/files/${FILENAME}/viewer.html\"},{\"type\": \"button\",\"text\": \"${MULTIDEV} Site\",\"url\":\"${MULTIDEV_URL}\"},{\"type\": \"button\",\"text\": \"${MULTIDEV} Dashboard\",\"url\":\"https://dashboard.pantheon.io/sites/${SITE_UUID}#${MULTIDEV}/code\"}]}]"
else
    SLACK_MESSAGE="We have run auto-update on ${SITE_NAME} site and no visual differences found. Updated site is https://${MULTIDEV}-${SITE_NAME}.pantheonsite.io."
    SLACK_ATTACHEMENTS=""
fi


echo -e "\nSending a message to the ${SLACK_CHANNEL} Slack channel"
curl -X POST --data "payload={\"channel\": \"${SLACK_CHANNEL}\",${SLACK_ATTACHEMENTS}, \"username\": \"${SLACK_USERNAME}\", \"text\": \"${SLACK_MESSAGE}\"}" $SLACK_HOOK_URL

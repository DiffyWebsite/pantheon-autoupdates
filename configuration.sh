#!/bin/bash

set -ex

# Replacement for sites-to-auto-update.json
# Exports information about individual site we plan to check.
export SITE_NAME='diffy'
export SITE_UUID='56fe4929-47bc-4273-ab23-3456346dccbc'
export CREATE_BACKUPS=1
export RECREATE_MULTIDEV=1
export LIVE_URL=0
export DIFFY_KEY='a9f8a8086c47a52fd086b62756f40bc4'
export DIFFY_PROJECT=359
export TMP_FOLDER='/tmp'
export SLACK_HOOK_URL='https://hooks.slack.com/services/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'
export SLACK_CHANNEL='#auto-updates'
export SLACK_USERNAME='bot'
#!/bin/bash

set -ex

# Where to place file with global variables that will
# be used by other scripts.
export BASH_ENV='/tmp/env.sh'
# Remove environments file to start from scratch.
rm -rf ${BASH_ENV}

# Set up variables.
source configuration.sh

# Set up globals.
./scripts/set-up-globals.sh

# Identify framework.
#./scripts/set-framework.sh

# Run auto-updates.
#./scripts/auto-update.sh
source ${BASH_ENV}

#if [[ "${UPDATES_APPLIED}" = true ]]
#then
    ./scripts/visual-testing-diffy.sh
#fi
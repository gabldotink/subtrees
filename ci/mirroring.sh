#!/usr/bin/env bash

set -o errexit
set -o nounset

# Setup Git mirror.
git remote set-url origin "https://oauth2:${GITLAB_PERSONAL_ACCESS_TOKEN}@gitlab.com/DeveloperC/starlingbanktechnicalchallenge"
# Push to Git mirror.
git push --force

#!/usr/bin/env sh

set -o errexit
set -o xtrace

# Get current version.
current_version=$(cat "VERSION")
# If the tag already exist then exit.
git tag -l | grep -q "^${current_version}$" && exit 0
# Where to start generating the release notes from.
base_commit=$(git rev-list --max-parents=0 HEAD)
# Get the very last tag in the history or else set empty.
latest_tag=$(git describe --exact-match --tags || echo "")
notes_from="${latest_tag:-${base_commit}}"
# Generate the release notes.
release_notes=$(git log --format="* %s" "${notes_from}".. --no-merges)
# Create release and the tag.
gh release create "${current_version}" --notes "${release_notes}"

#!/bin/bash
# Push the generated repository to GitHub
#

cd import

#  Optimize structure
git gc --aggressive

git checkout Research-V1-Snapshot-Development

# Empty old repo
pushd ../empty
git push origin --mirror
popd

# Push to GitHub
git remote add origin git@github.com:dspinellis/unix-history-repo.git
git push -fu --all origin
git push --tags origin

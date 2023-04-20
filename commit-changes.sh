#!/bin/bash

set -euo pipefail

COMMIT_MESSAGE="${1:?"Specify the commit message"}"

diff="$(git diff)"
if [ -z "$diff" ]
then
    echo "No changes detected"
    echo "changes-pushed=false" >> "$GITHUB_OUTPUT"
    exit 0
fi

echo "Changes detected:"
echo "================="
git status --short --branch
echo "================="

last_author="$(git log --max-count 1 --pretty=format:%an)"
last_email="$(git log --max-count 1 --pretty=format:%ae)"

git config user.name "$last_author"
git config user.email "$last_email"
git add .
git commit --message "$COMMIT_MESSAGE"
git push

echo "changes-pushed=true" >> "$GITHUB_OUTPUT"

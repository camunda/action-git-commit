#!/bin/bash

set -euo pipefail

COMMIT_MESSAGE="${1:?"Specify the commit message"}"
AUTHOR_NAME="${2:-""}"
AUTHOR_EMAIL="${3:-""}"

if ([ -n "$AUTHOR_NAME" ] && [ -z "$AUTHOR_EMAIL"]) || ( [ -z "$AUTHOR_NAME" ] && [ -n "$AUTHOR_EMAIL" ])
then
    echo "Either both AUTHOR_NAME and AUTHOR_EMAIL must be defined, or neither should be"
    exit 1
fi

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

if [ -z "$AUTHOR_NAME" ]
then
    echo "No author specified, retrieving author of previous commit"
    AUTHOR_NAME="$(git log --max-count 1 --pretty=format:%an)"
    AUTHOR_EMAIL="$(git log --max-count 1 --pretty=format:%ae)"
fi

echo "Setting commit author: $AUTHOR_NAME <$AUTHOR_EMAIL>"
git config user.name "$AUTHOR_NAME"
git config user.email "$AUTHOR_EMAIL"

git add .
git commit --message "$COMMIT_MESSAGE"
git push

echo "changes-pushed=true" >> "$GITHUB_OUTPUT"

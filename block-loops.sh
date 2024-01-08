#!/bin/bash

set -euo pipefail

# The output format from "git log"
git_log_format="format:%an"

# The branch to find changes against.
# Pull requests are most of the time made against the "main" branch.
origin_branch="origin/main"

# The maximum allowed number of commits from the last author.
# This should be enough to allow a few commits to be made, but not too much to
# limits the number of GHA runs in case we run into an endless loop.
# Typically, 3 commits should allow:
#   1. An original update from Renovate
#   2. Updating golden files after the update
#   3. (normally not needed)
max_commit=3

last_author="$(git log --max-count=$max_commit author="$(git log --max-count 1 --pretty="$git_log_format")"

nb_commits_last_author="$(git log --format="$git_log_format" "${origin_branch}.." | grep --fixed-strings "$last_author" | wc --lines)"

if [ "$nb_commits_last_author" -ge "$max_commit" ]
then
    echo "::error::To many commits made by: $last_author." >> "$GITHUB_OUTPUT"
    echo "::error::Stopping GitHub Action now because it may be running in an endless loop." >> "$GITHUB_OUTPUT"
    exit 255
fi

echo "$last_author commited $nb_commits_last_author compared to the origin branch: $origin_banch."
exit 0

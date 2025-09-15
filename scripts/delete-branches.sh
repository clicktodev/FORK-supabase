#!/bin/bash

# Script to delete all branches except master
# This script will delete both local and remote branches except for master

echo "Starting branch cleanup - keeping only master branch"

# Define the branch to keep
KEEP_BRANCH="master"

# Read command line argument for dry run
DRY_RUN=${1:-false}

if [ "$DRY_RUN" = "dry-run" ]; then
    echo "DRY RUN MODE - No branches will be deleted"
fi

# Get list of all remote branches using ls-remote to get accurate list
echo "Getting list of remote branches..."
REMOTE_BRANCHES=$(git ls-remote --heads origin | grep -v "refs/heads/$KEEP_BRANCH" | sed 's/.*refs\/heads\///')

# Delete remote branches
echo "Remote branches to delete:"
for branch in $REMOTE_BRANCHES; do
    if [ "$branch" != "$KEEP_BRANCH" ] && [ ! -z "$branch" ]; then
        echo "  - $branch"
        if [ "$DRY_RUN" != "dry-run" ]; then
            git push origin --delete "$branch" || echo "Failed to delete remote branch: $branch"
        fi
    fi
done

# Get list of all local branches except master
LOCAL_BRANCHES=$(git branch | grep -v "$KEEP_BRANCH" | sed 's/^[[:space:]]*//' | sed 's/^\*//')

# Delete local branches
echo "Local branches to delete:"
for branch in $LOCAL_BRANCHES; do
    if [ "$branch" != "$KEEP_BRANCH" ] && [ ! -z "$branch" ]; then
        echo "  - $branch"
        if [ "$DRY_RUN" != "dry-run" ]; then
            git branch -D "$branch" || echo "Failed to delete local branch: $branch"
        fi
    fi
done

echo "Branch cleanup completed. Only $KEEP_BRANCH should remain."
echo "Remaining branches:"
git branch -a
#!/bin/bash
set -e
set -o pipefail

echo "SETTING TOKEN"
if [[ -n "$TOKEN" ]]; then
  GITHUB_TOKEN=$TOKEN
fi

echo "SETTING PAGES_BRANCH"
if [[ -n "$PAGES_BRANCH" ]]; then
  PAGES_BRANCH="master"
fi

echo "SETTING GITHUB_TOKEN"
if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Set the GITHUB_TOKEN env variable."
  exit 1
fi

echo "SETTING REPOSITORY"
if [[ -z "$GITHUB_REPOSITORY" ]]; then
  echo "Set the GITHUB_REPOSITORY env variable."
  exit 1
fi

main() {
  echo "Starting deploy..."

  echo "Fetching themes"
  git config --global url."https://".insteadOf git://
  git config --global url."https://github.com/".insteadOf git@github.com:

  remote_repo="https://${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
  remote_branch=$PAGES_BRANCH

  echo "Pushing artifacts to ${GITHUB_REPOSITORY}:$remote_branch"

  git config user.name "GitHub Actions"
  git config user.email "github-actions-bot@users.noreply.github.com"

  git add .

  # git commit -m "Deploy ${GITHUB_REPOSITORY} to ${GITHUB_REPOSITORY}:$remote_branch"
  # git push --force "${remote_repo}" master:${remote_branch}

  echo "Deploy complete"
}

main "$@"

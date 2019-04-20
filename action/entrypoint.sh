#!/bin/bash
set -e
set -o pipefail

if [[ -n "$TOKEN" ]]; then
  GITHUB_TOKEN=$TOKEN
fi

if [[ -n "$PAGES_BRANCH" ]]; then
  PAGES_BRANCH="master"
fi

if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Set the GITHUB_TOKEN env variable."
  exit 1
fi

if [[ -z "$GITHUB_REPOSITORY" ]]; then
  echo "Set the GITHUB_REPOSITORY env variable."
  exit 1
fi

main() {
  cd "$GITHUB_WORKSPACE"
  VALUES=$(ruby runner.rb)

  echo "Starting deploy..."

  echo "Changing git config"
  git config --global url."https://".insteadOf git://
  git config --global url."https://github.com/".insteadOf git@github.com:

  git config user.name "GitHub Actions"
  git config user.email "github-actions-bot@users.noreply.github.com"

  remote_repo="https://${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
  remote_branch=$PAGES_BRANCH

  echo "Pushing artifacts to ${GITHUB_REPOSITORY}:$remote_branch"

  git add .

  if [ -n "$(git status --porcelain)" ]; then
    echo "There are changes to the JSON files"

    git commit -m "Deploy ${GITHUB_REPOSITORY} to ${GITHUB_REPOSITORY}:$remote_branch"
    git push --force "${remote_repo}" master:${remote_branch}
  else
    echo "There are no changes"
  fi

  echo "Deploy complete"
}

USERNAME=$(cat $GITHUB_EVENT_PATH | jq --raw-output '.commits[0].committer.username')

if [ $USERNAME == "github-actions-bot" ]; then
  echo "Don't need to do anything because username = $USERNAME"
else
  echo "User is $USERNAME, continuing"
  main "$@a"
fi

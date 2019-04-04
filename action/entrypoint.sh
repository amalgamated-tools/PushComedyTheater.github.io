#!/bin/sh -l
echo "SUPER COOL NOW"
printenv
remote_repo="https://${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git" &&
  remote_branch="gh-pages" &&
  git init &&
  git config user.name "${GITHUB_ACTOR}" &&
  git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"

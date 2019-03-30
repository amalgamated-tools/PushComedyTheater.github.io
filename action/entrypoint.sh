#!/bin/sh -l

printenv
echo "{}" >$GITHUB_WORKSPACE/dude.json
git status
# sh -c "echo $*> $GITHUB_WORKSPACE/dude.json"

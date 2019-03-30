#!/bin/sh -l

printenv
echo "{}" >$GITHUB_WORKSPACE/dude.json
which git
ls $GITHUB_WORKSPACE
# git status
# sh -c "echo $*> $GITHUB_WORKSPACE/dude.json"

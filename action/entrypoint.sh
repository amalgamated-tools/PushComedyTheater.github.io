#!/bin/sh -l
printenv

cd $GITHUB_WORKSPACE
ls
git status
cp -R $GITHUB_WORKSPACE/ /tmp
cd /tmp
ls -al

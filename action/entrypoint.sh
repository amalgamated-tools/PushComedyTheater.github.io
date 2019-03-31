#!/bin/sh -l
printenv

cd $GITHUB_WORKSPACE
ls
git status
cp -R $GITHUB_WORKSPACE/ /tmp
cd /tmp/workspace
echo "{}" >stuff.json
git config --global user.email "bot@veverka.net"
git config --global user.name "Your Name"

git status
git add stuff.json
git status
git commit -m 'adding automagit'
git push origin master

#!/bin/sh -l
printenv

cd $GITHUB_WORKSPACE
ls
git status
cp -R $GITHUB_WORKSPACE/ /tmp
cd /tmp/workspace

echo "CREATING STUFF"
echo "{}" >stuff.json
echo "SETTING GLOBAL"

git config --global user.email "bot@veverka.net"
git config --global user.name "Patrick Veverka"
echo "GIT STATUS"
git status
echo "GIT ADD"
git add stuff.json
echo "GIT STATUS"
git status
echo "GIT COMMIT"
git commit -m 'adding automagit'
echo "GIT PUSH ORIGIN"
git push origin master
echo "GIT STATUS"
git status

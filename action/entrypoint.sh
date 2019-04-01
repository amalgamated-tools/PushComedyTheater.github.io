#!/bin/sh -l
set -x
printenv

cd /tmp

git clone https://$GITHUB_TOKEN:x-oauth-basic@github.com/PushComedyTheater/PushComedyTheater.github.io.git
ls -al
cd PushComedyTheater.github.io/
ls -al
# cd $GITHUB_WORKSPACE
# ls
# git status
# cp -R $GITHUB_WORKSPACE/ /tmp
# cd /tmp/workspace

# echo "CREATING STUFF"
# echo "{}" >stuff.json
# echo "SETTING GLOBAL"

# echo "GIT STATUS"
# git status
# echo "GIT ADD"
# git add stuff.json
# echo "GIT STATUS"
# git status
# echo "GIT COMMIT"
# git commit --author='Patrick Veverka <bot@veverka.net>' -m 'adding automagit'
# echo "GIT PUSH ORIGIN"
# git push origin master
# echo "GIT STATUS"
# git status

#!/bin/sh -l
printenv

cd /tmp
pwd

git clone https://$GITHUB_TOKEN:x-oauth-basic@github.com/PushComedyTheater/PushComedyTheater.github.io.git
cd PushComedyTheater.github.io/
ls -al
echo "{}" >boose.json
echo "GIT STATUS"
git status
echo "GIT ADD"
git add .

echo "GIT STATUS"
git status
echo "GIT COMMIT"
git commit --author='Patrick Veverka <bot@veverka.net>' -m 'adding automagit'
echo "GIT PUSH ORIGIN"
git push origin master
echo "GIT STATUS"
git status

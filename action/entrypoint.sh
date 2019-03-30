#!/bin/sh -l
echo "{}" >$GITHUB_WORKSPACE/file.json
./action/runner

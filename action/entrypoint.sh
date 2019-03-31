#!/bin/sh -l
printenv
echo "{}" >/tmp/sfile.json
./action/runner
ls /tmp/

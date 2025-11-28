#!/usr/bin/env bash

set -x
git branch -r | grep -v '\->' | while read remote; do
	branchStr="${remote}"
	git branch ${branchStr} --track "$remote" -f
done
git fetch --all --tags --force
git pull --all --tags --force

#!/bin/bash
# Intentional issues for shellcheck to catch

# SC2086: Double quote to prevent globbing and word splitting
name=hello world
echo $name

# SC2046: Quote to prevent word splitting
files=$(ls *.txt)
echo $files

# SC2034: Unused variable
unused_var="never used"

# SC2006: Use $(...) instead of backticks
date=`date +%Y-%m-%d`

# SC2002: Useless cat
cat file.txt | grep "pattern"

# SC2162: read without -r mangles backslashes
read input

# SC2164: Use cd ... || exit
cd /some/directory

# SC2069: Redirect order - stderr before stdout redirect
echo "test" 2>&1 >/dev/null

# SC2035: Use ./*glob* to avoid matching dashes
rm -rf *.tmp

# TODO: Fix these issues
# FIXME: This script is intentionally broken

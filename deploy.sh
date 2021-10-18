#!/usr/bin/env sh

set -e

hugo

cd public

git init

git add .

git commit -m 'deploy'

git push origin master:master

git push -f https://${access_token}git@github.com/pastSeagull/blog.git master:gh-pages
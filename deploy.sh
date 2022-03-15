#!/usr/bin/env sh

set -e

hugo --theme=hemingway --baseUrl="https://pastSeagull.github.io/blog/"

cd public

git init

git add .

git commit -m 'deploy'

# git push -f https://git@github.com/pastSeagull/blog.git master:gh-pages
git push -f git@github.com:pastSeagull/blog.git master:gh-pages
#!/bin/bash

if [[ -z "$1" ]]; then
  echo "Enter a git commit message you idiot!"
  exit
fi

bundle exec jekyll build && \
  cd _site && \
  git add . && \
  git commit -am "$1" && \
  git push origin master && \
  cd .. && \
  echo "Changes pushed."
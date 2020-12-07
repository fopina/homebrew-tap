#!/bin/sh -l

set -e

export BINARY_SHASUM=$(sha256sum ${INPUT_RELEASE} | cut -d ' ' -f1)

# get committer data
COMMITTER_NAME=$(git log -1 --pretty=format:"%cn")
COMMITTER_EMAIL=$(git log -1 --pretty=format:"%ce")

# clone homebrew-tap repo
git clone --depth=1 -b "${INPUT_TAP_BRANCH}" https://${INPUT_TOKEN}@github.com/${INPUT_TAP_REPO} /tmp/.worktap
cd /tmp/.worktap

# set comitter data
git config --local user.name "${COMMITTER_NAME}"
git config --local user.email "${COMMITTER_EMAIL}"

# generate formula from template
confgen -o Formula/${INPUT_FORMULA_FILE}.rb /etc/formula.rb.tpl
git add Formula/${INPUT_FORMULA_FILE}.rb

git commit Formula/${INPUT_FORMULA_FILE}.rb -m "${INPUT_FORMULA_FILE} ${INPUT_VERSION}"
git push

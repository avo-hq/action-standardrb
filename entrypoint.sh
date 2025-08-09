#!/bin/sh
version() {
  if [ -n "$1" ]; then
    echo "-v $1"
  fi
}

cd "$GITHUB_WORKSPACE"

git config --global --add safe.directory $GITHUB_WORKSPACE || exit 1

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

# Ensure StandardRB is installed
gem install -N standard $(version $INPUT_RUBOCOP_VERSION)

echo '::group:: Running standardrb with reviewdog 🐶 ...'
standardrb ${INPUT_RUBOCOP_FLAGS} \
  | reviewdog \
  -f=rubocop \
  -name="${INPUT_TOOL_NAME}" \
  -reporter="${INPUT_REPORTER}" \
  -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
  -level="${INPUT_LEVEL}"

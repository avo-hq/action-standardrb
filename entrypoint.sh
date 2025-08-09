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

# If no project-level Standard config exists, create one that extends trailing comma rules.
if [ ! -f ".standard.yml" ]; then
  # If the workspace lacks a rubocop rules file, seed it from image defaults (if available)
  if [ ! -f ".rubocop.yml" ] && [ -f "/config/.rubocop.yml" ]; then
    cp /config/.rubocop.yml .rubocop.yml
  fi
  printf "%s\n" "extend_config:" "  - .rubocop.yml" > .standard.yml
fi

echo '::group:: Running standardrb with reviewdog 🐶 ...'
standardrb ${INPUT_RUBOCOP_FLAGS} \
  | reviewdog \
  -f=rubocop \
  -name="${INPUT_TOOL_NAME}" \
  -reporter="${INPUT_REPORTER}" \
  -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
  -level="${INPUT_LEVEL}"

#!/bin/sh
version() {
  if [ -n "$1" ]; then
    echo "-v $1"
  fi
}

cd "$GITHUB_WORKSPACE"

git config --global --add safe.directory $GITHUB_WORKSPACE || exit 1

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

gem install -N standard $(version $INPUT_RUBOCOP_VERSION)

# Ensure project-level .standard.yml ignores trailing-comma cops so commas are allowed
ruby <<'RUBY'
require 'yaml'
require 'pathname'

path = Pathname('.standard.yml')

config = if path.exist?
  YAML.safe_load(path.read, permitted_classes: [], aliases: true) || {}
else
  {}
end

config = {} unless config.is_a?(Hash)

# Add all rules to ignore at the project level
ignore_entries = Array(config['ignore'])
block = { '**/*' => [
  'Style/TrailingCommaInHashLiteral',
  'Style/TrailingCommaInArrayLiteral'
] }

unless ignore_entries.any? { |e| e.is_a?(Hash) && e['**/*'].is_a?(Array) &&
  e['**/*'].include?('Style/TrailingCommaInHashLiteral') && e['**/*'].include?('Style/TrailingCommaInArrayLiteral') }
  ignore_entries << block
end

config['ignore'] = ignore_entries

path.write(config.to_yaml)
RUBY

echo '::group:: Running standardrb with reviewdog 🐶 ...'

standardrb ${INPUT_RUBOCOP_FLAGS} \
  | reviewdog \
	-f=rubocop \
	-name="${INPUT_TOOL_NAME}" \
	-reporter="${INPUT_REPORTER}" \
	-fail-on-error="${INPUT_FAIL_ON_ERROR}" \
	-level="${INPUT_LEVEL}"

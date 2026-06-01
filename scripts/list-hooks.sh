#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

usage() {
  cat <<'EOF'
Usage: list-hooks.sh <event>

List all enabled hooks for a given speckit lifecycle event from .specify/extensions.yml.

Examples:
  bash .specify/scripts/bash/list-hooks.sh after_tasks
  bash .specify/scripts/bash/list-hooks.sh after_specify

Output format (one hook per line):
  COMMAND=<command> OPTIONAL=<true|false> PROMPT=<prompt>
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

EVENT="${1:-}"
if [[ -z "$EVENT" ]]; then
  echo "ERROR: Missing required argument <event>." >&2
  usage >&2
  exit 1
fi

if ! command -v ruby >/dev/null 2>&1; then
  echo "ERROR: ruby is required to parse .specify/extensions.yml" >&2
  exit 1
fi

REPO_ROOT="$(get_repo_root)"
EXTENSIONS_FILE="$REPO_ROOT/.specify/extensions.yml"

if [[ ! -f "$EXTENSIONS_FILE" ]]; then
  echo "ERROR: File not found: $EXTENSIONS_FILE" >&2
  exit 1
fi

ruby -r yaml -e '
  file = ARGV[0]
  event = ARGV[1]

  data = YAML.load_file(file) || {}
  hooks = data.is_a?(Hash) ? data.dig("hooks", event) : nil

  if hooks.nil?
    exit 0
  end

  hooks = [hooks] if hooks.is_a?(Hash)
  hooks = [] unless hooks.is_a?(Array)

  hooks.each do |hook|
    next unless hook.is_a?(Hash)

    enabled = hook.key?("enabled") ? hook["enabled"] : true
    next unless enabled == true

    command = hook["command"].to_s.strip
    next if command.empty?

    optional = hook.key?("optional") ? hook["optional"] : true
    prompt = hook["prompt"].to_s.gsub(/\s+/, " ").strip

    optional_value = optional == true ? "true" : "false"
    puts "COMMAND=#{command} OPTIONAL=#{optional_value} PROMPT=#{prompt}"
  end
' "$EXTENSIONS_FILE" "$EVENT"

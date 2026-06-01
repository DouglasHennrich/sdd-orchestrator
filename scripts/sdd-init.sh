#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
EXTENSION_ROOT="$(cd "$SCRIPT_DIR/.." >/dev/null 2>&1 && pwd)"
PROJECT_ROOT="$(pwd)"

SOURCE_AGENTS="$EXTENSION_ROOT/templates/agents"
DEST_AGENTS="$PROJECT_ROOT/.github/agents"
DEST_DOC="$EXTENSION_ROOT/Multi-Agent SDD Orchestrator.md"

if [[ -f "$EXTENSION_ROOT/Multi-Agent SDD Orchestrator.md" ]]; then
  SOURCE_DOC="$EXTENSION_ROOT/Multi-Agent SDD Orchestrator.md"
elif [[ -f "$EXTENSION_ROOT/../Multi-Agent SDD Orchestrator.md" ]]; then
  SOURCE_DOC="$EXTENSION_ROOT/../Multi-Agent SDD Orchestrator.md"
else
  SOURCE_DOC=""
fi

if [[ ! -d "$SOURCE_AGENTS" ]]; then
  echo "ERROR: Agents source not found: $SOURCE_AGENTS"
  exit 1
fi

mkdir -p "$DEST_AGENTS"

echo "Copying agent definitions to project .github/agents..."
cp -v "$SOURCE_AGENTS"/*.md "$DEST_AGENTS/"

PROJECT_COPILOT="$PROJECT_ROOT/.github/copilot-instructions.md"
EXTENSION_COPILOT=""
for candidate in \
  "$EXTENSION_ROOT/.github/copilot-instructions.md" \
  "$EXTENSION_ROOT/templates/copilot-instructions.md" \
  "$EXTENSION_ROOT/copilot-instructions.md"; do
  if [[ -f "$candidate" ]]; then
    EXTENSION_COPILOT="$candidate"
    break
  fi
done

if [[ ! -f "$PROJECT_COPILOT" ]]; then
  if [[ -z "$EXTENSION_COPILOT" ]]; then
    echo "WARNING: Extension copilot-instructions template not found; cannot create .github/copilot-instructions.md."
  else
    echo "Creating .github/copilot-instructions.md with SDD Orchestrator instructions..."
    mkdir -p "$PROJECT_ROOT/.github"
    cp "$EXTENSION_COPILOT" "$PROJECT_COPILOT"
  fi
elif [[ -z "$EXTENSION_COPILOT" ]]; then
  echo "WARNING: Extension copilot-instructions template not found; skipping append."
elif grep -q '<!-- SPECKIT-ORCHESTRATOR START -->' "$PROJECT_COPILOT" || grep -q '<!-- SPECKIT HOOKS -->' "$PROJECT_COPILOT"; then
  echo "Project .github/copilot-instructions.md already contains SDD Orchestrator instructions."
else
  echo "Appending SDD Orchestrator instructions to project .github/copilot-instructions.md..."
  printf "\n" >> "$PROJECT_COPILOT"
  cat "$EXTENSION_COPILOT" >> "$PROJECT_COPILOT"
fi

if [[ ! -d "$PROJECT_ROOT/.squad" ]]; then
  echo "No .squad directory found. Initializing Squad..."
  squad init
else
  echo ".squad directory already exists."
fi

if [[ ! -f "$SOURCE_DOC" ]]; then
  echo "ERROR: Multi-Agent SDD Orchestrator document not found: $SOURCE_DOC"
  exit 1
fi

echo "Copying Multi-Agent SDD Orchestrator document to installed extension folder..."
cp -v "$SOURCE_DOC" "$DEST_DOC"

echo "SDD Orchestrator initialization complete."

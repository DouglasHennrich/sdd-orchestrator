#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
EXTENSION_ROOT="$(cd "$SCRIPT_DIR/.." >/dev/null 2>&1 && pwd)"
PROJECT_ROOT="$(pwd)"

SOURCE_AGENTS="$EXTENSION_ROOT/templates/agents"
SOURCE_PROMPTS="$EXTENSION_ROOT/templates/prompts"
DEST_AGENTS="$PROJECT_ROOT/.github/agents"
DEST_PROMPTS="$PROJECT_ROOT/.github/prompts"
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

if [[ ! -d "$SOURCE_PROMPTS" ]]; then
  echo "ERROR: Prompts source not found: $SOURCE_PROMPTS"
  exit 1
fi

mkdir -p "$DEST_AGENTS"
mkdir -p "$DEST_PROMPTS"

echo "Copying agent definitions to project .github/agents..."
cp -v "$SOURCE_AGENTS"/*.md "$DEST_AGENTS/"

echo "Copying prompt templates to project .github/prompts..."
cp -v "$SOURCE_PROMPTS"/*.md "$DEST_PROMPTS/"

# ── copilot-instructions ─────────────────────────────────────────────────────
# Find the extension's template
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
  echo "WARNING: Extension copilot-instructions template not found; skipping update."
else
  # Replace the blocks between markers if present, otherwise append
  ORCHESTRATOR_BLOCK=$(sed -n '/<!-- SPECKIT-ORCHESTRATOR START -->/,/<!-- SPECKIT-ORCHESTRATOR END -->/p' "$EXTENSION_COPILOT")
  HOOKS_BLOCK=$(sed -n '/<!-- SPECKIT HOOKS -->/,/<!-- END SPECKIT HOOKS -->/p' "$EXTENSION_COPILOT")

  if grep -q '<!-- SPECKIT-ORCHESTRATOR START -->' "$PROJECT_COPILOT"; then
    # Replace ORCHESTRATOR block in-place using Python (portable, handles multiline)
    python3 - "$PROJECT_COPILOT" "$EXTENSION_COPILOT" <<'PYEOF'
import sys, re

target_path = sys.argv[1]
source_path = sys.argv[2]

with open(target_path, 'r') as f:
    target = f.read()
with open(source_path, 'r') as f:
    source = f.read()

def extract_block(text, start_marker, end_marker):
    pattern = re.compile(
        re.escape(start_marker) + r'.*?' + re.escape(end_marker),
        re.DOTALL
    )
    m = pattern.search(text)
    return m.group(0) if m else None

def replace_block(text, start_marker, end_marker, new_block):
    pattern = re.compile(
        re.escape(start_marker) + r'.*?' + re.escape(end_marker),
        re.DOTALL
    )
    return pattern.sub(new_block, text)

# Update SPECKIT-ORCHESTRATOR block
new_orch = extract_block(source, '<!-- SPECKIT-ORCHESTRATOR START -->', '<!-- SPECKIT-ORCHESTRATOR END -->')
if new_orch:
    target = replace_block(target, '<!-- SPECKIT-ORCHESTRATOR START -->', '<!-- SPECKIT-ORCHESTRATOR END -->', new_orch)

# Update or append SPECKIT HOOKS block
new_hooks = extract_block(source, '<!-- SPECKIT HOOKS -->', '<!-- END SPECKIT HOOKS -->')
if new_hooks:
    if '<!-- SPECKIT HOOKS -->' in target:
        target = replace_block(target, '<!-- SPECKIT HOOKS -->', '<!-- END SPECKIT HOOKS -->', new_hooks)
    else:
        target = target.rstrip('\n') + '\n\n' + new_hooks + '\n'

with open(target_path, 'w') as f:
    f.write(target)
PYEOF
    echo "Updated SDD Orchestrator blocks in .github/copilot-instructions.md"
  else
    echo "Appending SDD Orchestrator instructions to .github/copilot-instructions.md..."
    printf "\n" >> "$PROJECT_COPILOT"
    cat "$EXTENSION_COPILOT" >> "$PROJECT_COPILOT"
  fi
fi

# ── Squad ────────────────────────────────────────────────────────────────────
if [[ ! -d "$PROJECT_ROOT/.squad" ]]; then
  echo "No .squad directory found. Initializing Squad..."
  squad init
else
  echo ".squad directory already exists."
fi

# ── Multi-Agent SDD Orchestrator doc ────────────────────────────────────────
if [[ ! -f "$SOURCE_DOC" ]]; then
  echo "ERROR: Multi-Agent SDD Orchestrator document not found: $SOURCE_DOC"
  exit 1
fi

if [[ "$SOURCE_DOC" != "$DEST_DOC" ]]; then
  echo "Copying Multi-Agent SDD Orchestrator document to installed extension folder..."
  cp -v "$SOURCE_DOC" "$DEST_DOC"
else
  echo "Multi-Agent SDD Orchestrator document already in place; skipping copy."
fi

echo "SDD Orchestrator initialization complete."

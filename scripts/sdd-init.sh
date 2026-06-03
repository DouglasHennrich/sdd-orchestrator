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

# ── Monorepo scope patch: create-new-feature.sh ─────────────────────────────
GIT_SCRIPT="$PROJECT_ROOT/.specify/extensions/git/scripts/bash/create-new-feature.sh"

if [[ ! -f "$GIT_SCRIPT" ]]; then
  echo "ERROR: $GIT_SCRIPT not found."
  echo "The sdd-orchestrator monorepo scope feature requires the spec-kit git extension."
  echo "Install it with: speckit extension add git"
  exit 1
fi

if grep -q "# SDD-ORCHESTRATOR-SCOPE-PATCH" "$GIT_SCRIPT"; then
  echo "[sdd-orchestrator] Scope patch already applied to create-new-feature.sh; skipping."
else
  # a) Add idempotency marker after shebang line
  sed -i.bak '1s|^#!/usr/bin/env bash|#!/usr/bin/env bash\n# SDD-ORCHESTRATOR-SCOPE-PATCH|' "$GIT_SCRIPT"

  # b) Add SCOPE="" variable declaration after the USE_TIMESTAMP=false line
  sed -i.bak 's|^USE_TIMESTAMP=false$|USE_TIMESTAMP=false\nSCOPE=""|' "$GIT_SCRIPT"

  # c) Add --scope flag parsing inside the while loop, after the --timestamp case block.
  #    We append it after the line that sets USE_TIMESTAMP=true (end of --timestamp block).
  sed -i.bak '/USE_TIMESTAMP=true/{n;n;s|^        ;;$|        ;;\n        --scope)\n            if \[ $((i + 1)) -gt $# \]; then\n                echo '"'"'Error: --scope requires a value'"'"' >\&2\n                exit 1\n            fi\n            i=$((i + 1))\n            next_arg="${!i}"\n            if \[\[ "$next_arg" == --* \]\]; then\n                echo '"'"'Error: --scope requires a value'"'"' >\&2\n                exit 1\n            fi\n            SCOPE="$next_arg"\n            ;;\n|}' "$GIT_SCRIPT"

  # d) Replace BRANCH_SUFFIX construction block (the if/elif/else that currently
  #    uses SHORT_NAME and generate_branch_name) with the scope-aware version.
  #    We use Python for this multi-line replacement (portable, no GNU sed needed).
  python3 - "$GIT_SCRIPT" <<'PYEOF'
import sys, re

path = sys.argv[1]
with open(path, 'r') as f:
    content = f.read()

old = (
    r'    if \[ -n "\$SHORT_NAME" \]; then\n'
    r'        BRANCH_SUFFIX=\$\(clean_branch_name "\$SHORT_NAME"\)\n'
    r'    else\n'
    r'        BRANCH_SUFFIX=\$\(generate_branch_name "\$FEATURE_DESCRIPTION"\)\n'
    r'    fi'
)
new = (
    '    if [ -n "$SCOPE" ] && [ -n "$SHORT_NAME" ]; then\n'
    '        BRANCH_SUFFIX="${SCOPE}-$(clean_branch_name "$SHORT_NAME")"\n'
    '    elif [ -n "$SHORT_NAME" ]; then\n'
    '        BRANCH_SUFFIX=$(clean_branch_name "$SHORT_NAME")\n'
    '    else\n'
    '        BRANCH_SUFFIX=$(generate_branch_name "$FEATURE_DESCRIPTION")\n'
    '    fi'
)

updated = re.sub(old, new, content)
if updated == content:
    # Fallback: try without backslash escaping (plain literal match)
    old_plain = (
        '    if [ -n "$SHORT_NAME" ]; then\n'
        '        BRANCH_SUFFIX=$(clean_branch_name "$SHORT_NAME")\n'
        '    else\n'
        '        BRANCH_SUFFIX=$(generate_branch_name "$FEATURE_DESCRIPTION")\n'
        '    fi'
    )
    updated = content.replace(old_plain, new)

with open(path, 'w') as f:
    f.write(updated)
PYEOF

  # Clean up sed backup files
  rm -f "${GIT_SCRIPT}.bak"

  echo "[sdd-orchestrator] Scope patch applied to create-new-feature.sh."
fi

# ── Monorepo scope patch: speckit.git.feature.agent.md ──────────────────────
FEATURE_AGENT="$PROJECT_ROOT/.github/agents/speckit.git.feature.agent.md"

if [[ ! -f "$FEATURE_AGENT" ]]; then
  echo "ERROR: $FEATURE_AGENT not found."
  echo "The sdd-orchestrator monorepo scope feature requires the spec-kit git extension."
  echo "Install it with: speckit extension add git"
  echo "Then re-run: speckit sdd-orchestrator.init"
  exit 1
fi

if grep -q "SDD-ORCHESTRATOR-SCOPE-PATCH" "$FEATURE_AGENT"; then
  echo "[sdd-orchestrator] Scope patch already applied to speckit.git.feature.agent.md; skipping."
else
  # Insert the scope-forwarding instruction into the Execution section.
  # We add it after the line "- Preserve technical terms and acronyms (OAuth2, API, JWT, etc.)"
  python3 - "$FEATURE_AGENT" <<'PYEOF'
import sys

path = sys.argv[1]
with open(path, 'r') as f:
    content = f.read()

# Add idempotency marker to frontmatter
content = content.replace(
    '---\ndescription: Create a feature branch with sequential or timestamp numbering\n---',
    '---\ndescription: Create a feature branch with sequential or timestamp numbering\n# SDD-ORCHESTRATOR-SCOPE-PATCH\n---'
)

# Add scope-forwarding instruction in the Execution section
scope_instruction = (
    '\n\nIf `--scope <value>` is present in `$ARGUMENTS`, extract it and pass it to '
    'the script as `--scope <value>` alongside `--short-name`. '
    'Example: `--scope front` produces a branch like `007-front-add-login`.'
)
anchor = '- Preserve technical terms and acronyms (OAuth2, API, JWT, etc.)'
content = content.replace(anchor, anchor + scope_instruction)

# Update the Bash example lines to show --scope usage
content = content.replace(
    '- **Bash**: `.specify/extensions/git/scripts/bash/create-new-feature.sh --json --short-name "<short-name>" "<feature description>"`',
    '- **Bash**: `.specify/extensions/git/scripts/bash/create-new-feature.sh --json --short-name "<short-name>" --scope "<scope>" "<feature description>"`'
)
content = content.replace(
    '- **Bash (timestamp)**: `.specify/extensions/git/scripts/bash/create-new-feature.sh --json --timestamp --short-name "<short-name>" "<feature description>"`',
    '- **Bash (timestamp)**: `.specify/extensions/git/scripts/bash/create-new-feature.sh --json --timestamp --short-name "<short-name>" --scope "<scope>" "<feature description>"`'
)

with open(path, 'w') as f:
    f.write(content)
PYEOF

  echo "[sdd-orchestrator] Scope patch applied to speckit.git.feature.agent.md."
fi

echo "SDD Orchestrator initialization complete."

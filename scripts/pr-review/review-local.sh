#!/usr/bin/env bash
# Free, zero-cloud-cost PR review — the active default. Calls your own Ollama
# instance instead of a paid API. See docs/public/guides/reviewing-cohort-prs.md
# for the full workflow this fits into; see .github/workflows/pr-review.yml for
# the (currently inactive, cloud-cost-gated) Anthropic alternative — same rubric,
# same prompt builder, different model behind it.
#
# Requires: gh (authenticated), curl, python3, and an Ollama reachable at
# OLLAMA_BASE_URL with OLLAMA_MODEL already pulled.
#
# Usage:
#   scripts/pr-review/review-local.sh <PR_NUMBER>            # print the review
#   scripts/pr-review/review-local.sh <PR_NUMBER> --post     # also post it as a PR comment
#
# Env overrides (Tanit / macOS default = native Metal Ollama on :11434):
#   OLLAMA_BASE_URL   default: http://localhost:11434
#   OLLAMA_MODEL      default: qwen2.5-coder:32b
# Compose-container path (mapped host port, usually 11435) is opt-in, e.g.:
#   OLLAMA_BASE_URL=http://localhost:11435 OLLAMA_MODEL=llama3.2:1b make review-pr PR=9
# A 404 from /api/chat almost always means the model is not pulled on *that*
# endpoint — check `curl -s "$OLLAMA_BASE_URL/api/tags"`.
set -euo pipefail

PR="${1:?usage: review-local.sh <PR_NUMBER> [--post]}"
POST_FLAG="${2:-}"

OLLAMA_BASE_URL="${OLLAMA_BASE_URL:-http://localhost:11434}"
OLLAMA_MODEL="${OLLAMA_MODEL:-qwen2.5-coder:32b}"

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

BRANCH=$(gh pr view "$PR" --json headRefName -q .headRefName)
DIFF_FILE=$(mktemp)
PROMPT_FILE=$(mktemp)
REVIEW_FILE=$(mktemp)
trap 'rm -f "$DIFF_FILE" "$PROMPT_FILE" "$REVIEW_FILE"' EXIT

gh pr diff "$PR" > "$DIFF_FILE"
scripts/pr-review/build-prompt.sh "$BRANCH" "$DIFF_FILE" > "$PROMPT_FILE"

echo "Reviewing PR #$PR (branch: $BRANCH) with $OLLAMA_MODEL at $OLLAMA_BASE_URL ..." >&2

python3 - "$OLLAMA_BASE_URL" "$OLLAMA_MODEL" "$PROMPT_FILE" "$REVIEW_FILE" <<'PYEOF'
import json, sys, urllib.error, urllib.request

base_url, model, prompt_file, out_file = sys.argv[1:5]
chat_url = f"{base_url.rstrip('/')}/api/chat"

with open(prompt_file) as f:
    prompt = f.read()

body = json.dumps({
    "model": model,
    "messages": [{"role": "user", "content": prompt}],
    "stream": False,
}).encode()

req = urllib.request.Request(
    chat_url,
    data=body,
    headers={"content-type": "application/json"},
)
try:
    with urllib.request.urlopen(req, timeout=300) as resp:
        result = json.load(resp)
except urllib.error.HTTPError as exc:
    detail = exc.read().decode("utf-8", errors="replace")
    print(
        f"Ollama HTTP {exc.code} at {chat_url} (model={model!r}).\n"
        f"Body: {detail}\n"
        f"Hint: list models with: curl -s {base_url.rstrip('/')}/api/tags\n"
        f"On Tanit use host Metal (default): unset OLLAMA_BASE_URL or set "
        f"OLLAMA_BASE_URL=http://localhost:11434\n"
        f"Compose-only box: "
        f"OLLAMA_BASE_URL=http://localhost:11435 OLLAMA_MODEL=<pulled-name>",
        file=sys.stderr,
    )
    raise SystemExit(1) from exc

text = result.get("message", {}).get("content", "")
with open(out_file, "w") as f:
    f.write(f"### 🤖 Automated review (hybrid rubric — local {model}, comment only)\n\n")
    f.write(text)
    f.write("\n\n---\n*Generated locally, no cloud API cost. Does not approve or block merge — a human review is still required.*\n")
PYEOF

if [ "$POST_FLAG" = "--post" ]; then
  gh pr comment "$PR" --body-file "$REVIEW_FILE"
  echo "Posted to PR #$PR." >&2
else
  cat "$REVIEW_FILE"
fi

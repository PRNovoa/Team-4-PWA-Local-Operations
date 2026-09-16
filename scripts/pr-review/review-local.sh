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
# Env overrides (defaults match this repo's own docker-compose Ollama service,
# reachable from the host at the mapped port — see .env.example):
#   OLLAMA_BASE_URL   default: http://localhost:11435
#   OLLAMA_MODEL      default: qwen2.5-coder:32b
#     Any locally-pulled code-capable model works — a smaller model (e.g. a
#     7B–14B coder-tuned one) trades review depth for speed; a model
#     specifically fine-tuned on git diffs/code review, if you have one
#     pulled, is a reasonable third option — this script doesn't care which,
#     it only needs an OpenAI/Ollama-chat-shaped endpoint.
set -euo pipefail

PR="${1:?usage: review-local.sh <PR_NUMBER> [--post]}"
POST_FLAG="${2:-}"

OLLAMA_BASE_URL="${OLLAMA_BASE_URL:-http://localhost:11435}"
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
import json, sys, urllib.request

base_url, model, prompt_file, out_file = sys.argv[1:5]

with open(prompt_file) as f:
    prompt = f.read()

body = json.dumps({
    "model": model,
    "messages": [{"role": "user", "content": prompt}],
    "stream": False,
}).encode()

req = urllib.request.Request(
    f"{base_url.rstrip('/')}/api/chat",
    data=body,
    headers={"content-type": "application/json"},
)
with urllib.request.urlopen(req, timeout=300) as resp:
    result = json.load(resp)

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

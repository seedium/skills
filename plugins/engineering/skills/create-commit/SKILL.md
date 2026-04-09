---
name: create-commit
description: This skill should be used when the user asks to "commit", "create a commit", "git commit", "commit my changes", "commit staged changes", "make a conventional commit", "write a commit message", or wants to create a well-formatted conventional commit from staged git changes. Handles branch safety checks, automatic commit type detection, message composition following the conventional commits spec, pre-commit hook failure recovery, and optional PR creation.
disable-model-invocation: true
model: haiku
allowed-tools: Bash(git *), Bash(gh *), Read
---

# Create Commit

Create a conventional commit from staged changes.

## Isolation

Each invocation operates in complete isolation. Ignore all prior conversation context. Base every decision solely on the current git repository state observed by commands in this invocation.

## Process

1. **Gather all context** — Run one command to collect everything:

   ```bash
   echo '=== STAGED ===' && git diff --cached --name-only && echo '=== DIFF ===' && git diff --cached && echo '=== BRANCH ===' && git branch --show-current && echo '=== LOG ===' && git log --oneline -5
   ```

   If the STAGED section is empty, tell the user nothing is staged and stop.

2. **Branch guard** — If on `main` or `master`, ask whether to create a new branch (`<kebab-description>`, max 50 chars) or commit directly.

3. **Compose commit message** per [Conventional Commits](https://www.conventionalcommits.org):

   **Format**: `type(scope): subject` or `type: subject`

   **Types**:

   | Type       | When                                       |
   | ---------- | ------------------------------------------ |
   | `feat`     | New functionality                          |
   | `fix`      | Bug fixes                                  |
   | `refactor` | Restructuring without behavior change      |
   | `chore`    | Tooling, config, dependencies              |
   | `docs`     | Documentation only                         |
   | `style`    | Formatting, whitespace only                |
   | `test`     | Adding or updating tests                   |
   | `ci`       | CI/CD changes                              |
   | `perf`     | Performance improvements                   |
   | `revert`   | Reverting a previous commit                |

   **Scope**: use when changes fall within a single module/component; omit when spanning multiple areas.

   **Subject rules**:
   - Must contain verb + subject — `add auth middleware`, not just `auth middleware`
   - Imperative mood, present tense — `add` not `adds`/`added`
   - All lowercase, under 72 characters for the entire header
   - Specific and meaningful — reader understands the change without the diff
   - Describe actual changes, never meta-tasks — no "trying", "another try", "final fix"

   **Body** (optional): explain what and why. Separate from header with a blank line.

   **No trailers**: no `Co-Authored-By` or AI attribution unless explicitly requested.

   **Good examples**:
   ```
   feat(auth): add jwt token validation
   fix(parser): handle empty input gracefully
   refactor: consolidate duplicate helper functions
   ```

   **Bad examples**: `feat: bearer login` (no verb), `chore: fix build` (vague), `chore: final try` (meta-task)

4. **Commit** — Run `git commit` immediately, do not ask for approval:

   ```bash
   git commit -m "type(scope): subject

   Optional body."
   ```

   No indentation or extra formatting in the message. If the user rejects the tool call with feedback, revise and retry.

5. **Pre-commit failures** — If commit fails due to hooks:
   - Read error output, apply targeted fixes
   - If the error mentions commitlint rules (type-enum, scope-enum, etc.), run `ls commitlint.config.* .commitlintrc* 2>/dev/null` at the repo root to find the config, then Read it and adjust the message accordingly
   - Stage fixes with `git add <specific-files>` (never `git add .`)
   - Retry up to 3 times, then report remaining issues

6. **Create PR** (non-main branches only) — After successful commit, push and create a PR. Use only these exact commands:
   - **Ready**: `gh pr create --fill`
   - **Draft**: `gh pr create --fill --draft`

   If not specified, ask which one.

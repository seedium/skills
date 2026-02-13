---
name: create-commit
description: This skill should be used when the user asks to "commit", "create a commit", "git commit", "commit my changes", "commit staged changes", "make a conventional commit", "write a commit message", or wants to create a well-formatted conventional commit from staged git changes. Handles branch safety checks, automatic commit type detection, message composition following the conventional commits spec, pre-commit hook failure recovery, and optional PR creation.
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(gh *), Read, Glob
---

# Create Commit

Create a conventional commit from staged changes with branch safety, automatic type detection, and optional PR creation.

## Process

1. **Verify staged changes** — Run `git diff --cached --name-only`. If no files are staged, inform the user and stop.

2. **Load commitlint config** — Search the repository root for a commitlint configuration file. Use Glob to check for these files (in priority order):

   ```
   commitlint.config.{js,cjs,mjs,ts,cts,mts}
   .commitlintrc
   .commitlintrc.{json,yaml,yml,js,cjs,mjs,ts,cts,mts}
   ```

   Also check `package.json` for a `commitlint` field.

   If a config is found, read it and extract all applicable rules:
   - `type-enum` — allowed commit types (overrides the default type table)
   - `scope-enum` — allowed scopes (restricts scope choices)
   - `header-max-length` — max header length (overrides the 72-char default)
   - `subject-case` — required casing for the subject
   - `body-max-line-length` — max line length in the body
   - `body-leading-blank` — whether a blank line is required before the body
   - `footer-leading-blank` — whether a blank line is required before the footer
   - Any other rules defined in the config

   If the config uses `extends` (e.g., `@commitlint/config-conventional`), acknowledge the base ruleset and apply any rule overrides on top.

   If **no config is found**, apply the default constraints defined in the steps below.

3. **Gather context** (run in parallel):
   - `git diff --cached` — full diff of staged changes
   - `git branch --show-current` — current branch name
   - `git log --oneline -5` — recent commits for style consistency

4. **Branch guard** — If on `main` or `master`, ask whether to:
   - Create a new branch (derive name as `<kebab-description>`, max 50 chars), then run `git checkout -b <name>`
   - Continue committing directly to the protected branch

5. **Determine commit type** — If commitlint config defines `type-enum`, only use types from that list. Otherwise, use the default table:

   | Type       | When to use                                           |
   |------------|-------------------------------------------------------|
   | `feat`     | New functionality, new public interfaces              |
   | `fix`      | Bug fixes, corrections preserving existing interfaces |
   | `refactor` | Code restructuring without behavior change            |
   | `chore`    | Tooling, config, dependencies, non-functional changes |
   | `docs`     | Documentation-only changes                            |
   | `style`    | Formatting, whitespace, no logic change               |
   | `test`     | Adding or updating tests                              |
   | `ci`       | CI/CD pipeline changes                                |
   | `perf`     | Performance improvements                              |
   | `revert`   | Reverting a previous commit                           |

6. **Determine scope** — If commitlint config defines `scope-enum`, only use scopes from that list. Otherwise, use a scope when all changes fall within a single logical module, component, or directory. Omit scope when changes span multiple areas or touch root-level config.

7. **Compose the commit message** following the [Conventional Commits](https://www.conventionalcommits.org) specification and all loaded commitlint rules:

   - **Format**: `type(scope): subject` or `type: subject`
   - **Subject rules**:
     - Must contain a **verb and a subject** — the verb describes the action, the subject addresses the area
     - Use present simple, imperative mood (`add` not `adds`/`added`)
     - Start lowercase (unless commitlint `subject-case` requires otherwise)
     - Stay under 72 characters (or the `header-max-length` from commitlint config — note this limit applies to the **entire header** including type, scope, and colon)
     - Be specific and meaningful — the reader must understand what changed without looking at the diff
     - Keep it short — if motivation or context is needed, put it in the body
     - Describe what actually changed, not the meta-task you are working on
   - **Body** (when needed): Explain *what* changed and *why*, note breaking changes or migration steps. Use the body to clarify motivation when the subject alone is insufficient. If commitlint enforces `body-max-line-length`, wrap body lines accordingly.
   - **Blank lines**: Always add a blank line between header and body, and between body and footer (commitlint `body-leading-blank` and `footer-leading-blank` rules enforce this by default).
   - **Exclude from body**: Co-author tags, AI metadata, tool attribution, or process-related notes

   ### Subject quality rules

   **Must have verb + subject (action + area):**
   - Bad: `feat: bearer login functionality` (no verb)
   - Bad: `feat: add` (no subject)
   - Good: `feat: add bearer login functionality`

   **Must be meaningful — reader should understand the change:**
   - Bad: `style: change bunch files` (unclear what changed)
   - Good: `style: format src folder with prettier`
   - Bad: `chore: fix build` (unclear how)
   - Good: `chore: add env var extract plugin`

   **Must address a specific area, not be generic:**
   - Bad: `fix: fix bug` (says nothing)
   - Bad: `fix: fix schema` (still vague)
   - Good: `fix: change first name type in user schema`

   **Keep short — use body for context:**
   - Bad: `feat: add another get user endpoint because first endpoint doesn't return security information for admin`
   - Good:
     ```
     feat: add admin get user endpoint

     The existing endpoint works for simple user, but now admins
     want to get additional information about the user.
     ```

   **Describe actual changes — never the meta-task:**
   - Bad sequence: `chore: final try` → `chore: trying to enable` → `chore: fix` → `chore: fix build`
   - Good sequence: `chore: add extract env plugin` → `chore: remove default env plugin` → `chore: enable cache layer for webpack`
   - Never use words like "trying", "another try", "final fix" — each commit must stand on its own

8. **Present the message** to the user for approval before committing.

9. **Commit** — Execute `git commit` with the approved message using a heredoc:
   ```bash
   git commit -m "$(cat <<'EOF'
   type(scope): subject

   Optional body explaining what and why.
   EOF
   )"
   ```

10. **Handle pre-commit failures** — If the commit fails due to linting or formatting hooks:
   - Analyze the error output
   - Apply targeted fixes to the reported issues
   - Stage fixes with `git add` (specific files only, not `git add .`)
   - Re-attempt the commit
   - Repeat up to 3 times, then report remaining issues to the user

11. **Offer PR creation** (non-main branches only) — After a successful commit, push the branch and ask whether to create a PR:
    - **Create PR** → `gh pr create --fill`
    - **Create draft PR** → `gh pr create --fill --draft`
    - **Skip** → do nothing

## Commit Message Examples

```
feat(auth): add jwt token validation
fix(parser): handle empty input gracefully
refactor: consolidate duplicate helper functions
chore: update terraform provider versions
docs(api): add rate limiting section
test(billing): add edge case coverage for zero amounts
ci: add staging deployment workflow
perf(db): add index on users.email column
feat!: redesign authentication flow

BREAKING CHANGE: OAuth tokens from v1 are no longer valid.
```

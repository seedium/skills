---
name: Create Commit
description: This skill should be used when the user asks to "commit", "create a commit", "git commit", "commit my changes", "commit staged changes", "make a conventional commit", "write a commit message", or wants to create a well-formatted conventional commit from staged git changes. Handles branch safety checks, automatic commit type detection, message composition following the conventional commits spec, pre-commit hook failure recovery, and optional PR creation.
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(gh *)
---

# Create Commit

Create a conventional commit from staged changes with branch safety, automatic type detection, and optional PR creation.

## Process

1. **Verify staged changes** — Run `git diff --cached --name-only`. If no files are staged, inform the user and stop.

2. **Gather context** (run in parallel):
   - `git diff --cached` — full diff of staged changes
   - `git branch --show-current` — current branch name
   - `git log --oneline -5` — recent commits for style consistency

3. **Branch guard** — If on `main` or `master`, ask whether to:
   - Create a new branch (derive name as `<kebab-description>`, max 50 chars), then run `git checkout -b <name>`
   - Continue committing directly to the protected branch

4. **Determine commit type** from the nature of the changes:

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

5. **Determine scope** — Use a scope when all changes fall within a single logical module, component, or directory. Omit scope when changes span multiple areas or touch root-level config.

6. **Compose the commit message**:
   - **Format**: `type(scope): subject` or `type: subject`
   - **Subject**: Start lowercase, use imperative mood (`add` not `adds`/`added`), include a verb and noun, stay under 72 characters
   - **Body** (when needed): Explain *what* changed and *why*, note breaking changes or migration steps
   - **Exclude from body**: Co-author tags, AI metadata, tool attribution, or process-related notes

7. **Present the message** to the user for approval before committing.

8. **Commit** — Execute `git commit` with the approved message using a heredoc:
   ```bash
   git commit -m "$(cat <<'EOF'
   type(scope): subject

   Optional body explaining what and why.
   EOF
   )"
   ```

9. **Handle pre-commit failures** — If the commit fails due to linting or formatting hooks:
   - Analyze the error output
   - Apply targeted fixes to the reported issues
   - Stage fixes with `git add` (specific files only, not `git add .`)
   - Re-attempt the commit
   - Repeat up to 3 times, then report remaining issues to the user

10. **Offer PR creation** (non-main branches only) — After a successful commit, push the branch and ask whether to create a PR:
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

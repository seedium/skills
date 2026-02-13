# Engineering Plugin

Engineering workflow skills for Claude Code.

## Skills

### `/create-commit`

Creates a conventional commit from staged changes. Analyzes your diff, determines the commit type and scope, composes a message, and handles the full commit flow.

**What it does:**

1. Reads staged changes and current branch
2. Guards against accidental commits to `main`/`master` (offers to create a branch)
3. Picks the commit type (`feat`, `fix`, `refactor`, `chore`, etc.) and scope based on the diff
4. Presents the commit message for your approval
5. Runs `git commit` and auto-fixes pre-commit hook failures
6. Optionally pushes and creates a PR via `gh`

**Usage:**

```shell
git add <files>
/create-commit
```

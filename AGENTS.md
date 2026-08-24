# Agentia CLI for AI Agents

Use Agentia to manage Copado user stories end-to-end: pick work, prepare a git branch, push changes, submit for review, and promote.

**Prefer the Agentia MCP server when it is available.** If tools such as `agentia_work_list`, `agentia_work_set`, `agentia_work_commit`, `agentia_work_push`, `agentia_work_submit`, and `agentia_work_done` are registered, call those instead of shelling out to the `agentia` CLI. Fall back to CLI commands only when MCP is not configured.

When using the CLI, prefer `--json` on every command so you can parse structured output instead of terminal tables.

Authentication must already be configured (`agentia auth set` / keychain, or local gateway mode). Run from a git repository that is a Copado-managed project.

## Typical workflow

```text
list → get → set → (implement & commit or cloud commit) → push → submit → done
```

| Step | MCP tool (preferred) | CLI fallback | Purpose |
| --- | --- | --- | --- |
| 1 | `agentia_work_list` (`assignedToMe: true`) | `agentia cicd work list --assigned-to-me --json` | Show user stories assigned to you |
| 2 | `agentia_work_get` | `agentia cicd work get [id] --json` | Read user story details (omit id after `work set`) |
| 3 | `agentia_work_set` | `agentia cicd work set <id> --json` | Mark in progress and prepare the feature branch |
| 4 | *(your edits + `git commit`)* or `agentia_work_commit` | *(your edits + `git commit`)* or `agentia cicd work commit --cloud --json` | Implement the story or create a Copado cloud metadata commit |
| 5 | `agentia_work_push` | `agentia cicd work push --json` | Push local Git commits and register them with Copado |
| 6 | `agentia_work_submit` | `agentia cicd work submit --json` | Flag ready for review (pipeline quality gates / validation) |
| 7 | `agentia_work_done` | `agentia cicd work done --json` | Promote and deploy to the next stage |

Do not skip `work set` before coding. Later steps expect a `feature/<user-story-name>` branch and a recorded base branch from `work set`.

---

## Commands

CLI examples below are the fallback when MCP is unavailable. MCP tool names and arguments mirror these commands (camelCase args instead of flags).

### `agentia cicd work list`

Show user stories. For “assigned to me”, always use:

```sh
agentia cicd work list --assigned-to-me --json
```

Useful filters: `--status`, `--project-name`, `--name`, `--owned-by-me`. Do not combine `--assigned-to-me` with `--owned-by-me` or `--assignee-id`.

### `agentia cicd work get [id]`

Read full details for one user story. After `work set`, omit the ID to use the active work item:

```sh
agentia cicd work get --json
agentia cicd work get a0SKC000000CmZ2AU --json
```

Use this before starting work to understand title, status, acceptance criteria, and related fields.

### `agentia cicd work set <id>`

Flag the user story as the active work item (in progress) and prepare the correct git branch:

```sh
agentia cicd work set a0SKC000000CmZ2AU --json
# or by name:
agentia cicd work set US-0001 --json
```

What it does:

1. Calls Copado to set the work item and resolve the base branch
2. Requires a **clean tracked working tree** (stash or commit first if dirty)
3. Fetches `origin/<base-branch>`
4. Creates or checks out `feature/<user-story-name>`
5. Records the last work item ID, name, and base branch for later commands

Optional: `--base-branch <name>` overrides the base branch from the API.

After success, stay on that feature branch for all implementation commits.

### `agentia cicd work push`

Push committed changes to git and register them with Copado:

```sh
agentia cicd work push --json
```

Prerequisites:

- Current branch is `feature/US-XXXX` (from `work set`)
- No uncommitted tracked changes (commit first)
- `work set` was run so a base branch is recorded

Locks the tip commit, runs `git push origin <branch>`, then registers the commits with Copado.

### `agentia cicd work commit --cloud`

Create a Copado cloud commit job for selected metadata:

```sh
agentia cicd work commit --cloud --message "Commit AccountService" --metadata-name AccountService --metadata-type ApexClass --metadata-category SFDX --json
agentia cicd work commit a0SKC000000CmZ2AU --cloud --file commit-request.json --json
```

Use this when the metadata commit should be performed by Copado rather than by local Git. The command preflights the user story, submits the commit request, and waits for the job by default. For bundled metadata with `SelectiveCommit`, include `--selection` values for the files inside the bundle. MCP uses camelCase fields such as `metadataName`, `metadataType`, `metadataCategory`, `selection`, and `wait`.

### `agentia cicd work test --local`

Run local project quality gates without submitting:

```sh
agentia cicd work test --local --json
agentia cicd work test --local --apex-test-classes=MyTest,OtherTest --json
```

If the project root contains `.agentia_quality_gates.sh` (macOS/Linux) or `.agentia_quality_gates.cmd` (Windows), that script runs and the command stops on failure. Only `--local` is supported for now. Optional `--apex-test-classes=class1,class2` is passed to the script as `AGENTIA_APEX_TEST_CLASSES` (MCP: `apexTestClasses`).

### `agentia cicd work submit`

Flag the user story as ready for review. Runs local project quality gates (when present), then pipeline quality gates and validation:

```sh
agentia cicd work submit --json
agentia cicd work submit --apex-test-classes=MyTest,OtherTest --json
agentia cicd work submit --skip-local-tests --json
```

Same branch/clean-tree rules as `work push`. If the project root contains `.agentia_quality_gates.sh` (macOS/Linux) or `.agentia_quality_gates.cmd` (Windows), that script runs first and submit stops on failure (same local gates as `work test --local`). Use `--apex-test-classes=class1,class2` to pass Apex test classes to the script as `AGENTIA_APEX_TEST_CLASSES` (MCP: `apexTestClasses`). Use `--skip-local-tests` to skip local gates. If the branch has unpushed commits, it pushes and registers them next, then submits.

### `agentia cicd work done`

Promote and deploy the user story to the next pipeline stage:

```sh
agentia cicd work done --json
```

Same branch/clean-tree rules as `work submit`. Pushes unpushed commits if needed, then promotes (without the validate-only path used by submit).

Only run this when the story is approved and ready to move to the next environment.

---

## Agent rules

1. **Prefer MCP over CLI.** When Agentia MCP tools are available, use them instead of running `agentia` in the shell.
2. **Discover before acting.** List assigned stories, then `get` the chosen ID, then `set` before editing files.
3. **One story, one feature branch.** Do not mix unrelated commits on the same `feature/US-XXXX` branch.
4. **Choose the right commit path.** Use normal `git add` / `git commit` followed by `agentia_work_push` for local Git work. Use `agentia_work_commit` / `agentia cicd work commit --cloud` for Copado cloud metadata commits.
5. **Keep the tree clean** before `set`, `push`, `submit`, and `done`. Those steps fail if tracked changes are pending.
6. **Prefer structured results.** MCP returns JSON; for CLI, use `--json` and do not scrape human table output.
7. **Order matters.** `set` → local commit or cloud commit → `push` when local Git commits exist → `submit` → `done`. `submit` and `done` will auto-push if the branch is ahead of origin, but `set` is still required first.
8. **Confirm intent for `done`.** Promotion deploys to the next stage; do not run it unless the user asked to promote/deploy.

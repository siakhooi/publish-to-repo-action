# Publish to Repo Action

![GitHub](https://img.shields.io/github/license/siakhooi/publish-to-repo-action?logo=github)
![GitHub last commit](https://img.shields.io/github/last-commit/siakhooi/publish-to-repo-action?logo=github)
![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/siakhooi/publish-to-repo-action?logo=github)

A GitHub Action that copies files from your workflow workspace into another GitHub repository, then commits and pushes. Typical uses include deploying build artifacts, generated docs, or other outputs to a dedicated repo.

## Installation

This action is available on the [GitHub Marketplace](https://github.com/marketplace/actions/publish-to-repo-action).

## Quick start

### 1. Configure the workflow

Create `.github/workflows/publish.yml`:

```yaml
name: Publish Files
on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Publish to target repo
        uses: siakhooi/publish-to-repo-action@main
        with:
          token: ${{ secrets.PUBLISH_TOKEN }}
```

### 2. Add the config file

Add `publish-to-repo.yml` at the repository root (or set `config-file` to another path):

```yaml
repo: username/target-repo
branch: main
git_commit_user: Deploy Bot
git_commit_email: deploy@example.com
git_commit_message: "chore: Auto deploy"

files:
  - source: "dist/*"
    target: public/
  - source: README.md
    target: docs/README.md
  - source: "build/*.zip"
    target: releases/
```

## Inputs

| Input         | Description                                                             | Required | Default               |
| ------------- | ----------------------------------------------------------------------- | -------- | --------------------- |
| `token`       | GitHub token with `contents:write` on the **target** repository         | **Yes**  | —                     |
| `config-file` | Path to the YAML config file (relative to the repository root)          | No       | `publish-to-repo.yml` |

## Outputs

| Output                | Description                                              |
| --------------------- | -------------------------------------------------------- |
| `commit_sha`          | SHA of the commit that was pushed.                       |
| `committed`           | Whether a commit was made (`true` / `false`).            |
| `changed_files_count` | Number of files changed in that commit.                  |

## Configuration schema

| Field                | Type   | Description                                                                 | Required |
| -------------------- | ------ | --------------------------------------------------------------------------- | -------- |
| `repo`               | string | Target repository as `owner/name`                                         | **Yes**  |
| `branch`             | string | Branch to push to                                                           | **Yes**  |
| `git_commit_user`    | string | Commit author name                                                          | **Yes**  |
| `git_commit_email`   | string | Commit author email                                                         | **Yes**  |
| `git_commit_message` | string | Base message; run metadata is appended automatically                        | **Yes**  |
| `files`              | array  | List of copy mappings                                                       | **Yes**  |
| `files[].source`     | string | Source path or glob, relative to [`$GITHUB_WORKSPACE`](https://docs.github.com/en/actions/learn-github-actions/variables#default-environment-variables) | **Yes**  |
| `files[].target`     | string | Destination path relative to the target repo root (see file mapping below) | **Yes**  |

## File mapping

Paths are interpreted on the Linux runner using bash pathname expansion.

- **Source** — Joined with the workspace root. You may use shell globs (`*`, `?`, `[…]`). If nothing matches, that mapping is skipped (with a log line).
- **Target** — Resolved under the cloned target repo. Whether the destination is treated as a **file** or a **directory** is determined by a **trailing slash**:
  - Ends with **`/`** — directory. Matching items are copied **into** that directory (created if needed).
  - Does **not** end with **`/`** — single file path. The parent directory is created; there must be exactly **one** matching source path (otherwise `cp` cannot combine several sources into one file).

**Multiple matches:** if `source` matches **more than one** path, `target` **must** end with `/`. Otherwise the action fails with a clear error.

Examples:

| Intent | Example `source` | Example `target` |
| ------ | ---------------- | ---------------- |
| One file to one file | `README.md` | `docs/README.md` |
| Many files into a folder | `build/*.js` | `static/js/` |
| One glob that may yield one or many files | `artifact.tgz` or `dist/*.zip` | Use `out/` if multiple zips are possible |

**Spaces in paths:** glob patterns or paths containing spaces are not reliably supported.

**Directories:** each copy uses `cp` without recursive directory semantics. Prefer globs that match the **files** you need (for example under `dist/`) rather than relying on copying a whole directory tree in one mapping.

## Authentication

The token must be allowed to push to the **target** repository (for example a personal access token or a scoped token from the target repo’s settings).

- **`contents:write`** on the target repo is required to push commits.

### Creating a token

1. **Settings** → **Developer settings** → **Personal access tokens** → create a token with access to the target repo (`repo` scope for classic tokens, or fine-grained permissions that include contents write).
2. Store it as an Actions secret on the **source** repo (for example `PUBLISH_TOKEN`).

### Using the token

```yaml
with:
  token: ${{ secrets.PUBLISH_TOKEN }}
```

## Limitations

- Target repository and branch must already exist; they are not created for you.
- Files are only added or updated from your mappings; nothing deletes remote-only files in the target repo.
- Intended for Linux runners (for example `ubuntu-latest`).
- Very large trees or huge files may be slow with a shallow clone; Git LFS objects are not handled specially.

## License

[MIT License](LICENSE) — Copyright (c) 2026 Siak Hooi

---

![GitHub issues](https://img.shields.io/github/issues/siakhooi/publish-to-repo-action?logo=github)
![GitHub closed issues](https://img.shields.io/github/issues-closed/siakhooi/publish-to-repo-action?logo=github)
![GitHub pull requests](https://img.shields.io/github/issues-pr-raw/siakhooi/publish-to-repo-action?logo=github)
![GitHub closed pull requests](https://img.shields.io/github/issues-pr-closed-raw/siakhooi/publish-to-repo-action?logo=github)
![GitHub top language](https://img.shields.io/github/languages/top/siakhooi/publish-to-repo-action?logo=github)

![Release](https://img.shields.io/badge/Release-github-purple)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/siakhooi/publish-to-repo-action?label=GPR%20release&logo=github)
![GitHub Release Date](https://img.shields.io/github/release-date/siakhooi/publish-to-repo-action?logo=github)

[![Wise](https://img.shields.io/badge/Funding-Wise-33cb56.svg?logo=wise)](https://wise.com/pay/me/siakn3)
![visitors](https://hit-tztugwlsja-uc.a.run.app/?outputtype=badge&counter=ghmd-publish-to-repo-action)

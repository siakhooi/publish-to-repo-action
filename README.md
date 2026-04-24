# Publish to Repo Action

![GitHub](https://img.shields.io/github/license/siakhooi/publish-to-repo-action?logo=github)
![GitHub last commit](https://img.shields.io/github/last-commit/siakhooi/publish-to-repo-action?logo=github)
![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/siakhooi/publish-to-repo-action?logo=github)

A GitHub Action that publishes files and directories from your workflow to another GitHub repository. Useful for deploying build artifacts, documentation, or generated files to a separate target repo.

## 📦 Installation

This action is available on the [GitHub Marketplace](https://github.com/marketplace/actions/publish-to-repo-action).

## 🚀 Quick Start

### 1. Configure the Workflow

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
      - name: Publish to Target Repo
        uses: siakhooi/publish-to-repo-action@main
        with:
          token: ${{ secrets.PUBLISH_TOKEN }}
```

### 2. Create Config File

Add `publish-to-repo.yml` to your repository root:

```yaml
repo: username/target-repo
branch: main
git_commit_user: Deploy Bot
git_commit_email: deploy@example.com
git_commit_message: "chore: Auto deploy"

files:
  - source: dist/
    target: public/
  - source: README.md
    target: docs/README.md
```

## 📋 Inputs

| Input         | Description                                                             | Required | Default               |
| ------------- | ----------------------------------------------------------------------- | -------- | --------------------- |
| `token`       | GitHub token with `contents:write` permission for the target repository | **Yes**  | -                     |
| `config-file` | Path to the configuration YAML file                                     | No       | `publish-to-repo.yml` |

## 📤 Outputs

| Output                | Description                                           |
| --------------------- | ----------------------------------------------------- |
| `commit_sha`          | The SHA of the commit that was pushed.                |
| `committed`           | Indicates whether a commit was made (`true`/`false`). |
| `changed_files_count` | Number of files that were changed in the commit.      |

## 🔧 Configuration Schema

The configuration file (`publish-to-repo.yml`) supports the following fields:

| Field                | Type   | Description                                              | Required |
| -------------------- | ------ | -------------------------------------------------------- | -------- |
| `repo`               | string | Target repository in `owner/repo` format                 | **Yes**  |
| `branch`             | string | Target branch name                                       | **Yes**  |
| `git_commit_user`    | string | Git commit author name                                   | **Yes**  |
| `git_commit_email`   | string | Git commit author email                                  | **Yes**  |
| `git_commit_message` | string | Base commit message (timestamp and SHA will be appended) | **Yes**  |
| `files`              | array  | List of file mappings to publish                         | **Yes**  |
| `files[].source`     | string | Source path (relative to `$GITHUB_WORKSPACE`)            | **Yes**  |
| `files[].target`     | string | Target path (relative to target repo root)               | **Yes**  |

### File Mapping Notes

- **Source paths** are resolved relative to the workflow workspace (`$GITHUB_WORKSPACE`)
- **Target paths** are resolved relative to the target repository root
- Supports both individual files and directories
- Directory contents are copied recursively

## 🔐 Authentication

This action requires a GitHub Personal Access Token (PAT) with the following permissions:

- **`contents:write`** - Required to push files to the target repository

### Creating a Token

1. Go to **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Generate a new token with `repo` scope (or `public_repo` for public repos only)
3. Add the token as a repository secret:
   - Go to your source repo → **Settings** → **Secrets and variables** → **Actions**
   - Create a new secret named `PUBLISH_TOKEN` (or any name you prefer)
   - Paste your PAT as the value

### Using the Token

Reference the secret in your workflow:

```yaml
with:
  token: ${{ secrets.PUBLISH_TOKEN }}
```

## ⚠️ Current Limitations

- Target repository must already exist (will not auto-create)
- Target branch must already exist (will not auto-create)
- Does not support deleting files from target repository
- Only supports publishing from Ubuntu/Linux runners
- Large file transfers may be slow due to shallow clone limitations
- No support for Git LFS files

## 📄 License

[MIT License](LICENSE) - Copyright (c) 2026 Siak Hooi

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

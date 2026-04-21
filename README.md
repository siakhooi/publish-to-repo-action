# publish-to-repo-action
github action to publish files to another github repo

## Sample publish-to-repo.yaml

```
repo: username/yyyyy
branch: main
git_commit_user: xxxxxx
git_commit_email: xxxxxx@example.com
git_commit_message: "xxxxxx: Auto deploy"

files:
  - source: /path/in/source
    target: path/in/target
```

## Usage
### Github Workflow File
```
name: Publish Files
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Publish Files
        uses: siakhooi/publish-to-repo-action@main
        with:
          token: ${{ secrets.MYTOKEN }}
```
### `publish-to-repo.yml`
```
repo: username/yyyyy
branch: main
git_commit_user: xxxxxx
git_commit_email: xxxxxx@example.com
git_commit_message: "xxxxxx: Auto deploy"

files:
  - source: /path/in/source
    target: path/in/target
```
## Badges
![GitHub](https://img.shields.io/github/license/siakhooi/publish-to-repo-action?logo=github)
![GitHub last commit](https://img.shields.io/github/last-commit/siakhooi/publish-to-repo-action?logo=github)
![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/siakhooi/publish-to-repo-action?logo=github)
![GitHub issues](https://img.shields.io/github/issues/siakhooi/publish-to-repo-action?logo=github)
![GitHub closed issues](https://img.shields.io/github/issues-closed/siakhooi/publish-to-repo-action?logo=github)
![GitHub pull requests](https://img.shields.io/github/issues-pr-raw/siakhooi/publish-to-repo-action?logo=github)
![GitHub closed pull requests](https://img.shields.io/github/issues-pr-closed-raw/siakhooi/publish-to-repo-action?logo=github)
![GitHub top language](https://img.shields.io/github/languages/top/siakhooi/publish-to-repo-action?logo=github)
![GitHub language count](https://img.shields.io/github/languages/count/siakhooi/publish-to-repo-action?logo=github)
![GitHub repo size](https://img.shields.io/github/repo-size/siakhooi/publish-to-repo-action?logo=github)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/siakhooi/publish-to-repo-action?logo=github)

![Release](https://img.shields.io/badge/Release-github-purple)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/siakhooi/publish-to-repo-action?label=GPR%20release&logo=github)
![GitHub all releases](https://img.shields.io/github/downloads/siakhooi/publish-to-repo-action/total?color=33cb56&logo=github)
![GitHub Release Date](https://img.shields.io/github/release-date/siakhooi/publish-to-repo-action?logo=github)

[![Wise](https://img.shields.io/badge/Funding-Wise-33cb56.svg?logo=wise)](https://wise.com/pay/me/siakn3)
![visitors](https://hit-tztugwlsja-uc.a.run.app/?outputtype=badge&counter=ghmd-publish-to-repo-action)
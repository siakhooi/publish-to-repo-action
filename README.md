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

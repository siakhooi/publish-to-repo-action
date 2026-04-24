#!/usr/bin/env bash

readonly configFile=$1
readonly token=$2

configFilePath=$(realpath "${GITHUB_WORKSPACE}/$configFile")

if [[ ! -f "$configFilePath" ]]; then
	echo "Config file not found: $configFilePath"
	exit 1
fi

if [[ -z "$token" ]]; then
	echo "Token is required"
	exit 1
fi
if [[ -z "$GITHUB_WORKSPACE" ]]; then
	echo "GITHUB_WORKSPACE is not set"
	exit 1
fi
if [[ -z "$GITHUB_OUTPUT" ]]; then
	echo "GITHUB_OUTPUT is not set"
	exit 1
fi
if command -v git &>/dev/null; then
	echo "Git is installed"
else
	echo "Git is not installed."
	exit 1
fi
if command -v yq &>/dev/null; then
	echo "yq is installed"
else
	echo "yq is not installed."
	exit 1
fi

set -euo pipefail

repoBranch=$(yq e '.branch' "$configFilePath")
repo=$(yq e '.repo' "$configFilePath")
repoUrl="https://x-access-token:${token}@github.com/${repo}.git"
gitCommitEmail=$(yq e '."git_commit_email"' "$configFilePath")
gitCommitUser=$(yq e '."git_commit_user"' "$configFilePath")
gitCommitMessage=$(yq e '."git_commit_message"' "$configFilePath")

fullCommitMessage="$gitCommitMessage | ${GITHUB_SHA:0:7} | $(date -u +"%Y-%m-%dT%H:%M:%SZ")"

# Check if .files array is empty or missing
files_count=$(yq e '.files | length' "$configFilePath")
if [[ -z "$files_count" || "$files_count" -eq 0 ]]; then
	echo ".files array is empty or missing in config file: $configFilePath"
	exit 1
fi

workingDirectory=$(mktemp -d)

git clone --depth=1 --branch "$repoBranch" "$repoUrl" "$workingDirectory"

cd "$workingDirectory" || {
	echo "Failed to change directory to $workingDirectory"
	exit 1
}

yq -r '.files[] | "\(.source) \(.target)"' "$configFilePath" | while read -r sourcePath targetPath; do
	echo "Source: $sourcePath, Target: $targetPath"

	# source path always relative to $GITHUB_WORKSPACE, /* means relative to $GITHUB_WORKSPACE
	srcPath=$(realpath "${GITHUB_WORKSPACE}/$sourcePath")

	# target path always relative to repo root, /* means relative to repo root
	tgtPath=$(realpath -m "$PWD/$targetPath")

	echo "Source: $srcPath"
	echo "Target: $tgtPath"

	if [[ -f "$srcPath" ]]; then
		mkdir -p "$(dirname "$tgtPath")"
		echo "Source is a file, copying to $tgtPath"
		cp -v "$srcPath" "$tgtPath"

	elif [[ -d "$srcPath" ]]; then
		echo "Source is a directory, copying contents"
		mkdir -p "$tgtPath"
		cp -rv "$srcPath/." "$tgtPath/"

	else
		echo "Source path does not exist: $srcPath"
		exit 1
	fi
done
git config user.email "$gitCommitEmail"
git config user.name "$gitCommitUser"

git add --all
git status
if git diff --cached --quiet; then
	echo "No changes to commit"
	{
		echo "committed=false"
		echo "changed_files_count=0"
	} >>"$GITHUB_OUTPUT"
	exit 1
fi
changed_files_count=$(git diff --cached --name-only | wc -l)

git remote set-url origin "$repoUrl"
git commit -m "$fullCommitMessage"
git push origin "$repoBranch"

echo "Committed changes to $repoBranch branch of $repo repository. Changed files: $changed_files_count"

COMMIT_SHA=$(git rev-parse HEAD)

{
	echo "commit_sha=$COMMIT_SHA"
	echo "committed=true"
	echo "changed_files_count=$changed_files_count"
} >>"$GITHUB_OUTPUT"

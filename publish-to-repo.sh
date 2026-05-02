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

for ((i = 0; i < files_count; i++)); do
	sourcePath=$(yq e ".files[$i].source" "$configFilePath")
	targetPath=$(yq e ".files[$i].target" "$configFilePath")
	items_raw=$(yq e ".files[$i].items" "$configFilePath")

	echo "Source: $sourcePath, Target: $targetPath"

	shopt -s nullglob
	# shellcheck disable=SC2206
	matches=("$GITHUB_WORKSPACE"/$sourcePath)
	shopt -u nullglob
	match_count=${#matches[@]}

	if [[ "$items_raw" != "null" && -n "$items_raw" ]]; then
		if ! [[ "$items_raw" =~ ^[0-9]+$ ]]; then
			echo "Invalid items for files[$i]: expected a non-negative integer, got: $items_raw"
			exit 1
		fi
		if [[ "$match_count" -ne "$items_raw" ]]; then
			echo "files[$i]: items is $items_raw but source \"$sourcePath\" matched $match_count item(s)"
			exit 1
		fi
	fi

	if [[ $match_count -eq 0 ]]; then
		echo "No files matched the pattern: $sourcePath"
		continue
	fi

	if [[ $match_count -gt 1 ]]; then
		if [[ ! "$targetPath" == */ ]]; then
			echo "Multiple files matched the pattern: $sourcePath, but target path does not end with /"
			exit 1
		fi
	fi

	tgtPath=$(realpath -m "$PWD/$targetPath")
	if [[ "$targetPath" == */ ]]; then
		mkdir -p "$tgtPath"
		for src in "${matches[@]}"; do
			echo "Copying $src to $tgtPath"
			if [[ -d "$src" ]]; then
				cp -vr "$src" "$tgtPath"
			else
				cp -v "$src" "$tgtPath"
			fi
		done
	else
		mkdir -p "$(dirname "$tgtPath")"
		cp -v "${matches[@]}" "$tgtPath"
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

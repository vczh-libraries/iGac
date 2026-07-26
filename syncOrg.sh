#!/usr/bin/env bash

set -u -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ORGANIZATION="vczh-libraries"
REPOSITORIES=(
    Vlpp
    VlppOS
    VlppRegex
    VlppReflection
    VlppParser2
    Workflow
    GacUI
    GacJS
    Release
    Tools
)

red_error() {
    printf '\033[31mERROR: %s\033[0m\n' "$*" >&2
}

resolve_git() {
    if command -v git >/dev/null 2>&1 && git --version >/dev/null 2>&1; then
        GIT="$(command -v git)"
        return 0
    fi

    local desktop_root="/Applications/GitHub Desktop.app/Contents/Resources/app/git"
    if [[ -x "$desktop_root/bin/git" ]]; then
        GIT="$desktop_root/bin/git"
        export GIT_EXEC_PATH="$desktop_root/libexec/git-core"
        export GIT_TEMPLATE_DIR="$desktop_root/share/git-core/templates"
        export PATH="$desktop_root/bin:$PATH"
        return 0
    fi

    red_error "Git is unavailable. Install Git or GitHub Desktop before running this script."
    return 1
}

has_unpushed_commits() {
    local repo_path="$1"
    local repo="$2"
    local ahead_count

    if ! "$GIT" -C "$repo_path" show-ref --verify --quiet refs/remotes/origin/master; then
        red_error "$repo has no origin/master reference; unpushed commits cannot be verified."
        return 0
    fi

    if ! ahead_count="$("$GIT" -C "$repo_path" rev-list --count refs/remotes/origin/master..HEAD)"; then
        red_error "$repo could not be checked for unpushed commits."
        return 0
    fi

    if [[ "$ahead_count" -ne 0 ]]; then
        red_error "$repo has $ahead_count unpushed commit(s)."
        return 0
    fi

    return 1
}

sync_repository() {
    local repo="$1"
    local repo_path="$ROOT_DIR/$repo"
    local repo_url="https://github.com/$ORGANIZATION/$repo.git"
    local top_level
    local branch
    local tracked_changes
    local untracked_files

    printf '\n==> %s\n' "$repo"

    if [[ ! -e "$repo_path" ]]; then
        printf 'Cloning %s\n' "$repo_url"
        if ! "$GIT" clone "$repo_url" "$repo_path"; then
            red_error "$repo could not be cloned; continuing with the next repository."
            return 1
        fi
    elif [[ ! -d "$repo_path" ]]; then
        red_error "$repo_path exists but is not a directory; continuing with the next repository."
        return 1
    fi

    if ! top_level="$("$GIT" -C "$repo_path" rev-parse --show-toplevel 2>/dev/null)"; then
        red_error "$repo_path is not a Git repository; continuing with the next repository."
        return 1
    fi

    if [[ "$top_level" != "$repo_path" ]]; then
        red_error "$repo_path is not the root of its Git repository; continuing with the next repository."
        return 1
    fi

    if ! branch="$("$GIT" -C "$repo_path" symbolic-ref --quiet --short HEAD 2>/dev/null)"; then
        red_error "$repo is in detached HEAD state; continuing with the next repository."
        return 1
    fi

    if [[ "$branch" != "master" ]]; then
        red_error "$repo is on branch '$branch', not 'master'; continuing with the next repository."
        return 1
    fi

    if ! tracked_changes="$("$GIT" -C "$repo_path" status --porcelain --untracked-files=no)"; then
        red_error "$repo could not be checked for uncommitted files; continuing with the next repository."
        return 1
    fi

    if [[ -n "$tracked_changes" ]]; then
        red_error "$repo has uncommitted tracked files; continuing with the next repository."
        return 1
    fi

    if ! untracked_files="$("$GIT" -C "$repo_path" ls-files --others --exclude-standard)"; then
        red_error "$repo could not be checked for untracked files; continuing with the next repository."
        return 1
    fi

    if [[ -n "$untracked_files" ]]; then
        red_error "$repo has untracked files; continuing with the next repository."
        return 1
    fi

    if has_unpushed_commits "$repo_path" "$repo"; then
        red_error "Skipping $repo and continuing with the next repository."
        return 1
    fi

    if ! "$GIT" -C "$repo_path" fetch; then
        red_error "$repo could not be fetched; continuing with the next repository."
        return 1
    fi

    # Fetch can reveal that the local branch contains commits not present on the
    # current remote branch, so check again before allowing pull to create a merge.
    if has_unpushed_commits "$repo_path" "$repo"; then
        red_error "Skipping $repo after fetch and continuing with the next repository."
        return 1
    fi

    if ! "$GIT" -C "$repo_path" pull origin master; then
        red_error "$repo could not be pulled; continuing with the next repository."
        return 1
    fi

    printf '%s is synchronized.\n' "$repo"
    return 0
}

if ! resolve_git; then
    exit 1
fi

failed=0
for repo in "${REPOSITORIES[@]}"; do
    if ! sync_repository "$repo"; then
        failed=1
    fi
done

printf '\n'
if [[ "$failed" -ne 0 ]]; then
    red_error "One or more repositories were not synchronized."
    exit 1
fi

printf 'All repositories are synchronized.\n'

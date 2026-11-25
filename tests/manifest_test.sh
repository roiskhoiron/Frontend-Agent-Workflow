#!/usr/bin/env bash
source "$(dirname "$0")/lib.sh"
REPO="$(cd "$(dirname "$0")/.." && pwd -P)"
M="$REPO/bin/manifest-check.sh"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT

# --- manifest-check ---
G="$T/repo"; mkdir "$G"; cd "$G" || exit 1
git init -q . && git config user.email t@t && git config user.name t
git commit -q --allow-empty -m init; git tag base
git commit -q --allow-empty -m "PROJ-1 fix"
git commit -q --allow-empty -m "feat" -m "body mentions PROJ-2 and UTF-8 and OTHER-9"
assert_exit 0 "manifest equal" -- "$M" base HEAD PROJ-1 PROJ-2
assert_exit 0 "manifest args lowercase ok" -- "$M" base HEAD proj-1 proj-2
out=$("$M" base HEAD PROJ-1); rc=$?
assert_eq "1" "$rc" "branch has extra -> exit 1"
case "$out" in *"di branch tapi tidak di manifest"*PROJ-2*) r=ok;; *) r=no;; esac; assert_eq ok "$r" "extra listed"
case "$out" in *"di manifest tapi tidak di branch"*) r=no;; *) r=ok;; esac; assert_eq ok "$r" "empty list not printed"
out=$("$M" base HEAD PROJ-1 PROJ-2 PROJ-3); rc=$?
assert_eq "1" "$rc" "manifest has extra -> exit 1"
case "$out" in *"di manifest tapi tidak di branch"*PROJ-3*) r=ok;; *) r=no;; esac; assert_eq ok "$r" "missing listed"
out=$("$M" base HEAD PROJ-1 PROJ-2); case "$out" in *UTF-8*|*OTHER-9*) r=no;; *) r=ok;; esac
assert_eq ok "$r" "foreign prefixes ignored"
git commit -q --allow-empty -m "PROJ-12 only"
out=$("$M" base HEAD PROJ-1 PROJ-2); case "$out" in *PROJ-12*) r=ok;; *) r=no;; esac
assert_eq ok "$r" "PROJ-12 not matched as PROJ-1"
assert_exit 0 "PROJ-1 PROJ-2 PROJ-12 exact" -- "$M" base HEAD PROJ-1 PROJ-2 PROJ-12
git commit -q --allow-empty -m "PROJ-1 again"
assert_exit 0 "duplicates deduped" -- "$M" base HEAD PROJ-1 PROJ-2 PROJ-12
assert_exit 2 "invalid ref" -- "$M" nope HEAD PROJ-1
assert_exit 2 "no manifest keys" -- "$M" base HEAD
assert_exit 2 "too few args" -- "$M" base

[ "$FAILS" -eq 0 ] || { echo "$FAILS failures"; exit 1; }

#!/usr/bin/env bash
# Skill flow vs skill internal (rancangan "Skill set di tiap flow"):
# - tiap SKILL.md punya name = nama folder dan description;
# - skill flow hanya merujuk skill internal yang ada, dan tiap skill internal dipakai minimal satu flow;
# - skill internal tidak saling memanggil (tidak menyebut /<skill internal lain>).
source "$(dirname "$0")/lib.sh"
REPO="$(cd "$(dirname "$0")/.." && pwd -P)"
FLOWS="validate-tiket develop-tiket rilis-tiket branch-manager audit-issue"
fm() { awk -v k="$2" 'NR==1&&$0!="---"{exit} NR>1&&$0=="---"{exit} NR>1&&index($0,k": ")==1{print substr($0,length(k)+3)}' "$1"; }
is_flow() { case " $FLOWS " in *" $1 "*) return 0;; esac; return 1; }

internal=()
for d in "$REPO"/skills/*/; do
  n=$(basename "$d"); [ "$n" = _shared ] && continue
  f="$d/SKILL.md"
  assert_eq yes "$([ -f "$f" ] && echo yes || echo no)" "$n: SKILL.md ada"
  [ -f "$f" ] || continue
  assert_eq "$n" "$(fm "$f" name)" "$n: name sama dengan folder"
  assert_eq yes "$([ -n "$(fm "$f" description)" ] && echo yes || echo no)" "$n: description"
  is_flow "$n" || internal+=("$n")
done
for n in $FLOWS; do
  assert_eq yes "$([ -f "$REPO/skills/$n/SKILL.md" ] && echo yes || echo no)" "flow /$n ada"
done

# /nama sebagai kata utuh (bukan bagian path seperti a/b/nama atau /nama-lain)
refs() { grep -oE '(^|[^A-Za-z0-9_./-])/[a-z][a-z0-9-]+' "$1" | sed -E 's#^.*/##' | sort -u; }

# daftar skill internal menurut rancangan (dokumen "Draft: Agent Workflow Delivery Frontend Web")
DESIGN="setup-board setup-docs read-ticket sync-docs reproduce-browser check-contract find-related write-report post-decision
gate-validation setup-worktree matrix-env write-plan mock-api implement-tdd review-code test-browser check-a11y deploy-preview open-pr post-summary move-ticket
read-feedback deploy-variant audit-pr release-trace run-regression write-release-notes prepare-release-pr smoke-live tag-release
split-questions trace-code compare-attachments"
for n in $DESIGN; do
  assert_eq yes "$([ -f "$REPO/skills/$n/SKILL.md" ] && echo yes || echo no)" "skill internal rancangan /$n ada"
done
assert_eq "$(echo $DESIGN | wc -w | tr -d ' ')" "${#internal[@]}" "jumlah skill internal sama dengan rancangan"

used=""
for n in $FLOWS; do
  f="$REPO/skills/$n/SKILL.md"; [ -f "$f" ] || continue
  for r in $(refs "$f"); do
    for i in "${internal[@]}"; do [ "$r" = "$i" ] && used="$used $r"; done
  done
done
for i in "${internal[@]}"; do
  assert_eq yes "$(case " $used " in *" $i "*) echo yes;; *) echo no;; esac)" "/$i dipakai skill flow"
  bad=""
  for r in $(refs "$REPO/skills/$i/SKILL.md"); do
    [ "$r" = "$i" ] && continue
    for j in "${internal[@]}"; do [ "$r" = "$j" ] && bad="$bad $r"; done
  done
  assert_eq "" "${bad# }" "/$i tidak memanggil skill internal lain"
done

echo "skills_test FAILS=$FAILS"; exit $FAILS

#!/usr/bin/env bash
# Set up a laptop from this repo.
#
# Safe to re-run on a partly set-up machine: anything already in place is left
# alone, and anything that conflicts is skipped with a warning instead of being
# overwritten. Nothing is deleted except a copy that is identical to the repo
# version (which is replaced with a symlink to it).
#
# Usage: ./install.sh [--dry-run]

# No `set -e`: one failed step shouldn't stop the rest. No `set -u`: macOS
# ships bash 3.2, which treats empty arrays as unbound.
set -o pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DRY_RUN=0
case "${1:-}" in
  -n|--dry-run) DRY_RUN=1 ;;
  "") ;;
  *) echo "usage: $0 [--dry-run]" >&2; exit 2 ;;
esac

MARKETPLACES=(anthropics/claude-plugins-official)
PLUGINS=(superpowers@claude-plugins-official)

WARNINGS=()
say()  { printf '\n\033[1;34m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
skip() { printf '  \033[33m-\033[0m %s\n' "$*"; }
warn() { printf '  \033[31m!\033[0m %s\n' "$*"; WARNINGS+=("$*"); }
run()  { if [ "$DRY_RUN" = 1 ]; then printf '  [dry-run] %s\n' "$*"; else "$@"; fi; }

# link <path in repo> <destination>
# Symlinks dst -> repo file. Leaves dst alone if it differs from the repo copy.
link() {
  local src="$REPO/$1" dst="$2"
  if [ ! -e "$src" ]; then
    warn "$1 is missing from the repo"
    return
  fi
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    ok "$dst"
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if diff -rq "$src" "$dst" >/dev/null 2>&1; then
      run rm -rf "$dst" # identical to the repo copy, so nothing is lost
    else
      warn "$dst differs from the repo; left alone (compare: diff -ru $dst $src)"
      return
    fi
  fi
  [ -d "$(dirname "$dst")" ] || run mkdir -p "$(dirname "$dst")"
  run ln -s "$src" "$dst" && ok "$dst -> $src"
}

install_brew_bundle() {
  say "Homebrew"
  if ! command -v brew >/dev/null 2>&1 && [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  if ! command -v brew >/dev/null 2>&1; then
    warn "Homebrew isn't installed; skipped the Brewfile. Install it from https://brew.sh, then re-run."
    return
  fi

  # Apps installed outside brew (by hand, or by IT) make `brew install --cask`
  # fail, so skip any cask whose app is already in /Applications.
  local casks installed info skipped="" token app
  casks=$(sed -nE 's/^cask "([^"]+)".*/\1/p' "$REPO/Brewfile")
  installed=$(brew list --cask -1 2>/dev/null)
  if command -v jq >/dev/null 2>&1; then
    # shellcheck disable=SC2086 # word-splitting the cask list is intended
    info=$(brew info --cask --json=v2 $casks 2>/dev/null)
    for token in $casks; do
      printf '%s\n' "$installed" | grep -qxF "$token" && continue
      while IFS= read -r app; do
        if [ -n "$app" ] && [ -e "/Applications/$app" ]; then
          skipped="$skipped $token"
          break
        fi
      done < <(jq -r --arg t "$token" \
        '.casks[] | select(.token == $t) | .artifacts[] | .app? // empty | .[] | strings' <<<"$info")
    done
  else
    skip "jq not found; can't detect apps installed outside brew, so some casks may fail"
  fi
  if [ -n "$skipped" ]; then
    skip "already in /Applications, not managed by brew:$skipped"
    skip "(to hand one over to brew: brew install --cask --adopt <name>)"
  fi

  if [ "$DRY_RUN" = 1 ]; then
    HOMEBREW_BUNDLE_CASK_SKIP="$skipped" brew bundle check --verbose --no-upgrade --file="$REPO/Brewfile" \
      | sed 's/^/  [dry-run] /'
    return
  fi
  if HOMEBREW_BUNDLE_CASK_SKIP="$skipped" brew bundle install --no-upgrade --file="$REPO/Brewfile"; then
    ok "Brewfile installed"
  else
    warn "brew bundle reported failures (see above); the remaining entries were still installed"
  fi
}

link_dotfiles() {
  say "Dotfiles"
  local f
  for f in .profile .bashrc .gitconfig .gitignore_global .vimrc; do
    link "$f" "$HOME/$f"
  done
  [ -d "$HOME/.ssh" ] || run mkdir -m 700 "$HOME/.ssh"
  link .ssh/config "$HOME/.ssh/config"
}

link_executables() {
  say "Executables"
  # ~/.local/bin is put on PATH by .profile
  link notify "$HOME/.local/bin/notify"
}

# ~/.claude/CLAUDE.md stays a local file for machine-specific instructions;
# it imports the portable ones from the repo.
ensure_claude_md_import() {
  local f="$HOME/.claude/CLAUDE.md" line='@~/.claude/CLAUDE.personal.md'
  if [ -f "$f" ] && grep -qxF "$line" "$f"; then
    ok "$f imports CLAUDE.personal.md"
    return
  fi
  if [ "$DRY_RUN" = 1 ]; then
    printf '  [dry-run] append %s to %s\n' "$line" "$f"
    return
  fi
  # don't glue the import onto a last line that lacks a newline
  if [ -s "$f" ] && [ -n "$(tail -c1 "$f")" ]; then
    echo >>"$f"
  fi
  printf '%s\n' "$line" >>"$f" && ok "added '$line' to $f"
}

# Deep-merge settings.base.json into ~/.claude/settings.json. Values already in
# settings.json win, and arrays (e.g. permissions.allow) are unioned, so
# re-running never undoes a local change.
merge_claude_settings() {
  local f="$HOME/.claude/settings.json" base="$REPO/claude/settings.base.json" merged
  if ! command -v jq >/dev/null 2>&1; then
    warn "jq not found; skipped merging settings.base.json"
    return
  fi
  if [ ! -f "$f" ]; then
    run cp "$base" "$f" && ok "created $f"
    return
  fi
  merged=$(jq -s '
    def merge($a; $b):
      if ($a | type) == "object" and ($b | type) == "object" then
        reduce (($a + $b) | keys_unsorted[]) as $k ({};
          .[$k] = if ($a | has($k)) and ($b | has($k)) then merge($a[$k]; $b[$k])
                  elif ($a | has($k)) then $a[$k]
                  else $b[$k] end)
      elif ($a | type) == "array" and ($b | type) == "array" then $a + ($b - $a)
      else $a end;
    merge(.[0]; .[1])' "$f" "$base") || {
    warn "couldn't parse $f; left alone"
    return
  }
  if [ "$merged" = "$(jq . "$f")" ]; then
    ok "$f already has the base settings"
    return
  fi
  if [ "$DRY_RUN" = 1 ]; then
    printf '  [dry-run] would merge into %s:\n' "$f"
    diff <(jq . "$f") <(printf '%s\n' "$merged") | sed 's/^/    /'
    return
  fi
  local backup
  backup="$f.bak.$(date +%Y%m%d%H%M%S)"
  cp "$f" "$backup" && printf '%s\n' "$merged" >"$f" && ok "merged base settings into $f (backup: $backup)"
}

install_claude_plugins() {
  if ! command -v claude >/dev/null 2>&1; then
    warn "claude CLI not found; skipped plugins. Install it (curl -fsSL https://claude.ai/install.sh | bash), then re-run."
    return
  fi
  if [ "$DRY_RUN" = 1 ]; then
    printf '  [dry-run] claude plugin marketplace add %s\n' "${MARKETPLACES[@]}"
    printf '  [dry-run] claude plugin install %s --scope user\n' "${PLUGINS[@]}"
    return
  fi
  # both commands exit 0 when the marketplace/plugin is already there
  local m p
  for m in "${MARKETPLACES[@]}"; do
    if claude plugin marketplace add "$m" >/dev/null; then ok "marketplace $m"; else warn "couldn't add marketplace $m"; fi
  done
  for p in "${PLUGINS[@]}"; do
    if claude plugin install "$p" --scope user >/dev/null; then ok "plugin $p"; else warn "couldn't install plugin $p"; fi
  done
}

setup_claude() {
  say "Claude Code"
  local dir="$HOME/.claude" s
  [ -d "$dir" ] || run mkdir -p "$dir"
  link claude/keybindings.json "$dir/keybindings.json"
  link claude/CLAUDE.md "$dir/CLAUDE.personal.md"
  ensure_claude_md_import
  for s in "$REPO"/claude/skills/*/; do
    s=$(basename "$s")
    link "claude/skills/$s" "$dir/skills/$s"
    # other agents (Codex, Gemini, Cursor) read ~/.agents/skills, if it's in use
    [ -d "$HOME/.agents/skills" ] && link "claude/skills/$s" "$HOME/.agents/skills/$s"
  done
  merge_claude_settings
  install_claude_plugins
}

[ "$DRY_RUN" = 1 ] && echo "Dry run: nothing will be changed."
install_brew_bundle
link_dotfiles
link_executables
setup_claude

say "Done"
if [ ${#WARNINGS[@]} -eq 0 ]; then
  ok "no warnings"
else
  for w in "${WARNINGS[@]}"; do printf '  \033[31m!\033[0m %s\n' "$w"; done
fi

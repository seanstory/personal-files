# Personal preferences
set -o vi
alias ls="ls -G"
alias ll="ls -lah"
alias gitl="git log --branches --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
export LSCOLORS="exfxcxdxbxegedabagacad"
export MAVEN_OPTS='-Xmx3g'

# Homebrew (Apple silicon)
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# User-local binaries (Claude Code, uv, etc. install here)
export PATH="$HOME/.local/bin:$PATH"

# Machine-specific settings and secrets stay out of this repo
[ -f "$HOME/.profile.local" ] && . "$HOME/.profile.local"

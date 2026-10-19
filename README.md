# personal-files
Just my settings files, the way I like them

### Setup

```sh
./install.sh --dry-run   # see what would change
./install.sh
```

Safe to re-run on a partly set-up machine. It:

1. Installs the `Brewfile` with `brew bundle --no-upgrade`. Casks whose app is already in `/Applications` (installed by hand or by IT) are skipped; hand one over to brew with `brew install --cask --adopt <name>`. Skipped entirely if Homebrew isn't installed.
2. Symlinks the dotfiles (`.profile`, `.bashrc`, `.gitconfig`, `.gitignore_global`, `.vimrc`, `.ssh/config`) into `~`.
3. Symlinks the executables (`notify`) into `~/.local/bin`.
4. Sets up Claude Code:
   - links `claude/keybindings.json` and the `claude/skills/*` into `~/.claude/` (and `~/.agents/skills/`, if that exists)
   - links `claude/CLAUDE.md` to `~/.claude/CLAUDE.personal.md` and adds an `@~/.claude/CLAUDE.personal.md` import to `~/.claude/CLAUDE.md`, which stays a local file for machine- or employer-specific instructions
   - deep-merges `claude/settings.base.json` into `~/.claude/settings.json`. Existing values win and arrays are unioned; a timestamped backup is written first.
   - adds the official plugin marketplace and installs `superpowers`

A destination that already exists and differs from the repo copy is **left alone**, with a warning and a `diff` command to compare. A destination identical to the repo copy is replaced with a symlink to it.

Machine-specific shell settings and secrets go in `~/.profile.local`, which `.profile` sources if it exists.

### Claude Code statusline

Not in this repo. Options:
- `/statusline <description of what you want>` in Claude Code generates a script and wires it into settings ([docs](https://code.claude.com/docs/en/statusline.md)).
- Community presets: [ccstatusline](https://github.com/sirmalloc/ccstatusline), [starship-claude](https://github.com/martinemde/starship-claude).

### Executables
* `notify <command>` runs the command, then shows a macOS notification when it finishes. `install.sh` links it into `~/.local/bin`.

### Resume

Run `make resume` to build `resume.pdf` from `resume/resume.html`.

- `resume/pool.yaml` — the source of truth: every role, accomplishment, project, publication, and skill, each with dates, tags, and a description. Much broader than any one resume. Public repo, so public-safe content only.
- `resume/template.html` — skeleton for agents generating a tailored resume from the pool plus a job description.
- `resume/resume.html` — the general resume; also the worked example of a filled-in template.
- `resume/out/` — gitignored; put tailored variants here and print with `make resume HTML=resume/out/<name>.html` (writes `resume/out/<name>.pdf`).

**Requires:** Chrome or Chromium. Checks for `chromium` or `google-chrome` on PATH, then falls back to `/Applications/Google Chrome.app` on macOS.

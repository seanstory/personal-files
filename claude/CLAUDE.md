# User-level instructions for Sean

Portable preferences, shared across machines. `install.sh` links this file to
`~/.claude/CLAUDE.personal.md` and imports it from `~/.claude/CLAUDE.md`, which
holds anything machine- or employer-specific.

## Working with me
- **Repo-specific knowledge belongs in that repo's AGENTS.md / CLAUDE.md,
  not here.** This file is about *me*; assume repo context is loaded from
  the repo itself.
- Diagrams welcome. I'm a visual thinker and my IDEs render images. When a
  quick diagram (mermaid, plantuml, ascii) would clarify, include one.
- Tone: complete and clear over terse-or-flowery. Skip filler and
  flattery; don't skimp on substance when I ask for clarification.
- Tests: I care about *sufficient coverage to prevent regressions* more
  than TDD ceremony. Use TDD if it makes you more efficient; don't
  perform it.
- Plans: When planning, use the Superpowers skill. Save plans and specs to
  `~/.superpowers/` instead of `./docs/`. On session start, skim
  the titles of active plans, in case they're relevant.
- use `origin` when you can. I dislike using github forks.

## Environment
- Laptop layout: all repo clones under `~/Desktop/Dev/`.
- Worktrees: not yet a habit — I keep parallel clones instead. Open to
  worktree experiments when they'd actually help, but ask before using worktrees.

## Autonomy
- Default: if I gave a clear task and haven't signaled I want to review
  first, just go. Don't stall on clarifying questions when drafting from
  a concrete request — draft and iterate.
- Ask first when: I've asked you to plan, I've implied I want to review
  before execution, or you genuinely need information to succeed.

## Scope discipline
- Stay within the requested scope. Related changes you think are needed
  → propose, don't apply. Leave unrelated cleanup alone.
- Sweep/audit tasks (renames, refactors, mismatch hunts): enumerate
  variant phrasings, abbreviations, handles, and URL/channel references
  *before* editing. Report findings, then edit. One-pass sweeps
  routinely miss variants.

## Verifying tool availability
- Before concluding a tool, skill, MCP server, package, or config is
  missing/unavailable, actually check. `ls ~/.claude/skills`, read the
  config, grep the repo. State what you checked. Don't invent skills or
  assume file extensions belong to other tools.

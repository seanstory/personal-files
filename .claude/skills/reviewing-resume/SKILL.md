---
name: reviewing-resume
description: Use when reviewing, critiquing, or proofreading a resume or CV, when a resume feels wordy, generic, or AI-written, or after generating a tailored resume under resume/out/ and before reporting it.
---

# Reviewing a resume

## Overview

Three readers judge a resume, in order: a recruiter skimming for a fit/no-fit
call, a hiring manager checking depth and level, and anyone who has read enough
machine-written prose to spot it. Review as each of them, separately, then
merge. Reviewers find problems and propose fixes; they don't rewrite the page.

## Inputs

- The resume HTML and its built PDF (reviewers check what lands on page 1).
- The job description.
- `resume/pool.yaml`: the ceiling for every claim, including proposed fixes.
- `resume/resume.html`: the density baseline.
- **The candidate's stated priorities** from the conversation (for example,
  "show more staff-level leadership", "less crawler-heavy"). Quote them
  verbatim in every reviewer brief. If there are none, write "none stated".

## Steps

1. Run the mechanical checks on the resume and on the baseline:
   ```bash
   python3 .claude/skills/reviewing-resume/lint.py resume/out/<name>.html
   python3 .claude/skills/reviewing-resume/lint.py resume/resume.html
   swift .claude/skills/reviewing-resume/pdftext.swift resume/out/<name>.pdf
   ```
   The last prints the PDF's text page by page. Include where page 1 ends in
   every brief, so reviewers don't need PDF tools of their own.
2. Dispatch the three reviewers in `reviewers.md` as parallel subagents. Each
   brief contains: the reviewer's section from `reviewers.md`, the input paths,
   the candidate's priorities, both lint outputs, the output contract below, and
   "read-only: do not edit files".
3. Merge the three reports for the user:
   - Findings raised by two or more reviewers first.
   - Where reviewers conflict, the candidate's stated priorities decide; name
     the conflict.
   - Drop any fix the pool doesn't support, or move it to "pool gaps".
   - Keep the "keep" lists: they stop the next revision from sanding off what
     works.
4. Apply fixes when the user asked for revisions or when tailoring-resume
   called this skill; otherwise report them. Rebuild and recount pages after
   applying.
5. When iterating, each later round's briefs add a "Settled, do not raise"
   list (the user's answers and the suggestions already declined) and say that
   a short or empty findings list is a valid result. Stop when every reviewer
   would advance the candidate and the remaining findings conflict with
   another reviewer's "keep" list or the candidate's priorities.

## Reviewer output contract

Each reviewer returns, in this order:

1. **Verdict:** one sentence on what this reader concludes.
2. **Findings:** at most 8, most damaging first. Each has a location (summary,
   skills, or bullet text), the problem, the effect on this reader, and a
   concrete fix written within the pool. A fix that adds words names what it
   cuts to pay for them.
3. **Keep:** up to 5 things that work and should survive revision.

## Guarding against overfitting

- The candidate's priorities outrank any reviewer's taste.
- One lint hit is a fact, not a finding. A pattern across bullets is a finding.
- The aim is plain, specific writing. Swapping flagged words for synonyms
  without making the sentence more concrete fixes nothing (Wikipedia's guide
  warns that treating its signs as the problems "could just make detection
  harder").
- The page length is fixed. Net additions are not fixes.

## Sources

The research behind `reviewers.md`:

- TheLadders, "Keeping an eye on recruiter behavior" (eye-tracking, 2012):
  ~6 seconds for the initial fit/no-fit call; ~80% of that time on six data
  points (name, current and previous titles and companies, their dates,
  education); the rest a keyword scan; explanatory detail "became filler" for
  the initial decision; resumes with clear hierarchy and less data rated far
  easier to read. Vendor study, n=30: directional, not precise.
  https://www.bu.edu/com/files/2018/10/TheLadders-EyeTracking-StudyC2.pdf
- Yale OCS, "Writing impactful resume bullets": Action + Project + Result, and
  "Accomplished X as measured by Y by doing Z"; quantify with a baseline;
  weak bullets describe activities, not outcomes.
  https://ocs.yale.edu/resources/writing-impactful-resume-bullets/
- MIT CAPD, "Crafting an effective resume": start bullets with the verb or
  skill so skimmers catch it; most important first; no pronouns; avoid jargon
  for non-specialist readers; review AI suggestions critically.
  https://capd.mit.edu/resources/career-toolkit-crafting-an-effective-resume/
- Tech Interview Handbook, resume guide: a few best achievements beat many
  average ones; mirror the job description's keywords where true; no keyword
  stuffing. https://www.techinterviewhandbook.org/resume/
- Wikipedia, "Signs of AI writing": puffery vocabulary, participle tails,
  negative parallelisms, rule of three, inflated significance; signs are
  observations, not rules, and no single one is proof.
  https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing

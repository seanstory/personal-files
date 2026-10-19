---
name: tailoring-resume
description: Use when asked to tailor, target, or generate a resume or CV for a specific job, job description, posting, or company, or to produce a resume under resume/out/.
---

# Tailoring a resume

## Overview

Inputs: `resume/pool.yaml` (every fact), a job description, `resume/template.html`
(structure), and `resume/resume.html` (the general resume: reference for tone,
density, and length). Output: `resume/out/<company>-<role>.html`, its PDF, and a
report in chat.

Tailoring is choosing, ordering, and rewording pool entries. The pool is the
ceiling for every claim.

## The page

- **Length:** at most two US-letter pages, 18–24 bullets in total, like
  `resume.html` (22). Never edit `resume.css` or add inline styles to fit.
- **Headline:** `profile.headlines[0]`, optionally followed by ` · <domain>`.
  The domain is a problem area backed by three or more of the chosen bullets,
  such as "Data Ingestion & Pipelines" or "Search Platforms". It is never a
  language, framework, or product name.
- **Summary:** `profile.summaries` `general`, tilted toward the job, in 2–4
  sentences. The last sentence keeps the current role visible.
- **Skills:** four rows. Each row label is one of the pool's skill categories,
  verbatim: Languages · Frameworks & APIs · Search & Data · Infrastructure ·
  AI/Agents · Practices. An item is eligible when its `evidence` includes at
  least one accomplishment id; `proj-*` ids alone don't qualify. Within a row,
  order the items by relevance to the job.
- **Experience:** every role, newest first. Each bullet comes from accomplishments
  whose `role` is that role, and a bullet may merge two of them. A job's
  must-have tech that the pool supports only thinly or in older work shows up in
  dated bullets and in Skills, with the dates left as they are.

## Steps

1. List the job's must-haves and nice-to-haves.
2. Map each to pool ids, using tags and descriptions.
3. Fill the template and save it to `resume/out/<company>-<role>.html`.
4. Build the PDF and count its pages:
   ```bash
   make resume HTML=resume/out/<name>.html
   python3 -c "import re,sys;print(re.findall(rb'/Count (\d+)',open(sys.argv[1],'rb').read())[0].decode())" resume/out/<name>.pdf
   ```
   If the count is more than 2, cut the weakest bullet and rebuild.
5. Report.

Edit only files under `resume/out/`. Problems you find in the pool belong in the
report.

## The report

In this order:
1. **Output:** paths and page count.
2. **Bullets:** for each role, the pool ids used.
3. **Gaps:** job requirements with no pool evidence. These are not claimed on
   the page.
4. **Stretches:** any wording that goes beyond its entry's description, with the
   entry id.
5. **Cut for space:** strong matches that were left out.

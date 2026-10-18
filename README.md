# personal-files
Just my settings files, the way I like them

### Executables
* move the `notify` script to somewhere in your path, and `chmod 777`

### Resume

Run `make resume` to build `resume.pdf` from `resume/resume.html`.

- `resume/pool.yaml` — the source of truth: every role, accomplishment, project, publication, and skill, each with dates, tags, and a description. Much broader than any one resume. Public repo, so public-safe content only.
- `resume/template.html` — skeleton for agents generating a tailored resume from the pool plus a job description.
- `resume/resume.html` — the general resume; also the worked example of a filled-in template.
- `resume/out/` — gitignored; put tailored variants here and print with `make resume HTML=resume/out/<name>.html` (writes `resume/out/<name>.pdf`).

**Requires:** Chrome or Chromium. Checks for `chromium` or `google-chrome` on PATH, then falls back to `/Applications/Google Chrome.app` on macOS.

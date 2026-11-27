---
name: record-agent-lesson
description: Use when the outcome of work done by the researcher, architect or product-manager agent becomes known and that agent was not there to see it - the user rejects or corrects a spec, a design decision proves right or wrong in implementation or review, a review finding turns out wrong or is confirmed by a bug, research is contradicted by what was later found. Also when the user says to teach or tell one of those agents something.
---

# Record an agent lesson

Each roster agent keeps its own Hindsight bank (`agent::researcher`, `agent::architect`, `agent::product-manager`) and recalls from it at the start of a task. An agent can record what it sees for itself, but most outcomes arrive after it has finished: you or the user find out days later whether its design held up or its finding was real. This skill is how that outcome reaches the agent.

```bash
# 1. see what the agent already holds on the topic
python3 ~/.claude/skills/record-agent-lesson/record.py recall <agent> "<query>"
# 2. record what is new
python3 ~/.claude/skills/record-agent-lesson/record.py record <agent> --title "<short title>" <<'EOF'
<lesson>
EOF
```

## What makes a lesson worth recording

Record it when there is an outcome with evidence behind it, and the lesson would change what the agent does on a different task. The agent will read it cold, with no memory of the original work, so write it to stand alone:

- **Situation:** the kind of task and what the agent did or claimed, concretely.
- **Outcome:** what happened, and who or what settled it (the user's decision, a failing test, a production bug, a reviewer's concession). Quote the user's words when they are the evidence.
- **Lesson:** what to do differently, or keep doing, stated as the check or habit and the condition it applies under.

One lesson per call. If the recall shows a similar lesson is already there, record only what is new, or the correction if the old one was wrong.

## What does not belong

- **Facts about one repository or project.** Those go in that repo's own memory if it has one (with the Hindsight coding-agent plugin, `hindsight_ingest_document`), where every session in the repo finds them. An agent's bank is for how it should work anywhere.
- **Routine results.** "The spec was approved" teaches nothing unless something about how it was written is why.
- **A lesson drawn from one loud opinion.** If the user overruled a reviewer's finding because of a constraint the reviewer could not have known, the lesson is "ask for that constraint in the brief", not "stop raising that kind of finding". Lessons that tell a reviewer to raise less need the stronger evidence: the finding was checked and was wrong.
- **Your guess at the outcome.** If the result is not in yet, wait.

Tell the user in one line what you recorded and for which agent.

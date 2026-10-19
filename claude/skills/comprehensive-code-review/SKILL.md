---
name: comprehensive-code-review
description: Provide a comprehensive, in-depth code review of a GitHub PR. Builds deep understanding of changed code and its usage. Use when the user says "comprehensive review", "deep review", or invokes /comprehensive-code-review.
args: PR
---

Provide a comprehensive code review of $PR. Build a deep understanding of the pieces that have changed, and how they're used. Do not post the review, but share your insights here in chat so that we can discuss. You will likely be the one to fix the issues you identify.


### Local copy of the code

In order to get the best review, you may want to be able to browse the branch locally. 
1. Make sure you're in the right working directory for the right repo
2. Make sure there's no local diff (if there is, interrupt and ask the user to stash/commit it and switch branches manually)
3. If $PR was made from a fork, you may need to add a remote for the fork first. Name the fork after the first name of the PR author. Check `git remote` first, and if there's not already one, do `git remote add <firstName> <remoteGitUrl>`
4. Fetch the latest with `git fetch <remote> <branch>`
5. Check out the branch `git checkout <branch>`

### Editorial review

Before sharing your findings, write them out to a temporary file. Then review them and prune unnecessary insights. 
Trains of thought like:

```
But Set.copyOf does throw on duplicates — it's Set.of that throws, but Set.copyOf also throws on null. Actually, re-reading the JDK source: Set.copyOf does not throw on duplicates — it deduplicates.
```

and

```
This would be a serious security bug.

Is this possible? Looking at how IndicesAccessControl is constructed — it's built per-request during authorization and stored in the thread context. Different users' requests run in different thread contexts, so they'd have different IndicesAccessControl and thus different DocumentPermissions instances. This appears safe.
```

read as contradictory stream-of-consciousness, not review conclusions, and should therefore be pruned/adjusted for conciseness and clarity.


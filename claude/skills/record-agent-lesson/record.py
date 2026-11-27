#!/usr/bin/env python3
"""Record or recall lessons in a roster agent's Hindsight bank (agent::<name>).

  record.py record <agent> --title "..."  < lesson.txt
  record.py recall <agent> "query"
"""
import argparse, json, sys, urllib.error, urllib.parse, urllib.request

AGENTS = ("researcher", "architect", "product-manager")
# Must be the server in the memory-<name> url of claude/agents/*.md, or lessons
# recorded here land where the agents never recall from. It is local and
# unauthenticated, like the agents' own connection, so no credential is sent.
SERVER = "http://localhost:8888"
# Loopback only: never route lesson text through a configured proxy.
OPENER = urllib.request.build_opener(urllib.request.ProxyHandler({}))


def call(bank, path, body=None):
    url = f"{SERVER}/v1/default/banks/{urllib.parse.quote(bank, safe='')}{path}"
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(url, data, {"Content-Type": "application/json"})
    try:
        with OPENER.open(req, timeout=120) as resp:
            return json.load(resp)
    except urllib.error.HTTPError as e:
        sys.exit(f"Hindsight returned {e.code} for {bank}: {e.read().decode(errors='replace')[:300]}")
    except TimeoutError:
        sys.exit(f"Hindsight did not answer in time; the write may still have landed, so check with recall before retrying")
    except OSError as e:
        sys.exit(f"could not reach Hindsight at {SERVER}: {e}")


p = argparse.ArgumentParser()
p.add_argument("action", choices=("record", "recall"))
p.add_argument("agent", choices=AGENTS)
p.add_argument("query", nargs="?")
p.add_argument("--title")
a = p.parse_args()
bank = f"agent::{a.agent}"

if a.action == "record":
    if sys.stdin.isatty():
        sys.exit("pipe the lesson text on stdin")
    text = sys.stdin.read().strip()
    if a.query or not a.title or not text:
        sys.exit("record takes --title and the lesson text on stdin, not as an argument")
    # Retaining to a bank that does not exist creates it with every MCP tool
    # enabled, including the ones that delete it. Only write to a prepared bank.
    if call(bank, "/config").get("config", {}).get("mcp_enabled_tools") != ["recall", "retain"]:
        sys.exit(f"{bank} is not set up: run the bank setup in the repo README (Claude Code agents, Requires) first")
    item = {"content": f"{a.title}\n\n{text}", "context": f"lesson for the {a.agent} agent, recorded by the session that saw the outcome", "tags": ["lesson", "source:main-session"]}
    print(json.dumps(call(bank, "/memories", {"items": [item], "async": False}), indent=1)[:600])
else:
    if not a.query:
        sys.exit("recall needs a query")
    out = call(bank, "/memories/recall", {"query": a.query, "max_tokens": 2000})
    for r in out.get("results", []):
        print(f"- [{r.get('type')}] {r.get('text')}")
    if not out.get("results"):
        print("(nothing recalled)")

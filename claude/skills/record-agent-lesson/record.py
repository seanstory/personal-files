#!/usr/bin/env python3
"""Record or recall lessons in a roster agent's Hindsight bank (agent::<name>).

  record.py record <agent> --title "..."  < lesson.txt
  record.py recall <agent> "query"
"""
import argparse, json, os, sys, urllib.parse, urllib.request

AGENTS = ("researcher", "architect", "product-manager")


def call(bank, path, body):
    cfg = json.load(open(os.path.expanduser("~/.hindsight/coding-agent.json")))
    url = f"{cfg['apiUrl'].rstrip('/')}/v1/default/banks/{urllib.parse.quote(bank, safe='')}{path}"
    headers = {"Content-Type": "application/json"}
    if cfg.get("apiToken"):
        headers["Authorization"] = f"Bearer {cfg['apiToken']}"
    req = urllib.request.Request(url, json.dumps(body).encode(), headers)
    with urllib.request.urlopen(req, timeout=120) as resp:
        return json.load(resp)


p = argparse.ArgumentParser()
p.add_argument("action", choices=("record", "recall"))
p.add_argument("agent", choices=AGENTS)
p.add_argument("query", nargs="?")
p.add_argument("--title")
a = p.parse_args()
bank = f"agent::{a.agent}"

if a.action == "record":
    text = sys.stdin.read().strip()
    if not a.title or not text:
        sys.exit("record needs --title and the lesson text on stdin")
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

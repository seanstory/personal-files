#!/usr/bin/env python3
"""Record or recall lessons in a roster agent's Hindsight bank (agent::<name>).

  record.py record <agent> --title "..."  < lesson.txt
  record.py recall <agent> "query"
"""
import argparse, json, os, sys, urllib.error, urllib.parse, urllib.request

AGENTS = ("researcher", "architect", "product-manager")


def call(bank, path, body):
    # Same server the agents' own memory tools point at. The token, if the
    # server needs one, comes from the Hindsight plugin's config when present.
    base = os.environ.get("HINDSIGHT_API_URL", "http://localhost:8888").rstrip("/")
    token = os.environ.get("HINDSIGHT_API_TOKEN")
    if not token:
        try:
            token = json.load(open(os.path.expanduser("~/.hindsight/coding-agent.json"))).get("apiToken")
        except (OSError, ValueError):
            token = None
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    url = f"{base}/v1/default/banks/{urllib.parse.quote(bank, safe='')}{path}"
    req = urllib.request.Request(url, json.dumps(body).encode(), headers)
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            return json.load(resp)
    except urllib.error.HTTPError as e:
        sys.exit(f"Hindsight returned {e.code} for {bank}: {e.read().decode(errors='replace')[:300]}")
    except OSError as e:
        sys.exit(f"could not reach Hindsight at {base}: {e}")


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

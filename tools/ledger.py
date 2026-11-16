#!/usr/bin/env python3
"""Project ledger (layer 5): a plain-text record of every cost-bearing resource,
decision, approval and human intervention, so teardown is a checklist of facts.

Usage: tools/ledger.py <command> [args]      (ledger file: $CREW_LEDGER or .crew/ledger.md)
  init <project> <cost-ceiling> <region>     create the ledger (refuses to overwrite)
  add <type> <name> <est-cost> <created-by> <teardown-command>
                                             record a resource at the moment it is created
  note <decision|approval|intervention> <text>
  close <row-number> <evidence>              mark a resource removed; evidence must say how it was verified
  keep <row-number> <reason>                 mark a resource as intentionally kept
  check                                      exit 0 if no row is open, 1 if any row is open
  show                                       print the ledger

The tool refuses to store AWS access keys and masks 12-digit numbers (possible account IDs).
It checks that the cells are filled in; it cannot check that the evidence is true. Put the
real proof (for example 'tools/teardown-check.sh exit 0') in the evidence text.
Status: v0, tested on temporary files (tools/test_ledger.sh); not yet used in a live session.
"""
import os, re, sys, datetime

PATH = os.environ.get("CREW_LEDGER", ".crew/ledger.md")
HEADER = "| # | Created (UTC) | Type | Name / ID | Est. cost | Created by | Teardown command | Removed (UTC) | Verified by |"
SEP = "|---|---|---|---|---|---|---|---|---|"
NOTE_KINDS = ("decision", "approval", "intervention")

def now():
    return datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M")

def clean(text):
    text = str(text).replace("|", "/").replace("\n", " ").strip()
    if re.search(r"(AKIA|ASIA)[0-9A-Z]{16}", text) or "BEGIN PRIVATE KEY" in text or "BEGIN RSA PRIVATE KEY" in text:
        sys.exit("refused: looks like a credential; never record secrets in the ledger")
    return re.sub(r"(?<![0-9A-Za-z])[0-9]{12}(?![0-9A-Za-z])", "<ACCOUNT_ID>", text)

def read():
    if not os.path.exists(PATH):
        sys.exit("no ledger at %s; run: tools/ledger.py init <project> <ceiling> <region>" % PATH)
    return open(PATH).read().split("\n")

def write(lines):
    open(PATH, "w").write("\n".join(lines))

def rows(lines):
    out = []
    for i, l in enumerate(lines):
        m = re.match(r"^\|\s*(\d+)\s*\|", l)
        if m:
            out.append((i, int(m.group(1)), [c.strip() for c in l.strip().strip("|").split("|")]))
    return out

def fmt(cells):
    return "| " + " | ".join(cells) + " |"

def main(a):
    if not a:
        sys.exit(__doc__)
    cmd, args = a[0], a[1:]
    if cmd == "init":
        if len(args) != 3: sys.exit("usage: init <project> <cost-ceiling> <region>")
        if os.path.exists(PATH): sys.exit("refused: %s already exists" % PATH)
        os.makedirs(os.path.dirname(PATH) or ".", exist_ok=True)
        write(["# Resource Ledger - " + clean(args[0]), "",
               "Cost ceiling: %s   Region: %s   Started (UTC): %s" % (clean(args[1]), clean(args[2]), now()), "",
               "Rule: a project is not finished while any row has an empty Removed or Verified-by cell, unless the resource is marked KEPT with a reason.", "",
               "## Resources", "", HEADER, SEP, "", "## Decisions, approvals and interventions", "", ""])
        print("created", PATH)
    elif cmd == "add":
        if len(args) != 5: sys.exit("usage: add <type> <name> <est-cost> <created-by> <teardown-command>")
        lines = read(); rs = rows(lines)
        n = max([r[1] for r in rs], default=0) + 1
        cells = [str(n), now()] + [clean(x) for x in args] + ["", ""]
        at = (rs[-1][0] + 1) if rs else lines.index(SEP) + 1
        lines.insert(at, fmt(cells)); write(lines)
        print("row", n, "recorded")
    elif cmd == "note":
        if len(args) != 2 or args[0] not in NOTE_KINDS: sys.exit("usage: note <decision|approval|intervention> <text>")
        lines = read()
        while lines and lines[-1] == "": lines.pop()
        lines.append("- %s [%s] %s" % (now(), args[0], clean(args[1]))); lines.append("")
        write(lines); print("noted")
    elif cmd in ("close", "keep"):
        if len(args) != 2 or not args[0].isdigit() or not args[1].strip():
            sys.exit("usage: %s <row-number> <%s>" % (cmd, "evidence" if cmd == "close" else "reason"))
        lines = read(); hit = [r for r in rows(lines) if r[1] == int(args[0])]
        if not hit: sys.exit("no such row: " + args[0])
        i, _, cells = hit[0]
        if cells[7] or cells[8]: sys.exit("row %s is already closed" % args[0])
        cells[7] = now() if cmd == "close" else "KEPT"
        cells[8] = clean(args[1])
        lines[i] = fmt(cells); write(lines); print("row", args[0], "closed" if cmd == "close" else "kept")
    elif cmd == "check":
        open_rows = [r for r in rows(read()) if not (r[2][7] and r[2][8])]
        if not open_rows:
            print("LEDGER CLEAR: every row is removed or kept, with evidence"); return 0
        print("LEDGER OPEN: %d resource(s) not closed:" % len(open_rows))
        for _, n, c in open_rows: print("  #%d %s %s (est. %s) teardown: %s" % (n, c[2], c[3], c[4], c[6]))
        return 1
    elif cmd == "show":
        print("\n".join(read()))
    else:
        sys.exit(__doc__)
    return 0

if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

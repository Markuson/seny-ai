"""Lint the Seny repo: manifests, frontmatter, plugin paths, doc links, retired wording."""
import glob, json, os, re, sys

root = sys.argv[1] if len(sys.argv) > 1 else "."
os.chdir(root)
errors = []

for f in [".claude-plugin/plugin.json", ".claude-plugin/marketplace.json", "hooks/hooks.json"]:
    try:
        json.load(open(f))
    except Exception as e:  # noqa: BLE001
        errors.append(f"{f}: invalid JSON ({e})")

skills = sorted(glob.glob("skills/*/SKILL.md"))
for f in skills + glob.glob("agents/*.md"):
    m = re.match(r"^---\n(.*?)\n---\n", open(f).read(), re.S)
    if not m:
        errors.append(f"{f}: no frontmatter"); continue
    keys = dict(l.split(":", 1) for l in m.group(1).splitlines() if re.match(r"^[A-Za-z-]+:", l))
    for k in ("name", "description"):
        if k not in keys:
            errors.append(f"{f}: frontmatter lacks {k}")
    if f.startswith("skills/") and keys.get("name", "").strip() != f.split("/")[1]:
        errors.append(f"{f}: name doesn't match its folder")

method = skills + glob.glob("agents/*.md") + glob.glob("references/*.md") + glob.glob("templates/**/*.md", recursive=True)
for f in method + ["hooks/hooks.json"]:
    for p in re.findall(r"\$\{CLAUDE_PLUGIN_ROOT\}/([A-Za-z0-9_./<>-]+)", open(f).read()):
        p = p.rstrip(".`)")
        if "<" not in p and not os.path.exists(p):
            errors.append(f"{f}: missing plugin path {p}")

# Wording retired by past versions; the changelog may still mention it.
retired = [r"templates/feature", r"docs/features", r"<docs>/features", r"\.seny/features", r"\bE\d+-S\d+\b",
           r"project/research\.md", r"project-docs\.md", r"cleanup epic", r"Feature plan format", r"`react-native-skills`"]
docs = ["README.md"] + glob.glob("guide/*.md") + glob.glob("examples/**/*.md", recursive=True)
for f in method + docs + glob.glob("scripts/*.sh"):
    text = open(f).read()
    for pat in retired:
        if re.search(pat, text):
            errors.append(f"{f}: retired wording /{pat}/")

def slug(h):
    return re.sub(r"[^\w\- ]", "", h.strip().lower()).replace(" ", "-")

anchors = {}
for f in docs + ["CHANGELOG.md"]:
    t = open(f).read()
    nocode = re.sub(r"```.*?```", "", t, flags=re.S)
    anchors[os.path.normpath(f)] = {slug(h) for h in re.findall(r"^#+ (.*)$", nocode, re.M)} | set(re.findall(r'<a name="([^"]+)"', t))
for f in docs + ["CHANGELOG.md"]:
    t = re.sub(r"```.*?```", "", open(f).read(), flags=re.S)
    for link in re.findall(r"\]\(([^)\s]+)\)", t):
        if link.startswith(("http", "mailto:")):
            continue
        path, _, anc = link.partition("#")
        target = os.path.normpath(os.path.join(os.path.dirname(f), path)) if path else os.path.normpath(f)
        if not os.path.exists(target):
            errors.append(f"{f}: broken link {link}")
        elif anc and target.endswith(".md") and anc not in anchors.get(target, set()):
            errors.append(f"{f}: broken anchor {link}")

# The command reference must cover every skill.
ref = open("guide/commands.md").read()
for f in skills:
    name = f.split("/")[1]
    if f"/seny:{name}" not in ref:
        errors.append(f"guide/commands.md: no entry for /seny:{name}")

for e in errors:
    print("LINT:", e)
sys.exit(1 if errors else 0)

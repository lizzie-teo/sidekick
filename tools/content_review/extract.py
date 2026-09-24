#!/usr/bin/env python3
# Pulls every reader-facing line out of the Dart script files and the
# markdown briefs, into one JSON file the review page reads.
#
# Run it again whenever the scripts change:
#     python3 tools/content_review/extract.py

import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Dart files whose string literals are words somebody reads on screen.
DART_SOURCES = [
    ("Panic", "Breathing script", "lib/features/panic/models/breathing_script.dart"),
    ("Panic", "Body sensations", "lib/features/panic/models/sensation.dart"),
    ("Panic", "Lead-in beats", "lib/features/panic/viewmodels/breathing_viewmodel.dart"),
    ("Panic", "Feeling picker", "lib/features/panic/models/feeling.dart"),
    ("Play", "Tighten, and stop", "lib/features/play/models/tighten_script.dart"),
    ("Play", "Low day", "lib/features/play/models/low_day_script.dart"),
    ("Play", "Actually okay", "lib/features/play/models/actually_okay_lines.dart"),
    ("Home", "Noticing prompts", "lib/data/models/noticing_prompts.dart"),
    ("Home", "Affirmation lines", "lib/features/dashboard/models/affirmation_lines.dart"),
    ("Practice", "Swap drill", "lib/features/practice/models/swap_drill_script.dart"),
    ("Practice", "Practice tab", "lib/features/practice/models/practice_item.dart"),
]

BRIEF_DIR = "_docs/briefs"
EXTRA_DOCS = [
    ("Reference", "Affirmation flow", "_docs/affirmation-flow.md"),
    ("Reference", "Kind writing style", "_docs/kind-writing-style.md"),
]

# A string literal, single or double quoted, no interpolation spanning quotes.
STRING_RE = re.compile(r"""(?<![\w$])(?:r?)('(?:\\.|[^'\\])*'|"(?:\\.|[^"\\])*")""")
DECL_RE = re.compile(
    r"static\s+(?:const|final)\s+(?:[\w<>,\s?]+\s+)?(\w+)\s*[=;]|"
    r"^\s*(?:const\s+)?(\w+)\s*\(\s*$|"
    r"^\s*final\s+(\w+)\s*="
)
# Only a numbered heading comment -- "// 3. Shoulders" -- names a section.
# Anything looser catches ordinary prose comments and mislabels the lines
# under them.
SECTION_COMMENT_RE = re.compile(r"^\s*//\s*(\d+\.\s+[A-Z][^.]{2,50})\s*$")


def unquote(raw):
    body = raw[1:-1]
    body = body.replace("\\'", "'").replace('\\"', '"').replace("\\\\", "\\")
    body = body.replace("\\n", "\n").replace("\\t", "\t")
    return body


def is_prose(text):
    t = text.strip()
    if not t:
        return False
    if t.startswith("assets/") or t.startswith("lib/") or t.startswith("_docs/"):
        return False
    if t.startswith("/") or t.startswith("http") or t.startswith("package:"):
        return False
    if t.startswith("dart:"):
        return False
    if re.fullmatch(r"[\w\-./]+\.(png|jpg|webp|riv|mp3|m4a|json|dart)", t):
        return False
    # Single short token with no space is a key or a label fragment, not prose.
    if " " not in t and len(t) < 14:
        return False
    return True


def extract_dart(rel_path):
    abs_path = os.path.join(ROOT, rel_path)
    with open(abs_path, encoding="utf-8") as handle:
        lines = handle.read().split("\n")

    entries = []
    section = "(top of file)"
    pending = None  # an entry still collecting adjacent literals

    def flush():
        nonlocal pending
        if pending is not None:
            pending.pop("open", None)
            entries.append(pending)
            pending = None

    def make(text, number):
        return {
            "id": f"{rel_path}:{number}",
            "file": rel_path,
            "line": number,
            "endLine": number,
            "section": section,
            "text": text,
        }

    # A line ending in a comma, semicolon or closer has finished its value.
    # Only a line that does not is continued by the literal on the next one --
    # which is how Dart joins adjacent strings.
    closed_re = re.compile(r"[,;)\]}]\s*$")
    only_literals_re = re.compile(
        r"(?:\s*(?:r?'(?:\\.|[^'\\])*'|r?\"(?:\\.|[^\"\\])*\")\s*)+[,;)\]]*\s*"
    )

    for number, line in enumerate(lines, start=1):
        stripped = line.strip()

        if stripped.startswith("//"):
            match = SECTION_COMMENT_RE.match(line)
            if match:
                heading = (match.group(1) or "").strip()
                if len(heading.split()) <= 9:
                    section = heading
            flush()
            continue

        decl = DECL_RE.search(line)
        if decl:
            name = decl.group(1) or decl.group(2) or decl.group(3)
            flush()
            if name:
                section = _humanise(name)

        prose = [unquote(raw) for raw in STRING_RE.findall(line)]
        prose = [p for p in prose if is_prose(p)]

        if not prose:
            flush()
            continue

        continues = (
            pending is not None
            and pending.get("open")
            and not decl
            and bool(only_literals_re.fullmatch(line))
            and len(prose) == 1
        )

        if continues:
            pending["text"] += prose[0]
            pending["endLine"] = number
        else:
            flush()
            for text in prose[:-1]:
                entries.append(make(text, number))
            pending = make(prose[-1], number)

        pending["open"] = not closed_re.search(line)

    flush()
    return entries


def _humanise(name):
    spaced = re.sub(r"(?<!^)(?=[A-Z])", " ", name)
    return spaced[0].upper() + spaced[1:]


def extract_markdown(rel_path):
    abs_path = os.path.join(ROOT, rel_path)
    with open(abs_path, encoding="utf-8") as handle:
        body = handle.read()
    return body


def main():
    scripts = []
    for group, title, rel_path in DART_SOURCES:
        if not os.path.exists(os.path.join(ROOT, rel_path)):
            print(f"  skip (missing): {rel_path}", file=sys.stderr)
            continue
        entries = extract_dart(rel_path)
        scripts.append(
            {
                "group": group,
                "title": title,
                "file": rel_path,
                "kind": "script",
                "entries": entries,
            }
        )
        print(f"  {title}: {len(entries)} lines", file=sys.stderr)

    docs = []
    brief_dir = os.path.join(ROOT, BRIEF_DIR)
    brief_files = []
    if os.path.isdir(brief_dir):
        brief_files = [
            ("Brief", _humanise_file(name), os.path.join(BRIEF_DIR, name))
            for name in sorted(os.listdir(brief_dir))
            if name.endswith(".md")
        ]
    for group, title, rel_path in brief_files + EXTRA_DOCS:
        full = os.path.join(ROOT, rel_path)
        if not os.path.exists(full):
            continue
        docs.append(
            {
                "group": group,
                "title": title,
                "file": rel_path,
                "kind": "doc",
                "body": extract_markdown(rel_path),
            }
        )
    print(f"  {len(docs)} documents", file=sys.stderr)

    out = {"scripts": scripts, "docs": docs}
    dest = os.path.join(ROOT, "tools/content_review/content.json")
    with open(dest, "w", encoding="utf-8") as handle:
        json.dump(out, handle, indent=1, ensure_ascii=False)
    print(f"Wrote {dest}", file=sys.stderr)


def _humanise_file(name):
    stem = name[:-3].replace("-", " ").replace("_", " ")
    return stem[0].upper() + stem[1:]


if __name__ == "__main__":
    main()

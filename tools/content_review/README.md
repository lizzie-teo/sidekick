# Copy desk

A web page for reading every word Sidekick says, marking each line
Keep / Change / Cut, and leaving a note for Claude.

**The page:** https://claude.ai/code/artifact/fff2e523-e61d-4c75-a622-19fe5c727bd0

It is private to your account, and the notes are stored with it.

## What is in it

| Side | Where it comes from |
| --- | --- |
| Scripts | String literals in the Dart content files -- the breathing script, the two Play scripts, the swap drill, the sensations, the picker |
| Briefs | Every `.md` in `_docs/briefs/`, plus `affirmation-flow.md` and `kind-writing-style.md`, split into blocks |

Each line carries its `file:line`, so a note points at the exact place to
change.

## Refreshing it after the words change

```
python3 tools/content_review/extract.py
```

That rewrites `content.json`. Then ask Claude to republish the page --
same file path, same URL, notes kept.

## The one thing it does not do

It cannot write to the Dart files. A web page has no reach into the repo,
and the read-only file capability does not change that. So the loop is:

1. You mark a line and write what you want instead.
2. Claude reads the notes out of the page's store.
3. Claude edits the Dart file and reports back.

The **Copy notes** button puts the same thing on your clipboard as
markdown, for when you would rather paste it into a message.

---
name: breath-events
description: Check and repair the two Rive events the breathing counter runs on (inhale at frame 0, exhale at frame 186 on the Breathe timeline of assets/rive/character.riv). Use when the breath count stops incrementing, when the cue text stops swapping between in and out, or after any Rive editor session that touched the Breathe timeline.
---

# Breath events — check and repair

The breathing screen has no timer. `assets/rive/character.riv` fires two Rive
events on its `Breathe` timeline, `SkCharacter` listens for them, and
`BreathingViewModel.onInhale` counts the breath. Lose the two event keys and the
number stops moving while everything else looks correct.

**A Rive editor session can delete those keys.** This was thought to be fixed
when the file moved from trigger keys to event keys on 15 September 2026. It is
not fixed — the keys were lost again during the ragdoll-cat rebuild on 19
September 2026. Treat every editor session as capable of removing them.

**And the session does not have to go near `Breathe`.** Later the same day, a
session that only drew still faces on the four `feeling-*` artboards — never
opening the `Breathe` timeline, never touching the `sidekick` artboard — lost
both keys again, and had already lost and repaired them once earlier in the
same sitting. So:

- The trigger for this check is **any editor session at all**, not a session
  that touched the breath. The description above is deliberately narrower than
  the truth; read this line as the rule.
- Check **immediately before every export**, not once at the end of the work.
  Two exports in one sitting need two checks. The keys went missing between
  them.
- It costs one call. Repairing a shipped file costs a release.

## The facts

| Thing | Value |
| --- | --- |
| File | `assets/rive/character.riv`, single file, never copied per screen |
| Timeline | `Breathe`, 480 frames at 48fps, so 10.0s |
| `inhale` event | frame 0 |
| `exhale` event | frame 186 |
| Property key for an event key | `395` (`trigger`) |
| Dart listener | `_onRiveEvent` in `lib/app/widgets/sk_character.dart` |
| Counter | `BreathingViewModel.onInhale` |

## Step 1 — check

The Rive desktop app must be open with `character.riv` loaded. Run one call:

    mcp__rive__animation_editor
      command: simulateStateMachine
      data: {"simulateStateMachine": {"fps": 48, "frames": 300,
             "inputs": [{"frame": 2, "property": "startBreathe"}]}}

Read the `trace` array. It is healthy when it holds **both** of these:

    {"kind":"event","eventName":"inhale", ...}   near frame 4
    {"kind":"event","eventName":"exhale", ...}   near frame 189

The frames are a few higher than 0 and 186 because the machine spends the first
frames in `Idle` before `startBreathe` moves it into `Breathe`.

No event entries in the trace means the keys are gone. Go to step 2.

**Do not check with `queryKeyFrames`.** It cannot see event keys and reports a
healthy timeline as having none. Do not check by eye in the editor either —
that is what missed it last time. `simulateStateMachine` is the only check that
has ever caught this.

## Step 2 — repair

Object ids are not stable across sessions, so look them up:

    mcp__rive__find_objects  type: "event"

That returns the `inhale` and `exhale` event objects. Get the `Breathe`
animation id from `listLinearAnimations` (it was `0-6`). Then add both keys:

    mcp__rive__animation_editor
      command: modifyKeyFrames
      data: {"modifyKeyFrames": {"animationId": "<Breathe id>", "add": [
        {"objectId": "<inhale id>", "propertyKey": 395, "frame": 0,
         "value": true, "interpolationType": "hold"},
        {"objectId": "<exhale id>", "propertyKey": 395, "frame": 186,
         "value": true, "interpolationType": "hold"}]}}

Then run step 1 again. It must show both events before you go on.

## Step 3 — export and copy in

`export_file` cannot write to disk: the editor is sandboxed on macOS. Use the
HTTP endpoint instead. The recipe the error message prints is **missing the
`notifications/initialized` call** and fails with `Received tools/call before
notifications/initialized`. This one is correct:

    DEST='<a writable directory>'
    DEST_JSON=$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$DEST")
    URL=http://127.0.0.1:9791/mcp
    RESP="${TMPDIR:-/tmp}/rive_export_response.txt"
    SID=$(curl -si "$URL" -H 'Content-Type: application/json' \
      -H 'Accept: application/json, text/event-stream' \
      -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"export-script","version":"1"}}}' \
      | tr -d '\r' | sed -n 's/^mcp-session-id: //p')
    curl -s "$URL" -H 'Content-Type: application/json' \
      -H 'Accept: application/json, text/event-stream' -H "mcp-session-id: $SID" \
      -d '{"jsonrpc":"2.0","method":"notifications/initialized"}' > /dev/null
    curl -s "$URL" -H 'Content-Type: application/json' \
      -H 'Accept: application/json, text/event-stream' -H "mcp-session-id: $SID" \
      -d '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"export_file","arguments":{"format":"riv","destination":'"$DEST_JSON"',"inline_base64":true}}}' > "$RESP"
    python3 - "$RESP" "$DEST" <<'PY'
    import base64, json, sys
    raw = open(sys.argv[1], encoding='utf-8').read()
    lines = [l[5:].strip() for l in raw.splitlines() if l.startswith('data:')]
    body = json.loads(lines[-1] if lines else raw)
    payload = json.loads(body['result']['content'][0]['text'])
    if 'data' not in payload:
        print(payload['path'] + ' (written directly by the editor)')
        sys.exit(0)
    out = sys.argv[2] + '/' + payload['filename']
    open(out, 'xb').write(base64.b64decode(payload['data']))
    print(out)
    PY

The endpoint refuses to overwrite, so export into a scratch directory and copy
over `assets/rive/character.riv` yourself.

Each event key costs about 13 bytes, so a repaired file is roughly 27 bytes
larger than the broken one. That is a useful sanity check, not a proof.

## Step 4 — say what to run

The widget tests call `onInhale` and `onExhale` by hand, so they pass whether or
not the file delivers a single event. They prove nothing here. The simulation in
step 1 is the real check; the app is the final one:

    flutter run --dart-define-from-file=env.json

Open the breathing screen and watch for `RIVEDIAG inhale` and `RIVEDIAG exhale`
in the console, and the number climbing.

## Preventing it

Run step 1 at the end of **every** Rive editor session that touched anything,
not only the `Breathe` timeline. It is one call and it is the only check that
works.

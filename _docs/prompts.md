❯ is there an event at the end of the rive animation that we can use to increment the counter


      Not with the drawing. She animates correctly every time I have run her. What keeps breaking is the wiring around the animation, not the animation.

      Three things are known-wrong or fragile

      1. The inhale / exhale keyframes vanish.
      They were keyed, verified working, and then simply were not in the file the next time I exported. Once already today. Nothing inside Rive can tell you — queryKeyFrames does not list trigger keyframes at all, so they look absent even when they are fine. The only check is running the app and watching the counter tick.

      2. A second state machine does not deliver them.
      I built a small Breathing state machine — one state, the Breathe timeline, no listeners. She animated perfectly, but inhale and exhale never reached the app. The counter stayed frozen. I deleted that machine again. I do not know why it behaves that way, and it is worth treating as a real Rive gotcha: a keyframed trigger appears to only fire from the file's default state machine.

      3. The last device check did not complete, so the newest change is unverified.

      What I changed in your file today

      ┌────────────────────────────────────────────────────────────────────┬─────────────────────────────────────────────────────────┐
      │                               Change                               │                           Why                           │
      ├────────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────┤
      │ Breathe timeline fps 60 → 48                                       │ Makes the breath 10.0s without moving a single keyframe │
      ├────────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────┤
      │ Re-added fire keyframes on inhale (frame 0) and exhale (frame 186) │ They had gone missing                                   │
      ├────────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────┤
      │ Added a startBreathe trigger to the Character view model           │ So taps cannot start or stop the pacer                  │
      ├────────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────┤
      │ Pointed Idle → Breathe and IdleAfterHi → Breathe at startBreathe   │ They used to listen to tapBody                          │
      ├────────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────┤
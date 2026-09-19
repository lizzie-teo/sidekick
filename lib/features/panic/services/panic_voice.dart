import 'package:just_audio/just_audio.dart';

import 'package:sidekick/app/core/logger_service.dart';

// The recorded voice on the breathing screen.
//
// **One player, one clip.** Every clip in this flow is the screen saying the
// thing it is already showing, and the screen shows one thing at a time -- so
// two clips at once is always a bug, never a chord. A single player gives
// that for free: starting a clip replaces whatever was playing, so the F2
// closing cannot end up talking underneath the in-breath cue when somebody
// presses "Keep breathing with me".
//
// **One line, one recording, no exceptions.** The opening pairs arrived as a
// single file each and this class briefly grew a null case meaning "the clip
// already playing reads this line too". The files were cut in half instead,
// so the case is gone: every line the screen shows has a clip of its own, and
// playing it is always the right thing to do.
//
// Failure is swallowed. A missing or unplayable clip leaves the screen silent
// and working, which is the right trade on a screen somebody opened mid-panic.
abstract class PanicVoice {
  // Start `asset`, replacing anything already playing.
  Future<void> play(String asset);

  Future<void> stop();

  Future<void> dispose();
}

// The default everywhere that is not the running app: viewmodel tests, and the
// viewmodel's own fallback when nobody handed it a voice.
class SilentPanicVoice implements PanicVoice {
  const SilentPanicVoice();

  @override
  Future<void> play(String asset) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

class JustAudioPanicVoice implements PanicVoice {
  final LoggerService _loggerService;
  final AudioPlayer _player;

  JustAudioPanicVoice({
    required LoggerService loggerService,
    AudioPlayer? player,
  })  : _loggerService = loggerService,
        _player = player ?? AudioPlayer();

  // Loading an asset is a Future, and the breath cues arrive on the animation's
  // own schedule -- so two loads can be in flight at once and the older one can
  // finish last. This counts the calls and lets only the newest one speak.
  int _turn = 0;

  @override
  Future<void> play(String asset) async {
    final int turn = ++_turn;

    try {
      await _player.stop();
      await _player.setAsset(asset);
      if (turn != _turn) return;
      await _player.play();
    } catch (e, s) {
      // A clip that will not load leaves the screen silent, not broken.
      _loggerService.errorShort(e, s);
    }
  }

  @override
  Future<void> stop() async {
    _turn++;
    try {
      await _player.stop();
    } catch (e, s) {
      _loggerService.errorShort(e, s);
    }
  }

  @override
  Future<void> dispose() async {
    _turn++;
    try {
      await _player.dispose();
    } catch (e, s) {
      _loggerService.errorShort(e, s);
    }
  }
}

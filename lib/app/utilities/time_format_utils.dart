class TimeFormatUtils {
  const TimeFormatUtils._();

  // A countdown as m:ss. At a 300 second cooldown "Resend in 300s" reads badly,
  // so the resend label uses this instead.
  static String formatCountdown(int seconds) {
    final safeSeconds = seconds < 0 ? 0 : seconds;
    final minutes = safeSeconds ~/ 60;
    final remainder = safeSeconds % 60;

    return '$minutes:${remainder.toString().padLeft(2, '0')}';
  }
}

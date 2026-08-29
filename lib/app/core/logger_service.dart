import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

// Centralised logging. Injected into every service and viewmodel rather than
// calling debugPrint directly, so output can be silenced or redirected in one
// place (and so tests can assert against a fake).
class LoggerService {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 100,
      colors: true,
      printEmojis: true,
    ),
    level: kReleaseMode ? Level.warning : Level.debug,
  );

  void debug(String message) => _logger.d(message);

  void info(String message) => _logger.i(message);

  void warning(String message) => _logger.w(message);

  void error(String message, [Object? e, StackTrace? s]) {
    _logger.e(message, error: e, stackTrace: s);
  }

  // Shorthand for catch blocks: errorShort(e, s)
  void errorShort(Object e, [StackTrace? s]) {
    _logger.e(e.toString(), error: e, stackTrace: s);
  }
}

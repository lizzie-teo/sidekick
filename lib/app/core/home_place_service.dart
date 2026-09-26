import 'package:flutter_timezone/flutter_timezone.dart';

import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/models/zone_coordinates.dart';

// Where the phone roughly is, for the sky Home and the breathing screen draw: the principal city of its time
// zone. No permission, no network. `sun_times.dart` holds why.
//
// Read by Home and by the breathing screen, which draw the same sky, so it
// is registered in the service locator rather than in either feature.
class HomePlaceService {
  final LoggerService _loggerService;

  HomePlaceService({required LoggerService loggerService})
      : _loggerService = loggerService;

  // Latitude and longitude, or null when the zone cannot be read or is not
  // in the table. Null is not an error the reader sees: the sky falls back
  // to fixed hours, which is what it did before this existed.
  Future<(double, double)?> coordinates() async {
    try {
      final String zone = await FlutterTimezone.getLocalTimezone();
      final (double, double)? place = zoneCoordinates[zone];
      if (place == null) {
        _loggerService.debug('HomePlaceService: no coordinates for $zone');
      }
      return place;
    } catch (error) {
      _loggerService.warning('HomePlaceService: time zone unreadable: $error');
      return null;
    }
  }
}

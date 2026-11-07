import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:favorite_location/models/place.dart';

void main() {
  group('Place and PlaceLocation Models', () {
    test('PlaceLocation stores coordinates and address correctly', () {
      const location = PlaceLocation(
        latitude: 37.422,
        longitude: -122.084,
        address: '1600 Amphitheatre Pkwy, Mountain View, CA',
      );

      expect(location.latitude, 37.422);
      expect(location.longitude, -122.084);
      expect(location.address, '1600 Amphitheatre Pkwy, Mountain View, CA');
    });

    test('Place automatically assigns an ID if not provided', () {
      const location = PlaceLocation(
        latitude: 10.0,
        longitude: 20.0,
        address: 'Test Address',
      );
      final place = Place(
        title: 'Test Place',
        image: File('test.jpg'),
        location: location,
      );

      expect(place.title, 'Test Place');
      expect(place.id, isNotEmpty);
      expect(place.location.address, 'Test Address');
    });

    test('Place preserves custom ID if provided', () {
      const location = PlaceLocation(
        latitude: 10.0,
        longitude: 20.0,
        address: 'Test Address',
      );
      final place = Place(
        id: 'custom-id-123',
        title: 'Custom ID Place',
        image: File('test.jpg'),
        location: location,
      );

      expect(place.id, 'custom-id-123');
      expect(place.title, 'Custom ID Place');
    });
  });
}

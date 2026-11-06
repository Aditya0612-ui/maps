import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:http/http.dart' as http;

import 'package:favorite_places/screens/map.dart';
import 'package:favorite_places/models/place.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});

  final void Function(PlaceLocation location) onSelectLocation;

  @override
  State<LocationInput> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;

  Future<void> _savePlace(double latitude, double longitude) async {
    if (!mounted) return;
    setState(() {
      _isGettingLocation = true;
    });

    String address = '';

    // 1. Try native geocoding (uses Android's built-in Geocoder service)
    try {
      final geocoding = Geocoding();
      final placemarks =
          await geocoding.placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        final addressParts = <String>[
          if (place.name != null && place.name!.trim().isNotEmpty)
            place.name!.trim(),
          if (place.street != null &&
              place.street!.trim().isNotEmpty &&
              place.street != place.name)
            place.street!.trim(),
          if (place.subLocality != null &&
              place.subLocality!.trim().isNotEmpty &&
              place.subLocality != place.name)
            place.subLocality!.trim(),
          if (place.locality != null && place.locality!.trim().isNotEmpty)
            place.locality!.trim(),
          if (place.administrativeArea != null &&
              place.administrativeArea!.trim().isNotEmpty)
            place.administrativeArea!.trim(),
          if (place.postalCode != null &&
              place.postalCode!.trim().isNotEmpty)
            place.postalCode!.trim(),
          if (place.country != null && place.country!.trim().isNotEmpty)
            place.country!.trim(),
        ];

        if (addressParts.isNotEmpty) {
          address = addressParts.join(', ');
        }
      }
    } catch (_) {}

    // 2. If device geocoder is unavailable, fallback to Google Geocoding API
    if (address.isEmpty) {
      try {
        final url = Uri.parse(
            'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=AIzaSyC8Tlo5ZWzzpGauV2oUo5QhNOJIhgqgvgw');
        final response = await http.get(url);
        final resData = json.decode(response.body);

        if (resData['results'] != null &&
            (resData['results'] as List).isNotEmpty) {
          address = resData['results'][0]['formatted_address'];
        }
      } catch (_) {}
    }

    // 3. Fallback to coordinate string if geocoding returns nothing
    if (address.isEmpty) {
      address =
          'Lat: ${latitude.toStringAsFixed(4)}, Lng: ${longitude.toStringAsFixed(4)}';
    }

    if (!mounted) return;

    setState(() {
      _pickedLocation = PlaceLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
      _isGettingLocation = false;
    });

    widget.onSelectLocation(_pickedLocation!);
  }

  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    if (!mounted) return;

    setState(() {
      _isGettingLocation = true;
    });

    try {
      locationData = await location.getLocation();
      final lat = locationData.latitude;
      final lng = locationData.longitude;

      await _savePlace(lat, lng);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  void _selectOnMap() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (ctx) => const MapScreen(),
      ),
    );

    if (pickedLocation == null) {
      return;
    }

    await _savePlace(pickedLocation.latitude, pickedLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No location chosen',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
    );

    if (_pickedLocation != null) {
      previewContent = GestureDetector(
        onTap: _selectOnMap,
        child: AbsorbPointer(
          child: GoogleMap(
            key: ValueKey(
              '${_pickedLocation!.latitude}_${_pickedLocation!.longitude}',
            ),
            initialCameraPosition: CameraPosition(
              target: LatLng(
                _pickedLocation!.latitude,
                _pickedLocation!.longitude,
              ),
              zoom: 16,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('m1'),
                position: LatLng(
                  _pickedLocation!.latitude,
                  _pickedLocation!.longitude,
                ),
              ),
            },
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            zoomGesturesEnabled: false,
            scrollGesturesEnabled: false,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
          ),
        ),
      );
    }

    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    }

    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text('Get Current Location'),
              onPressed: _getCurrentLocation,
            ),
            TextButton.icon(
              icon: const Icon(Icons.map),
              label: const Text('Select on Map'),
              onPressed: _selectOnMap,
            ),
          ],
        ),
      ],
    );
  }
}

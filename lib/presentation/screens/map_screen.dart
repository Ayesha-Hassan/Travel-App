import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_travel_companion/domain/entities/place.dart';

class MapScreen extends StatelessWidget {
  final Place? selectedPlace;

  const MapScreen({super.key, this.selectedPlace});

  @override
  Widget build(BuildContext context) {
    final center = selectedPlace != null
        ? LatLng(selectedPlace!.lat, selectedPlace!.lng)
        : const LatLng(51.509364, -0.128928);

    return Scaffold(
      appBar: AppBar(title: Text(selectedPlace != null ? selectedPlace!.title : 'Travel Map')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: selectedPlace != null ? 12 : 3,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.smart_travel_companion',
          ),
          if (selectedPlace != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: center,
                  width: 80,
                  height: 80,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

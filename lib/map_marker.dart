import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapMarkerPage extends StatefulWidget {
  @override
  _MapMarkerPageState createState() => _MapMarkerPageState();
}

class _MapMarkerPageState extends State<MapMarkerPage> {
  LatLng? _markerLatLng;

  void _handleTap(TapPosition pos, LatLng latLng) {
    setState(() {
      _markerLatLng = latLng;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Marker'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: LatLng(42.8746, 74.5698),
              zoom: 13.0,
              onTap: _handleTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              if (_markerLatLng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _markerLatLng!,
                      child: Container(
                        child: Icon(
                          Icons.location_pin,
                          size: 50,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (_markerLatLng != null)
            Positioned(
              bottom: 20,
              left: 20,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Latitude: ${_markerLatLng!.latitude}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Longitude: ${_markerLatLng!.longitude}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jol_tartip_flutter/constants.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomMarker {
  final LatLng latLng;
  final Widget? child;

  CustomMarker({required this.latLng, this.child});
}

class MapsPage extends StatefulWidget {
  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  List<CustomMarker> customMarkers = [];

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchReviewData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/rest/applications/points'));
      final List<dynamic> data = json.decode(response.body);

      print('Fetched data: $data');

      List<CustomMarker> markers = [];

      markers.addAll(data.map((entry) {
        final lat = entry['lat'] as double?;
        final lon = entry['lon'] as double?;
        if (lat != null && lon != null) {
          return CustomMarker(
            latLng: LatLng(lat, lon),
            child: Image.asset(
              'assets/images/red_marker.png',
              width: 10,
              height: 10,
              scale: 2.0,
            ),
          );
        } else {
          print('Invalid entry: $entry');
          return null;
        }
      }).whereType<CustomMarker>());

      setState(() {
        customMarkers.addAll(markers);
      });
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> fetchReviewData() async {
    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/rest/reviews/points'));
      final List<dynamic> data = json.decode(response.body);

      print('Fetched review data: $data');

      List<CustomMarker> reviewMarkers = [];

      reviewMarkers.addAll(data.map((entry) {
        final lat = entry['lat'] as double?;
        final lon = entry['lon'] as double?;
        if (lat != null && lon != null) {
          return CustomMarker(
            latLng: LatLng(lat, lon),
            child: Image.asset(
              'assets/images/green_marker.png',
              width: 10,
              height: 10,
              scale: 2.0,
            ),
          );
        } else {
          print('Invalid review entry: $entry');
          return null;
        }
      }).whereType<CustomMarker>());

      setState(() {
        customMarkers.addAll(reviewMarkers);
      });
    } catch (error) {
      print('Error fetching review data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('maps'.tr()),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(42.8746, 74.5698),
          zoom: 13.0,
          interactiveFlags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: customMarkers
                .map(
                  (marker) => Marker(
                    point: marker.latLng,
                    width: 100.0,
                    height: 100.0,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Маркер'),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Широта: ${marker.latLng.latitude}'),
                                  Text('Долгота: ${marker.latLng.longitude}'),
                                  SizedBox(height: 20),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Закрыть'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: marker.child ?? SizedBox(),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

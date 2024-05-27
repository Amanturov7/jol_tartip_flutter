import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:jol_tartip_flutter/applications/detailed_view_application.dart';
import 'package:jol_tartip_flutter/events/detailed_view_event.dart';
import 'package:jol_tartip_flutter/reviews/detailed_vew_review.dart';
import 'package:jol_tartip_flutter/sos/detailed_sos_page.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jol_tartip_flutter/constants.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomMarker {
  final LatLng latLng;
  final Widget? child;
  final String type;
  final String id;

  CustomMarker({
    required this.latLng,
    this.child,
    required this.type,
    required this.id,
  });
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
    fetchEventData();
    fetchSosData();
    fetchReviewData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/rest/applications/points'));
      final List<dynamic> data = json.decode(response.body);

      List<CustomMarker> markers = data.map((entry) {
        final lat = entry['lat'] as double?;
        final lon = entry['lon'] as double?;
        final id = entry['id'].toString();
        if (lat != null && lon != null && id.isNotEmpty) {
          return CustomMarker(
            latLng: LatLng(lat, lon),
            child: Image.asset(
              'assets/images/red_marker.png',
              width: 10,
              height: 10,
              scale: 2.0,
            ),
            type: 'violation',
            id: id,
          );
        } else {
          print('Invalid violation entry: $entry');
          return null;
        }
      }).whereType<CustomMarker>().toList();

      setState(() {
        customMarkers.addAll(markers);
      });
    } catch (error) {
      print('Error fetching violation data: $error');
    }
  }

  Future<void> fetchReviewData() async {
    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/rest/reviews/points'));
      final List<dynamic> data = json.decode(response.body);

      List<CustomMarker> reviewMarkers = data.map((entry) {
        final lat = entry['lat'] as double?;
        final lon = entry['lon'] as double?;
        final id = entry['id'].toString();
        if (lat != null && lon != null && id.isNotEmpty) {
          return CustomMarker(
            latLng: LatLng(lat, lon),
            child: Image.asset(
              'assets/images/green_marker.png',
              width: 20,
              height: 20,
              scale: 2.0,
            ),
            type: 'review',
            id: id,
          );
        } else {
          print('Invalid review entry: $entry');
          return null;
        }
      }).whereType<CustomMarker>().toList();

      setState(() {
        customMarkers.addAll(reviewMarkers);
      });
    } catch (error) {
      print('Error fetching review data: $error');
    }
  }

  Future<void> fetchEventData() async {
    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/rest/events/points'));
      final List<dynamic> data = json.decode(response.body);

      List<CustomMarker> eventMarkers = data.map((entry) {
        final lat = entry['lat'] as double?;
        final lon = entry['lon'] as double?;
        final id = entry['id'].toString();
        if (lat != null && lon != null && id.isNotEmpty) {
          return CustomMarker(
            latLng: LatLng(lat, lon),
            child: Image.asset(
              'assets/images/blue_marker.png',
              width: 10,
              height: 10,
              scale: 2.0,
            ),
            type: 'event',
            id: id,
          );
        } else {
          print('Invalid event entry: $entry');
          return null;
        }
      }).whereType<CustomMarker>().toList();

      setState(() {
        customMarkers.addAll(eventMarkers);
      });
    } catch (error) {
      print('Error fetching event data: $error');
    }
  }

  Future<void> fetchSosData() async {
    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/rest/sos/points'));
      final List<dynamic> data = json.decode(response.body);
      print('Fetched sos data: $data');

      List<CustomMarker> sosMarkers = data.map((entry) {
        final lat = entry['lat'] as double?;
        final lon = entry['lon'] as double?;
        final id = entry['id'].toString();
        if (lat != null && lon != null && id.isNotEmpty) {
          return CustomMarker(
            latLng: LatLng(lat, lon),
            child: Image.asset(
              'assets/images/sos.png',
              width: 30,
              height: 30,
            ),
            type: 'sos',
            id: id,
          );
        } else {
          print('Invalid sos entry: $entry');
          return null;
        }
      }).whereType<CustomMarker>().toList();

      setState(() {
        customMarkers.addAll(sosMarkers);
      });
    } catch (error) {
      print('Error fetching sos data: $error');
    }
  }

  void navigateToDetailView(String type, String id) {
  print('Navigating to detail view for type: $type, id: $id');
  if (type == null || id == null) {
    print('Invalid type or id for navigation');
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        switch (type) {
          case 'violation':
            return DetailedViewApplicationPage(id: id, fetchData: fetchData);
          case 'review':
            return DetailedViewReviewPage(id: id, fetchData: fetchReviewData);
          case 'event':
            return DetailedViewEventPage(id: id, fetchData: fetchEventData);
          case 'sos':
            return DetailedViewSOSPage(
              sos: {'id': id}, 
              sosList: fetchSosData,
            );
          default:
            return Container();
        }
      },
    ),
  );
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
            markers: customMarkers.map((marker) => Marker(
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
                                navigateToDetailView(marker.type, marker.id);
                              },
                              child: Text('Перейти к деталям'),
                            ),
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
            )).toList(),
          ),
        ],
      ),
    );
  }
}

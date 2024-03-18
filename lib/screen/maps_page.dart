import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';


class MapsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('maps'.tr()),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(42.8746, 74.5698),
          zoom: 9.2,
          interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag | InteractiveFlag.rotate, // Используем параметр interactiveFlags для управления поведением карты
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
        ],
      ),
    );
  }
}


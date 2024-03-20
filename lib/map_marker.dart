import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapMarkerPage extends StatefulWidget {
  final Function(double, double)? onSave; // Изменим тип функции

  MapMarkerPage({Key? key, this.onSave}) : super(key: key);

  @override
  _MapMarkerPageState createState() => _MapMarkerPageState();
}

class _MapMarkerPageState extends State<MapMarkerPage> {
  double? _latitude; // Изменим тип переменных
  double? _longitude;

  void _handleTap(TapPosition pos, LatLng latLng) {
    setState(() {
      _latitude = latLng.latitude;
      _longitude = latLng.longitude;
    });
  }

 void _saveLocation() {
  if (_latitude != null && _longitude != null && widget.onSave != null) {
    widget.onSave!(_latitude!, _longitude!); // Вызываем функцию обратного вызова
  }
  Navigator.pop(context); // Закрываем страницу после сохранения
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
              if (_latitude != null && _longitude != null) // Изменим условие наличия маркера
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(_latitude!, _longitude!), // Используем текущие значения широты и долготы
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
          if (_latitude != null && _longitude != null) // Изменим условие отображения текста и кнопки
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
                        'Latitude: $_latitude',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Longitude: $_longitude',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _saveLocation,
                        child: Text('Сохранить'),
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

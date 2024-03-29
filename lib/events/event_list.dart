import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:jol_tartip_flutter/constants.dart';

class EventsList extends StatefulWidget {
  @override
  _EventsListState createState() => _EventsListState();
}

class _EventsListState extends State<EventsList> {
  List<dynamic> events = [];

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  void fetchEvents() async {
    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/rest/events/all'));
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        setState(() {
          events = decodedResponse;
        });
      } else {
        print('Failed to load events. Error code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching events: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('events'.tr()),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          fetchEvents();
        },
        child: ListView.builder(
          itemCount: events.length,
          itemBuilder: (BuildContext context, int index) {
            final event = events[index];
            if (event is Map<String, dynamic>) {
              return Padding(
                padding: EdgeInsets.all(8.0),
                child: Card(
                  elevation: 2.0,
                  child: ListTile(
                    title: Text(
                      event['title'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['description'],
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'address'.tr() + ' ${event['address']}',
                          style: TextStyle(fontWeight: FontWeight.normal, color: Colors.grey),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'lat: ${event['lat']}',
                          style: TextStyle(fontWeight: FontWeight.normal, color: Colors.grey),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'lon: ${event['lon']}',
                          style: TextStyle(fontWeight: FontWeight.normal, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Container(); // Или любой другой виджет по вашему выбору
            }
          },
        ),
      ),
    );
  }
}

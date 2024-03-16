import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Event {
  final String title;
  final String description;
  final String address;
  Event({required this.title, required this.description,required this.address});
}

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
      final response = await http.get(Uri.parse('http://172.26.192.1:8080/rest/events/all'));
      if (response.statusCode == 200) {
       final fetchedEvents = json.decode(utf8.decode(response.bodyBytes))
            .map((item) => Event(
                  title: item['title'],
                  description: item['description'],
                  address: item['address'],
                ))
            .toList();
        setState(() {
          events = fetchedEvents;
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
      title: Text('События'),
    ),
    body: ListView.builder(
      itemCount: events.length,
      itemBuilder: (BuildContext context, int index) {
        final event = events[index];
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: Card(
            elevation: 2.0,
            child: ListTile(
              title: Text(
                event.title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.description,
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Адрес: ${event.address}',
                    style: TextStyle(fontWeight: FontWeight.normal, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
}
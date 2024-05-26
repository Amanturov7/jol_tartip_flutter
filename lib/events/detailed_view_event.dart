import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jol_tartip_flutter/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailedViewEventPage extends StatefulWidget {
  final String id;
  final Function? fetchData; // Сделаем fetchData необязательным

  DetailedViewEventPage({required this.id, required this.fetchData});

  @override
  _DetailedViewEventPageState createState() => _DetailedViewEventPageState();
}

class _DetailedViewEventPageState extends State<DetailedViewEventPage> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController addressController;
  late TextEditingController startDateController;
  late TextEditingController endDateController;

  Map<String, dynamic>? eventData;
  int? userId;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    addressController = TextEditingController();
    startDateController = TextEditingController();
    endDateController = TextEditingController();
    fetchData(); // Assuming this method populates the controllers with data
  }

  Future<void> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/rest/user/user?token=$token'),
        headers: <String, String>{
          'token': token,
        },
      );
      if (response.statusCode == 200) {
        final userData = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          userId = userData['id'];
        });
      } else {
        throw Exception('Failed to load user data');
      }
    }
    try {
      final response = await http.get(Uri.parse("${Constants.baseUrl}/rest/events/event/${widget.id}"));

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          eventData = jsonData;
          titleController.text = eventData?['title'] ?? '';
          descriptionController.text = eventData?['description'] ?? '';
          addressController.text = eventData?['address'] ?? '';
          startDateController.text = eventData?['startDate']?.toString() ?? '';
          endDateController.text = eventData?['endDate']?.toString() ?? '';
        });
      } else {
        throw Exception('Failed to load event details');
      }
    } catch (error) {
      print('Error fetching event details: $error');
    }
  }

  Future<void> deleteEvent() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      try {
        final response = await http.delete(
          Uri.parse('${Constants.baseUrl}/rest/events/delete/${widget.id}'),
          headers: <String, String>{
            'token': token,
          },
        );
        if (response.statusCode == 204) {
          // Событие успешно удалено
          Navigator.pop(context); // Возвращаемся на предыдущий экран
          // Обновляем список событий
          if (widget.fetchData != null) {
            widget.fetchData!();
          }
        } else {
          throw Exception('Failed to delete event');
        }
      } catch (error) {
        print('Error deleting event: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          eventData != null ? eventData!['title'] ?? '' : '',
        ),
        actions: [
          if (userId != null && eventData != null && userId == eventData!['userId'])
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Удалить'),
                      content: Text('Вы хотите удалить событие?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Закрываем диалоговое окно
                          },
                          child: Text('Нет'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Вызываем функцию для удаления события
                            deleteEvent();
                            // Закрываем диалоговое окно
                            Navigator.of(context).pop();
                          },
                          child: Text('Да'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.delete),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Column(
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Название',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  readOnly: true,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Описание',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  readOnly: true,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Адрес',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  readOnly: true,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: startDateController,
                  decoration: InputDecoration(
                    labelText: 'Дата начала',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  readOnly: true,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: endDateController,
                  decoration: InputDecoration(
                    labelText: 'Дата окончания',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  readOnly: true,
                ),
                // Add other form fields similarly
              ],
            ),
          ],
        ),
      ),
    );
  }
}

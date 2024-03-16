import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

class EventFormPage extends StatefulWidget {
  @override
  _EventFormPageState createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController dateStartController = TextEditingController();
  TextEditingController timeStartController = TextEditingController();

 TextEditingController dateEndController = TextEditingController();
  TextEditingController timeEndController = TextEditingController();

  DateTime? _startDateTime;
  DateTime? _endDateTime;
  TextEditingController _addressController = TextEditingController();
  int? _selectedEventType;
  int userId = 0;
  List<dynamic> _eventTypes = []; // Список типов событий

  @override
  void initState() {
    super.initState();
    fetchEventTypes(); // Вызываем функцию загрузки типов событий при инициализации страницы
  }

  Future<void> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      final response = await http.get(
        Uri.parse('http://172.26.192.1:8080/rest/user/user?token=$token'),
        headers: <String, String>{
          'token': token,
        },
      );
      if (response.statusCode == 200) {
final userData = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          userId = userData['id'] ?? 0;
        });
      } else {
        throw Exception('Failed to load user data');
      }
    }
  }

  // Функция для загрузки типов событий с сервера
  void fetchEventTypes() async {
    try {
      final response = await http.get(
          Uri.parse('http://172.26.192.1:8080/rest/common-reference/by-type/006'));
      if (response.statusCode == 200) {
        // Если запрос успешен, декодируем полученные данные из JSON
        final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;

        // Создаем список типов событий, извлекая title и id
        List<Map<String, dynamic>> eventTypes = [];
        for (var item in data) {
          eventTypes.add({
            'title': item['title'],
            'id': item['id'],
          });
        }

        // Обновляем список типов событий в состоянии
        setState(() {
          _eventTypes = eventTypes;
        });
      } else {
        throw Exception('Failed to load event types');
      }
    } catch (error) {
      print('Error fetching event types: $error');
    }
  }

  // Функция для отправки данных формы
 void submit() async {
  try {
    final int startDateInMillis = _startDateTime!.millisecondsSinceEpoch;
    final int endDateInMillis = _endDateTime!.millisecondsSinceEpoch;

    final response = await http.post(
      Uri.parse('http://172.26.192.1:8080/rest/events/create'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'title': _titleController.text,
        'description': _descriptionController.text,
        'startDate': startDateInMillis,
        'endDate': endDateInMillis,
        'address': _addressController.text,
        'typeEventId': _selectedEventType,
        'userId': userId,
      }),
    );

    print('Response: ${response.body}');

    _titleController.clear();
    _descriptionController.clear();
    _addressController.clear();

    // Дополнительные действия после успешной отправки формы
  } catch (error) {
    print('Error creating event: $error');
  }
}

Future<void> selectStartDateAndTime() async {
  final DateTime? pickedDateAndTime = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  if (pickedDateAndTime != null) {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _startDateTime = DateTime(
          pickedDateAndTime.year,
          pickedDateAndTime.month,
          pickedDateAndTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        dateStartController.text = DateFormat('yyyy-MM-dd HH:mm').format(_startDateTime!);
        timeStartController.text = DateFormat('HH:mm').format(_startDateTime!);
      });
    }
  }
}

Future<void> selectEndDateAndTime() async {
  final DateTime? pickedDateAndTime = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  if (pickedDateAndTime != null) {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _endDateTime = DateTime(
          pickedDateAndTime.year,
          pickedDateAndTime.month,
          pickedDateAndTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        dateEndController.text = DateFormat('yyyy-MM-dd HH:mm').format(_endDateTime!);
        timeEndController.text = DateFormat('HH:mm').format(_endDateTime!);
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cобытие'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Заголовок',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Описание',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
            SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  controller: dateStartController,
                  onTap: selectStartDateAndTime,
                  decoration: InputDecoration(
                    hintText: 'Дата и время начала', 
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      color: Color(0xFF3BB5E9), 
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF3BB5E9)), 
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
            SizedBox(height: 16),
            TextFormField(
                  readOnly: true,
                  controller: dateEndController,
                  onTap: selectEndDateAndTime,
                  decoration: InputDecoration(
                    hintText: 'Дата и время начала', 
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      color: Color(0xFF3BB5E9), 
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF3BB5E9)), 
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
            SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Адрес',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField(
              value: _selectedEventType,
              items: _eventTypes.map<DropdownMenuItem<int>>((eventType) {
                return DropdownMenuItem<int>(
                  value: eventType['id'] as int,
                  child: Text(eventType['title'].toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedEventType = value as int;
                });
              },
              decoration: InputDecoration(
                hintText: 'Выберите тип события',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: submit,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                alignment: Alignment.center,
                child: Text(
                  'Сохранить',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3BB5E9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: Size(double.infinity, 70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

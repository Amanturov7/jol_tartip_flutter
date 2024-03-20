import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jol_tartip_flutter/constants.dart';

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
  List<dynamic> _eventTypes = [];

  @override
  void initState() {
    fetchData();
    super.initState();
    fetchEventTypes();
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
          userId = userData['id'] ?? 0;
        });
      } else {
        throw Exception('Failed to load user data');
      }
    }
  }

  void fetchEventTypes() async {
    try {
      final response = await http.get(
          Uri.parse('${Constants.baseUrl}/rest/common-reference/by-type/006'));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;

        List<Map<String, dynamic>> eventTypes = [];
        for (var item in data) {
          eventTypes.add({
            'title': item['title'],
            'id': item['id'],
          });
        }

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

  void submit() async {
    try {
      int? startDateInMillis;
      int? endDateInMillis;

      if (_startDateTime != null) {
        startDateInMillis = _startDateTime!.millisecondsSinceEpoch;
      } else {
        print('Error: _startDateTime is null');
        return; 
      }

      if (_endDateTime != null) {
        endDateInMillis = _endDateTime!.millisecondsSinceEpoch;
      } else {
        print('Error: _endDateTime is null');
        return;
      }

      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/rest/events/create'),
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

      // Показываем диалоговое окно об успешном сохранении события
  
       showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('success'.tr()),
          content: Text('event_saved_successfully'.tr()),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрываем диалоговое окно
                Navigator.of(context).pop(); // Закрываем страницу
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
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
        title: Text('events'.tr()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'title'.tr(),
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
                hintText: 'description'.tr(),
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
                hintText: 'start_date_time'.tr(), 
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                suffixIcon: Icon(
                  Icons              .calendar_today,
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
            hintText: 'end_date_time'.tr(), 
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
            hintText: 'address'.tr(),
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
            hintText: 'select_event_type'.tr(),
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
              'save'.tr(),
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


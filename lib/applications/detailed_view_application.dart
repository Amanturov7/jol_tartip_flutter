import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:jol_tartip_flutter/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailedViewApplicationPage extends StatefulWidget {
  final String id;
    final Function? fetchData; // Сделаем fetchData необязательным

  DetailedViewApplicationPage({required this.id, required this.fetchData});

  @override
  _DetailedViewApplicationPageState createState() =>
      _DetailedViewApplicationPageState();
}

class _DetailedViewApplicationPageState
    extends State<DetailedViewApplicationPage> {
  late TextEditingController titleController;
  late TextEditingController dateController;
  late TextEditingController numberAutoController;
  late TextEditingController descriptionController;

  List<dynamic> violationsList = [];
  Map<String, dynamic>? applicationData;
  int? userId;

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchViolations();
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
      final response = await http
          .get(Uri.parse("${Constants.baseUrl}/rest/applications/${widget.id}"));

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          applicationData = jsonData;
          titleController =
              TextEditingController(text: applicationData!['title']);
          dateController = TextEditingController(
              text: applicationData!['dateOfViolation']);
          numberAutoController =
              TextEditingController(text: applicationData!['numberAuto']);
          descriptionController =
              TextEditingController(text: applicationData!['description']);
        });
      } else {
        throw Exception('Failed to load application details');
      }
    } catch (error) {
      print('Error fetching application details: $error');
    }
  }

  Future<void> fetchViolations() async {
    try {
      final response =
          await http.get(Uri.parse('${Constants.baseUrl}/rest/violations/all'));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        setState(() {
          violationsList = data;
        });
      }
    } catch (error) {
      print('Error fetching violations: $error');
    }
  }

 Future<void> deleteApplication() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token != null) {
    try {
      final response = await http.delete(
        Uri.parse('${Constants.baseUrl}/rest/applications/delete/${widget.id}'),
        headers: <String, String>{
          'token': token,
        },
      );
      if (response.statusCode == 200) {
        // Нарушение успешно удалено
        Navigator.pop(context); // Возвращаемся на предыдущий экран
        // Обновляем список нарушений
        fetchViolations();
          if (widget.fetchData != null) {
    widget.fetchData!();
  }
      } else {
        throw Exception('Failed to delete application');
      }
    } catch (error) {
      print('Error deleting application: $error');
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'violation_number'.tr() + ' ${applicationData!['id']}',
        ),
        actions: [
          if (userId != null && userId == applicationData!['userId'])
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Удалить'),
                      content: Text('Вы хотите удалить нарушение?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Закрываем диалоговое окно
                          },
                          child: Text('Нет'),
                        ),
                        TextButton(
                          onPressed: () {
  // Вызываем функцию для удаления нарушения
  deleteApplication();
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
      body: applicationData != null
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Scaffold(
                            appBar: AppBar(),
                            body: Center(
                              child: Hero(
                                tag: 'image${applicationData!['id']}',
                                child: Image.network(
                                  '${Constants.baseUrl}/rest/attachments/download/applications/${widget.id}',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: NetworkImage(
                              '${Constants.baseUrl}/rest/attachments/download/applications/${widget.id}'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      TextFormField(
                        controller:
                            TextEditingController(text: applicationData!['title']),
                        decoration: InputDecoration(
                          labelText: 'violation_type'.tr(),
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
                      SizedBox(height: 10),
                      TextFormField(
                        controller: dateController,
                        decoration: InputDecoration(
                          labelText: 'Date_time_violation'.tr(),
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
                      SizedBox(height: 10),
                      TextFormField(
                        controller: numberAutoController,
                        decoration: InputDecoration(
                          labelText: 'gos_nomer'.tr(),
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
                      SizedBox(height: 10),
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'description'.tr(),
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
                    ],
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class ViolationFormPage extends StatefulWidget {
  
  @override
  _ViolationFormPageState createState() => _ViolationFormPageState();
}

class _ViolationFormPageState extends State<ViolationFormPage> {
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }
  String description = '';
  String place = '';
  double lat = 0.0;
  double lon = 0.0;
  String status = '';
  DateTime? dateAndTimeOfViolation;
  int regionId= 1;
  int districtId=1;
  int typeViolationsId = 0;
  int userId = 0;
  String numberAuto = '';
  File? _image;

  List<Map<String, dynamic>> violationsList = [];
  int? selectedViolationIndex;

  @override
  void initState() {
    super.initState();
    selectedViolationIndex = null; // Set selectedViolationIndex to null
    fetchData();
    fetchViolations();
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

  Future<void> fetchViolations() async {
    try {
      final Uri url = Uri.parse('http://172.26.192.1:8080/rest/violations/all');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        setState(() {
          violationsList = data.map((e) => e as Map<String, dynamic>).toList();
        });
      }
    } catch (error) {
      print('Error fetching violations: $error');
    }
  }

  Future<void> submitForm() async {
    var url = Uri.parse('http://172.26.192.1:8080/rest/applications/create');
    var headers = {'Content-Type': 'application/json'};
    final int timestamp = dateAndTimeOfViolation!.millisecondsSinceEpoch;
    var body = jsonEncode({
      'description': description,
      'place': place,
      'lat': lat,
      'lon': lon,
      'status': status,
      'dateOfViolation': timestamp,
      'regionId': regionId,
      'districtId': districtId,
      'typeViolationsId': typeViolationsId,
      'userId': userId,
      'numberAuto': numberAuto,
    });

    try {
      var response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Data submitted successfully
        print('Form submitted successfully');
        var responseData = jsonDecode(response.body);
        var applicationId = responseData['id'];
        if (_image != null) {
          // Upload file if selected
          await uploadFile(applicationId);
        }
      } else {
        // Failed to submit form
        print('Failed to submit form');
      }
    } catch (error) {
      print('Error creating application: $error');
    }
  }

Future<void> uploadFile(int applicationId) async {
  var url = Uri.parse('http://172.26.192.1:8080/rest/attachments/upload');
  var request = http.MultipartRequest('POST', url);

  // Добавляем данные 'dto' в виде JSON-строки
  request.fields['dto'] = jsonEncode({
  'type': 'application',
  'originName': File(_image!.path).path.split('/').last,
  'description': 'File description', // Добавьте описание здесь
  'userId': userId.toString(), // Добавьте идентификатор пользователя здесь
  'applicationsId': applicationId.toString(), // Добавьте идентификатор заявки здесь
  // Добавьте остальные поля 'dto' здесь...
});

  // Добавляем остальные поля запроса

  // Добавляем файл как часть запроса
  request.files.add(await http.MultipartFile.fromPath(
    'file',
    _image!.path,
    contentType: MediaType('image', 'jpeg'), // Можете уточнить contentType по необходимости
  ));

  try {
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      // Файл успешно загружен
      print('Файл успешно загружен');
    } else {
      // Не удалось загрузить файл
      print('Не удалось загрузить файл. Статус код: ${response.statusCode}');
    }
  } catch (error) {
    print('Ошибка загрузки файла: $error');
  }
}

// Метод для выбора даты и времени
Future<void> selectDateAndTime() async {
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
        dateAndTimeOfViolation = DateTime(
          pickedDateAndTime.year,
          pickedDateAndTime.month,
          pickedDateAndTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        dateController.text = DateFormat('yyyy-MM-dd HH:mm').format(dateAndTimeOfViolation!);
        timeController.text = DateFormat('HH:mm').format(dateAndTimeOfViolation!);
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Обращение о нарушении'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 8),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                },
                decoration: InputDecoration(hintText: 'Описание',   border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                         focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF3BB5E9)), // Установите желаемый цвет для границы при активном состоянии
      borderRadius: BorderRadius.circular(30.0),
    ),),
                                      
              ),
              SizedBox(height: 8),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    place = value;
                  });
                },
                decoration: InputDecoration(hintText: 'Адрес',  border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                         focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF3BB5E9)), // Установите желаемый цвет для границы при активном состоянии
      borderRadius: BorderRadius.circular(30.0),
    ),),
                
              ),
              SizedBox(height: 8),
        TextFormField(
  readOnly: true,
  controller: dateController,
  onTap: selectDateAndTime,
  decoration: InputDecoration(
    hintText: 'Дата и время нарушения', 
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.0),
    ),
    suffixIcon: Icon(
      Icons.calendar_today,
      color: Color(0xFF3BB5E9), // Установите желаемый цвет для иконки календаря
    ),

    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF3BB5E9)), // Установите желаемый цвет для границы при активном состоянии
      borderRadius: BorderRadius.circular(30.0),
    ),
  ),
),

              SizedBox(height: 8),
              DropdownButtonFormField<int?>(
                value: selectedViolationIndex,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                     focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF3BB5E9)), // Установите желаемый цвет для границы при активном состоянии
      borderRadius: BorderRadius.circular(30.0),
    ),
                ),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Выберите тип нарушения'),
                  ),
                  ...violationsList.map((violation) {
                    return DropdownMenuItem<int>(
                      value: violation['id'] as int,
                      child: Text(violation['title'] as String),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedViolationIndex = value;
                    typeViolationsId = value ?? 0; // Если value равно null, используйте значение по умолчанию, например, 0
                  });
                },
              ),
              SizedBox(height: 8),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    numberAuto = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Гос номер', 
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF3BB5E9)), // Установите желаемый цвет для границы при активном состоянии
                    borderRadius: BorderRadius.circular(30.0),
                  ),),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  // Get image from gallery
                  var image = await getImageFromGallery();
                  setState(() {
                    _image = image;
                  });
                },
                child: Text('Из галереи'),
                
              ),
              ElevatedButton(
                onPressed: () async {
                  // Take a photo with camera
                  var image = await takePhoto();
                  setState(() {
                    _image = image;
                  });
                },
                child: Text('Открыть камеру'),
              ),
              ElevatedButton(
    onPressed: submitForm,
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
      ),
    );
  }

  Future<File?> getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      return null;
    }
  }

  Future<File?> takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      return null;
    }
  }
}

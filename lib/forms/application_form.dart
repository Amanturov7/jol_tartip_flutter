import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:jol_tartip_flutter/constants.dart';

class ViolationFormPage extends StatefulWidget {
  @override
  _ViolationFormPageState createState() => _ViolationFormPageState();
}

class _ViolationFormPageState extends State<ViolationFormPage> {
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); 
  late TextEditingController _numberAutoController;
  String description = '';
  String place = '';
  double lat = 0.0;
  double lon = 0.0;
  String status = '';
  DateTime? dateAndTimeOfViolation;
  int regionId = 1;
  int districtId = 1;
  int typeViolationsId = 0;
  int userId = 0;
  String numberAuto = '';
  File? _image;

  List<Map<String, dynamic>> violationsList = [];
  int? selectedViolationIndex;

@override
void initState() {
  fetchData();
  super.initState();
  selectedViolationIndex = null;
      _numberAutoController = TextEditingController(text: numberAuto);
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
        final userData = jsonDecode(response.body);
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
      final Uri url = Uri.parse('${Constants.baseUrl}/rest/violations/all');
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
    if (_image == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('error'.tr()),
            content: Text('please_select_image'.tr()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      var url = Uri.parse('${Constants.baseUrl}/rest/applications/create');
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
          print('Form submitted successfully');
          var responseData = jsonDecode(response.body);
          var applicationId = responseData['id'];
          if (_image != null) {
            await uploadFile(applicationId);
          }
        } else {
          print('Failed to submit form');
        }
      } catch (error) {
        print('Error creating application: $error');
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('success'.tr()),
            content: Text('reviw_saved'.tr()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> uploadFile(int applicationId) async {
    var url = Uri.parse('${Constants.baseUrl}/rest/attachments/upload');
    var request = http.MultipartRequest('POST', url);

    request.fields['dto'] = jsonEncode({
      'type': 'application',
      'originName': File(_image!.path).path.split('/').last,
      'description': 'File description',
      'userId': userId.toString(),
      'applicationsId': applicationId.toString(),
    });

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      _image!.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        print('Файл успешно загружен');
      } else {
        print('Не удалось загрузить файл. Статус код: ${response.statusCode}');
      }
    } catch (error) {
      print('Ошибка загрузки файла: $error');
    }
  }

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
        title: Text('violation'.tr()),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, 
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите описание';
                    }
                    return null;
                  },
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
                SizedBox(height: 8),
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      place = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите адрес';
                    }
                    return null;
                  },
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
                SizedBox(height: 8),
                TextFormField(
                  readOnly: true,
                  controller: dateController,
                  onTap: selectDateAndTime,
                    validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите Дату и время нарушения';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Date_time_violation'.tr(),
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
                SizedBox(height: 8),
                DropdownButtonFormField<int?>(
                  value: selectedViolationIndex,
                  onChanged: (value) {
                    setState(() {
                      selectedViolationIndex = value;
                      typeViolationsId = value ?? 0;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Пожалуйста, выберите тип нарушения';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Выберите тип нарушения',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text('select_violation_type'.tr()),
                    ),
                    ...violationsList.map((violation) {
                      return DropdownMenuItem<int>(
                        value: violation['id'] as int,
                        child: Text(violation['title'] as String),
                      );
                    }).toList(),
                  ],
                ),
                SizedBox(height: 8),
        TextFormField(
      controller: _numberAutoController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Пожалуйста, введите номер автомобиля';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          numberAuto = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'gos_nomer'.tr(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF3BB5E9)),
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    var image = await getImageFromGallery();
                    setState(() {
                      _image = image;
                    });
                  },
                  child: Text('from_gallery'.tr()),
                ),
                ElevatedButton(
                  onPressed: () async {
                    var image = await takePhoto();
                    setState(() {
                      _image = image;
                    });
                  },
                  child: Text('open_camera'.tr()),
                ),
                ElevatedButton(
                  onPressed: submitForm,
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

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
class ReviewForm extends StatefulWidget {
  @override
  _ReviewFormPageState createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewForm> {
  String? reviewType;
  List<String> reviewTypes = ['Дорожный знак', 'Освещение', 'Дорожные условия', 'Экологические факторы'];
  String? selectedOption;
  List<String> options = [];
  double lat = 0;
  double lon = 0;
  String locationAddress = '';
  String description = '';
  int userId = 0;
  bool isMapModalOpen = false;
  Map<String, double> selectedCoordinate = {'lat': 0, 'lon': 0};
  int roadId = 0;
  int lightId = 0;
  int roadSignId = 0;
  int ecologicFactorsId = 0;
  File? _image;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        final response = await http.get(Uri.parse('http://localhost:8080/rest/user/user'), 
          headers: {
            'token': token,
          }
        );
        setState(() {
          userId = jsonDecode(response.body)['id'];
        });
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }



  void handleReviewTypeChange(String? type) async {
    setState(() {
      reviewType = type;
          selectedOption = null; // Обнуляем выбранный вид отзыва при изменении типа

    });

    try {
      final url = Uri.parse('http://172.26.192.1:8080/rest/common-reference/by-type/${getTypeReferenceType(type)}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<String> fetchedOptions = [];
        final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        for (final item in data) {
          fetchedOptions.add(item['title']);
        }
        setState(() {
          options = fetchedOptions;
        });
      } else {
        print('Failed to load options. Error code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching options: $error');
    }
  }

  String getTypeReferenceType(String? type) {
    switch (type) {
      case 'Дорожный знак':
        return '003';
      case 'Освещение':
        return '004';
      case 'Дорожные условия':
        return '005';
      case 'Экологические факторы':
        return '007';
      default:
        return '';
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
void handleSelectImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> uploadFile(int reviewsId) async {
    var url = Uri.parse('http://172.26.192.1:8080/rest/attachments/upload');
    var request = http.MultipartRequest('POST', url);

    request.fields['dto'] = jsonEncode({
      'type': 'review',
      'originName': _image!.path.split('/').last,
      'description': 'File description', // Добавьте описание здесь
      'userId': userId.toString(), // Добавьте идентификатор пользователя здесь
      'reviewsId': reviewsId.toString(), // Добавьте идентификатор заявки здесь
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


void handleSubmit() async {
  if (_image == null) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ошибка'),
          content: Text('Пожалуйста, выберите изображение перед сохранением.'),
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

  if (locationAddress.isEmpty) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ошибка'),
          content: Text('Пожалуйста, укажите адрес перед сохранением заявки.'),
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

  try {
    final response = await http.post(
      Uri.parse('http://172.26.192.1:8080/rest/reviews/create'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'lat': selectedCoordinate['lat'],
        'lon': selectedCoordinate['lon'],
        'locationAddress': locationAddress,
        'description': description,
        'userId': userId,
        'reviewType': reviewType,
      }),
    );

    final responseData = jsonDecode(response.body);


      if (_image != null) {
          await uploadFile(responseData['id']);
        }

    print('Review created: $responseData');

    // Clear form fields and image after successful submission
    setState(() {
      reviewType = null;
      selectedOption = null;
      locationAddress = '';
      description = '';
      _image = null;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Успех'),
          content: Text('Отзыв успешно создан.'),
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
  } catch (error) {
    print('Error creating review: $error');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ошибка'),
          content: Text('Произошла ошибка при создании отзыва: $error'),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Form'),
      ),
      body: Form(
        child: Column(
          children: [
            DropdownButton<String>(
              value: reviewType,
              
              hint: Text('Выберите тип отзыва'),
              onChanged: handleReviewTypeChange,
              items: reviewTypes.map((String type) {
                return DropdownMenuItem<String>(
                  
                  value: type,
                  child: Text(type),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedOption,
              
              hint: Text('Выберите вид отзыва'),
              onChanged: (String? value) {
                setState(() {
                  selectedOption = value;
                });
              },
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
            ),
                    
                            SizedBox(height: 8),

            TextFormField(
              onChanged: (value) {
                setState(() {
                  locationAddress = value;
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
              onChanged: (value) {
                setState(() {
                  description = value;
                });
              },
              decoration: InputDecoration(hintText: 'Описание',  border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                         focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF3BB5E9)), // Установите желаемый цвет для границы при активном состоянии
      borderRadius: BorderRadius.circular(30.0),
    ),),
            ),
                  SizedBox(height: 8),

             ElevatedButton(
              onPressed: handleSelectImage,
              child: Text('Выбрать изображение'),
            ),
                ElevatedButton(
                onPressed: () async {
                  // Take a photo with camera
                  var image = await takePhoto();
                  setState(() {
                    _image = image;
                  });
                },
                
                child: Text('Открыть камеру',),
              ),
                          SizedBox(height: 8),

           ElevatedButton(
    onPressed: handleSubmit,
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

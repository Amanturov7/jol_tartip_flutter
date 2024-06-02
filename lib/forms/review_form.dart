import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jol_tartip_flutter/compress_image.dart';
import 'package:jol_tartip_flutter/forms/image_selector_box.dart';
import 'package:jol_tartip_flutter/map_marker.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:jol_tartip_flutter/constants.dart';

class ReviewForm extends StatefulWidget {
  @override
  _ReviewFormPageState createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewForm> {
  final _formKey = GlobalKey<FormState>();

  String? reviewType;
  List<String> reviewTypes = [
    'Дорожный знак',
    'Освещение',
    'Дорожные условия',
    'Экологические факторы'
  ];
  String? selectedOption;
  List<String> options = [];
  double lat = 0;
  double lon = 0;
  String locationAddress = '';
  String description = '';
  int userId = 0;
  File? _image;
  int? roadId;
  int? lightId;
  int? roadSignId;
  int? ecologicFactorsId;

  @override
  void initState() {
    fetchData();
    super.initState();
  }




void _handleLocationSelection(double latitude, double longitude) {
  setState(() {
    lat = latitude;
    lon = longitude;
    print(lat);
    print(lon);
  });
}


  void _selectLocation() async {
  final location = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => MapMarkerPage()),
  );

  if (location != null) {
    setState(() {
      lat = location[0]; 
      lon = location[1]; 
      print(lat);
      print(lon);
    });
  }
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

  void handleReviewTypeChange(String? type) async {
    setState(() {
      reviewType = type;
      selectedOption = null;
    });

    switch (type) {
      case 'Дорожный знак':
        roadSignId = null; 
        break;
      case 'Освещение':
        lightId = null; 
        break;
      case 'Дорожные условия':
        roadId = null;
        break;
      case 'Экологические факторы':
        ecologicFactorsId = null; 
        break;
    }

    try {
      final url = Uri.parse(
          '${Constants.baseUrl}/rest/common-reference/by-type/${getTypeReferenceType(type)}');
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

    if (selectedOption != null) {
      switch (type) {
        case 'Дорожный знак':
          roadSignId = options.indexOf(selectedOption!);
          break;
        case 'Освещение':
          lightId = options.indexOf(selectedOption!);
          break;
        case 'Дорожные условия':
          roadId = options.indexOf(selectedOption!);
          break;
        case 'Экологические факторы':
          ecologicFactorsId = options.indexOf(selectedOption!);
          break;
      }
    }
  }

  int? getTypeReferenceId(String? type) {
    switch (type) {
      case 'Дорожный знак':
        return roadSignId;
      case 'Освещение':
        return lightId;
      case 'Дорожные условия':
        return roadId;
      case 'Экологические факторы':
        return ecologicFactorsId;
      default:
        return null;
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

  void handleSubmit() async {
    if (_formKey.currentState!.validate()) {
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
    }
      File compressedImage = await compressImage(_image!);


    if (locationAddress.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('error'.tr()),
            content: Text('please_address'),
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
        Uri.parse('${Constants.baseUrl}/rest/reviews/create'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'lat': lat,
          'lon': lon,
          'locationAddress': locationAddress,
          'description': description,
          'userId': userId,
          "roadId": roadId,
          "lightId": lightId,
          "roadSignId": roadSignId,
          "ecologicFactorsId": ecologicFactorsId
        }),
      );

      final responseData = jsonDecode(response.body);

      if (compressedImage != null) {
        await uploadFile(responseData['id'], compressedImage);
      }

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
            title: Text('success'.tr()),
            content: Text('review_saved'.tr()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('error'.tr()),
            content: Text('review_save_error'.tr() + ' $error'),
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

  Future<void> uploadFile(int reviewsId, File imageFile) async {
    var url = Uri.parse('${Constants.baseUrl}/rest/attachments/upload');
    var request = http.MultipartRequest('POST', url);

    request.fields['dto'] = jsonEncode({
      'type': 'review',
      'originName': File(imageFile.path).path.split('/').last,
      'description': 'File description',
      'userId': userId.toString(),
      'reviewsId': reviewsId.toString(),
    });

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      imageFile!.path,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('review'.tr()),
      ),
      body: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 16),

        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16),
              Container(
                child: DropdownButtonFormField<String>(
                  value: reviewType,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, выберите тип отзыва';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'select_review_type'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onChanged: handleReviewTypeChange,
                  items: reviewTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 8),
              Container(
                child: DropdownButtonFormField<String>(
                  value: selectedOption,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, выберите вид отзыва';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'select_review_type'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      selectedOption = value;

                      switch (reviewType) {
                        case 'Дорожный знак':
                          roadSignId = options.indexOf(selectedOption!);
                          break;
                        case 'Освещение':
                          lightId = options.indexOf(selectedOption!);
                          break;
                        case 'Дорожные условия':
                          roadId = options.indexOf(selectedOption!);
                          break;
                        case 'Экологические факторы':
                          ecologicFactorsId = options.indexOf(selectedOption!);
                          break;
                      }
                    });
                  },
                  items: options.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 8),
              Container(
                child: TextFormField(
                  onChanged: (value) {
                    setState(() {
                      locationAddress = value;
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
              ),
              SizedBox(height: 8),
              Container(
                child: TextFormField(
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
              ),
                SizedBox(height: 8),
                ImageSelectorBox(
                  onSelectImage: (image) {
                    setState(() {
                      _image = image;
                    });
                  },
                  imageFile: _image,
                ),
                       SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapMarkerPage(
                          onSave: _handleLocationSelection, 
                        ),
                      ),
                    );
                  },
                  
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      'Указать адрес на карте',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 169,208,158),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: Size(double.infinity, 70),
                  ),
                ),
              SizedBox(height: 8),
              Container(
                child: ElevatedButton(
                  onPressed: handleSubmit,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

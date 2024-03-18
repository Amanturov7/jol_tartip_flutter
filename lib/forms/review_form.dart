import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  String? reviewType;
  List<String> reviewTypes = ['Дорожный знак', 'Освещение', 'Дорожные условия', 'Экологические факторы'];
  String? selectedOption;
  List<String> options = [];
  double lat = 0;
  double lon = 0;
  String locationAddress = '';
  String description = '';
  int userId = 0;
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
        final response = await http.get(Uri.parse('${Constants.baseUrl}/rest/user/user'), 
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
      selectedOption = null;
    });

    try {
      final url = Uri.parse('${Constants.baseUrl}/rest/common-reference/by-type/${getTypeReferenceType(type)}');
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

  void handleSubmit() async {
    // Check if an image is selected
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


  Future<void> uploadFile(int reviewsId) async {
    var url = Uri.parse('${Constants.baseUrl}/rest/attachments/upload');
    var request = http.MultipartRequest('POST', url);

    request.fields['dto'] = jsonEncode({
      'type': 'review',
      'originName': _image!.path.split('/').last,
      'description': 'File description', 
      'userId': userId.toString(), 
      'reviewsId': reviewsId.toString(), 
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

    // Handle form submission
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
          'reviewType': reviewType,
        }),
      );

      final responseData = jsonDecode(response.body);

      // Upload image
      if (_image != null) {
        await uploadFile(responseData['id']);
      }

      // Reset form fields
      setState(() {
        reviewType = null;
        selectedOption = null;
        locationAddress = '';
        description = '';
        _image = null;
      });

      // Show success dialog
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
    } catch (error) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('error'.tr()),
            content: Text('review_save_error'.tr() +' $error'),
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
        title: Text('review'.tr()),
      ),
      body: SingleChildScrollView(
        child:Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
                  SizedBox(height: 16),

    Container(
      
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<String>(
        value: reviewType,
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
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<String>(
        value: selectedOption,
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
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        onChanged: (value) {
          setState(() {
            locationAddress = value;
          });
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
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        onChanged: (value) {
          setState(() {
            description = value;
          });
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
    Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: handleSelectImage,
        child: Text('select_image'.tr()),
      ),
    ),
    SizedBox(height: 8),
    Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () async {
          var image = await takePhoto();
          setState(() {
            _image = image;
          });
        },
        child: Text('open_camera'.tr()),
      ),
    ),
    SizedBox(height: 8),
    Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
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
)



      ),
    );
  }
}

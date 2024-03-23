import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:jol_tartip_flutter/constants.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class UserDataPage extends StatefulWidget {
  @override
  _UserDataPageState createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  String username = '';
  String passportSerial = '';
  String email = '';
  int id = 0;
  String role = '';
  String address = '';
  DateTime? signupDate;
  BigInt? phone;
  BigInt? inn;
  File? _image;

  bool isLoading = false;
  bool isEditing = false;

  Uint8List? _avatarImageBytes;
  bool isAvatarLoading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
            fetchData();

  }

Future<void> fetchData() async {
  setState(() {
    isLoading = true;
  });

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
        id = userData['id'] ?? 0;
        username = userData['username'] ?? '';
        email = userData['email'] ?? '';
        passportSerial = userData['passportSerial'] ?? '';
        role = userData['role'] ?? '';
        address = userData['address'] ?? '';
        signupDate = DateTime.tryParse(userData['signupDate'] ?? '');
        phone = BigInt.tryParse(userData['phone'].toString()) ?? BigInt.zero;
        inn = BigInt.tryParse(userData['inn'].toString()) ?? BigInt.zero;
        isLoading = false;
      });
      loadAvatarIfNeeded(); // Вызываем загрузку аватарки после получения данных пользователя
    } else {
      throw Exception('Failed to load user data');
    }
  }
}


Future<void> loadAvatar() async {
  setState(() {
    isAvatarLoading = true;
  });
  try {
    final avatarBytes = await fetchAvatar(id);
    setState(() {
      _avatarImageBytes = avatarBytes;
      isAvatarLoading = false; // Обновляем состояние после успешной загрузки
    });
  } catch (e) {
    print('Error loading avatar: $e');
    setState(() {
      isAvatarLoading = false; // Обновляем состояние в случае ошибки
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ошибка загрузки'),
          content: Text('Не удалось загрузить аватар пользователя. Пожалуйста, проверьте ваше подключение к интернету и попробуйте снова.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('ОК'),
            ),
          ],
        );
      },
    );
  }
}



    Future<Uint8List> fetchAvatar(int id) async {
    final url = Uri.parse('${Constants.baseUrl}/rest/attachments/download/avatar/user/4');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load user avatar');
    }
  }


Future<void> loadAvatarIfNeeded() async {
  if (_avatarImageBytes == null) {
    await loadAvatar();
  }
}

  Future<void> uploadAvatar() async {
    if (_image == null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      final url = Uri.parse('${Constants.baseUrl}/rest/user/$id/avatar');
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = '$token'
        ..files.add(await http.MultipartFile.fromPath('file', _image!.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        print('Avatar uploaded successfully');
        fetchAvatar(id);
      } else {
        print('Failed to upload avatar: ${response.statusCode}');
      }
    }
  }

 Future<void> getImageFromGallery() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    setState(() {
      _image = File(pickedFile.path);
    });
    await uploadAvatar(); // Добавлен вызов uploadAvatar()
  }
}

Future<void> takePhoto() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.camera);

  if (pickedFile != null) {
    setState(() {
      _image = File(pickedFile.path);
    });
    await uploadAvatar(); // Добавлен вызов uploadAvatar()
  }
}


  Future<void> updateAvatar() async {
    if (_image == null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      final url = Uri.parse('${Constants.baseUrl}/rest/user/$id/avatar');
      final request = http.MultipartRequest('PUT', url)
        ..headers['Authorization'] = '$token'
        ..files.add(await http.MultipartFile.fromPath('file', _image!.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        print('Avatar updated successfully');
      } else {
        print('Failed to update avatar: ${response.statusCode}');
      }
    }
  }

  Future<void> deleteAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      final url = Uri.parse('${Constants.baseUrl}/rest/user/$id/avatar');
      final response = await http.delete(
        url,
        headers: <String, String>{'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('Avatar deleted successfully');
      } else {
        print('Failed to delete avatar: ${response.statusCode}');
      }
    }
  }

  void showFullScreenImage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.memory(
                _avatarImageBytes!,
                fit: BoxFit.cover,
              ),
              ButtonBar(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      deleteAvatar();
                      Navigator.pop(context);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      updateAvatar();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('my_details'.tr()),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = true;
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
Center(
  child: GestureDetector(
    onTap: () {
      if (_avatarImageBytes != null) {
        showFullScreenImage();
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Фото профиля'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: Text('Загрузить из галереи'),
                    onTap: () {
                      Navigator.pop(context);
                      getImageFromGallery();
                    },
                  ),
                  ListTile(
                    title: Text('Сделать фото'),
                    onTap: () {
                      Navigator.pop(context);
                      takePhoto();
                    },
                  ),
                ],
              ),
            );
          },
        );
      }
    },
    child: isAvatarLoading
        ? CircularProgressIndicator()
        : CircleAvatar(
            radius: 80,
            backgroundColor: Colors.grey,
            backgroundImage: _avatarImageBytes != null
                ? MemoryImage(_avatarImageBytes!)
                : null,
          ),
  ),
),

                      SizedBox(height: 8),
                      Text(
                        'Адрес',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      TextFormField(
                        initialValue: '$address',
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Пожалуйста, введите адрес';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'username'.tr(),
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
                      Text(
                        'Логин',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        initialValue: username,
                        readOnly: !isEditing,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Пожалуйста, введите имя пользователя';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'username'.tr(),
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
                      Text(
                        'ИНН',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        initialValue: inn?.toString(),
                        readOnly: !isEditing,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Пожалуйста, введите имя inn';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'inn'.tr(),
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
                      Text(
                        'Номер телефона',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        initialValue: phone?.toString(),
                        readOnly: !isEditing,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Пожалуйста, введите номер телефона';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Телефон',
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
                      Text(
                        'Серия паспорта',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        initialValue: passportSerial,
                        readOnly: !isEditing,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Пожалуйста, введите серию паспорта';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Серия паспорта',
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
                      Text(
                        'Email',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        initialValue: email,
                        readOnly: !isEditing,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Пожалуйста, введите адрес электронной почты';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:jol_tartip_flutter/constants.dart';

class UserDataPage extends StatefulWidget {
  @override
  _UserDataPageState createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  String username = '';
  String passportSerial = '';
  String email = '';
  String role = '';
  String address = '';
  DateTime? signupDate;
  BigInt? phone;
  BigInt? inn;




  bool isLoading = false;
  bool isEditing = false;





   









  final _formKey = GlobalKey<FormState>(); // Ключ формы для валидации и сохранения данных

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
          username = userData['username'] ?? '';
          email = userData['email'] ?? '';
          passportSerial =  userData['passportSerial'] ?? '';
          role =  userData['role'] ?? '';
          address =  userData['address'] ?? '';
signupDate = DateTime.tryParse(userData['signupDate'] ?? '');
        phone = BigInt.tryParse(userData['phone'].toString()) ?? BigInt.zero;
inn = BigInt.tryParse(userData['inn'].toString()) ?? BigInt.zero;

          
          isLoading = false;

        });
      } else {
        throw Exception('Failed to load user data');
      }
    }
  }



void handleSubmit(){
   if (_formKey.currentState!.validate()) {

   }
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


                      SizedBox(height: 8),
    Text(
      'Адрес', // Метка поля
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
      'Логин', // Метка поля
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
      'ИНН', // Метка поля
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
      'phone_number'.tr(), // Метка поля
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
                      return 'Пожалуйста, введите имя phone';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'phone'.tr(),
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
      'passport_serial'.tr(), // Метка поля
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
                      return 'Пожалуйста, введите  passportSerial';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'passport_serial'.tr(),
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
      'Email', // Метка поля
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
                      return 'Пожалуйста, введите имя пользователя';
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


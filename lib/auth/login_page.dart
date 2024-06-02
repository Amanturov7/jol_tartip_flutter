import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jol_tartip_flutter/main.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:jol_tartip_flutter/constants.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final String apiUrl = '${Constants.baseUrl}/rest/auth/authenticate';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'login': _loginController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        String accessToken = responseData['accessToken'];
        String token = responseData['token'];

        await _saveAccessToken(accessToken);
        await _saveToken(token);
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
          (route) => false,
        );
      } else {


     showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(response.statusCode.toString()),
            content: Text(response.body),
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
        print('Failed to login: ${response.statusCode}');

      }
    }
  }

  Future<void> _saveAccessToken(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('sign_in'.tr()),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _loginController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите логин';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'login'.tr(),
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
                controller: _passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите пароль';
                  }
                  return null;
                },
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'password'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                         focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Color(0xFF3BB5E9)), 
                                            borderRadius: BorderRadius.circular(30.0),
                                        ),
                ),
              ),
              SizedBox(height: 20),

             SizedBox(
  height: 70, // Задаем фиксированную высоту для кнопки
  child: ElevatedButton(
    onPressed: _login,
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Text(
        'login_in'.tr(),
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


                  SizedBox(width: 10),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      // Действия при нажатии на кнопку "Забыли пароль?"
                    },
                    child: Text(
                      'forgot_password'.tr(),
                      style: TextStyle(color: Color(0xFF3BB5E9)),
                    ),
                  ),

                  SizedBox(width: 10),

                  TextButton(
                    onPressed: () {
                      // Действия при нажатии на кнопку "Регистрация"
                    },
                    child: Text(
                      'register'.tr(),
                      style: TextStyle(color: Color(0xFF3BB5E9)),
                    ),
                  ),
                ]
            )

            ],
          ),
        ),
      ),
    );
  }
}

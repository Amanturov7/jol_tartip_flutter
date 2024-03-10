import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'terms_page.dart'; // Импортируем файл с страницей условий пользования

import 'package:jol_tartip_flutter/main.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  bool _agreedToTerms = false;

  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _innController = TextEditingController();
  final TextEditingController _passportController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Future<void> _signup() async {
    if (_formKey.currentState!.validate() && _agreedToTerms) {
      // Все поля прошли валидацию, и условия пользования приняты
      // Можно выполнять регистрацию
      final String apiUrl = 'http://localhost:8080/auth/signup';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'login': _loginController.text,
          'password': _passwordController.text,
          'address': _addressController.text,
          'inn': _innController.text,
          'passport': _passportController.text,
          'phone': _phoneController.text,
        }),
      );

      if (response.statusCode == 201) {
        // Регистрация выполнена успешно
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
          (route) => false,
        );
        // Пользователь создан
      } else {
        // Регистрация не выполнена
        // Обрабатываем ошибку
        print('Failed to signup: ${response.statusCode}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Регистрация'),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                    labelText: 'Логин',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Остальные поля с валидацией аналогично
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
                    labelText: 'Пароль',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите адрес';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Адрес',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _innController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите ИНН';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'ИНН',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passportController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите пасспортные данные';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Пасспорт Серия №',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите номер телефона';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Номер телефона',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreedToTerms = value!;
                        });
                      },
                        activeColor: Color(0xFF3BB5E9) , // Здесь указывается цвет чекбокса
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    GestureDetector(
                      onTap: () {
                        // Переход на страницу с текстом об условиях пользования с анимацией
                      
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TermsPage(),
                            settings: RouteSettings(name: 'TermsPage'),
                          ),
                        );
                      },
                      child: Text(
                        'Я согласен с условиями пользования',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _agreedToTerms ? _signup : null,
                  child: Text(
                    'Зарегистрироваться',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _agreedToTerms ? Color(0xFF3BB5E9) : Colors.grey,
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
}

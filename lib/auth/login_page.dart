import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jol_tartip_flutter/main.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final String apiUrl = 'http://localhost:8080/auth/authenticate';
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
                        MaterialPageRoute(builder: (context) => MyApp()), // Замените MyApp на ваш класс главной страницы
                        (route) => false, // Удалить все предыдущие страницы из стека навигации
                      );
    } else {
      // Обрабатываем ошибку
      print('Failed to login: ${response.statusCode}');
    }
  }

  Future<void> _saveAccessToken(String accessToken) async {
    // Используем пакет shared_preferences для сохранения токена
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
  }

  Future<void> _saveToken(String token) async {
    // Используем пакет shared_preferences для сохранения токена
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Вход'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _loginController,
              decoration: InputDecoration(
                labelText: 'Логин',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0), // Закругленные углы
                ),
              ),
            ),

            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0), // Закругленные углы
                ),
              ),
            ),

            SizedBox(height: 20),
        ElevatedButton(
  onPressed: _login,
  child: Container(
    width: double.infinity,
    padding: EdgeInsets.all(16),
    alignment: Alignment.center,
    child: Text(
      'Войти',
      style: TextStyle(fontSize: 20, color: Colors.white),
    ),
  ),
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF3BB5E9),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    minimumSize: Size(double.infinity, 70), // Минимальный размер кнопки
  ),
),

          ],
        ),
      ),
    );
  }
}

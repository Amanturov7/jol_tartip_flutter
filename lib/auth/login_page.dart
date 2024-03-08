import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
    
    await _saveToken(accessToken);

    Navigator.pushReplacementNamed(context, '/home');
  } else {
    print('Failed to login: ${response.statusCode}');
  }
}


Future<void> _saveToken(String token) async {
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
              decoration: InputDecoration(labelText: 'Логин'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Пароль'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Войти'),
            ),
          ],
        ),
      ),
    );
  }
}

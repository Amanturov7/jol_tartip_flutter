import 'package:flutter/material.dart';
import '../auth/login_page.dart';
import '../user_data_page.dart'; // Импортируем файл с пользовательскими данными
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/signup_page.dart'; // Импортируем файл с регистрацией
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isAuthenticated(), // Проверяем статус аутентификации
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Профиль'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (snapshot.data!) // Если пользователь авторизован
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final prefs = await SharedPreferences.getInstance();
                          final token = prefs.getString('token');
                          if (token != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserDataPage(), // Переходим на страницу с данными пользователя
                              ),
                            );
                          }
                        } catch (e) {
                          print('Ошибка при загрузке данных пользователя: $e');
                        }
                      },
                      child: Text('Мои данные'),
                    ),
                    if (!snapshot.data!) // Если пользователь не авторизован
  ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignupPage()), // Переход на страницу регистрации
      );
    },
    child: Text('Зарегистрироваться'),
  ),

                  if (!snapshot.data!) // Если пользователь не авторизован
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text('Войти'),
                    ),
                 if (snapshot.data!) // Если пользователь авторизован
  ElevatedButton(
    onPressed: () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token'); // Удаляем токен
      // Дополнительные действия при выходе
    },
    child: Text('Выйти'),
  ),

                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Ошибка: ${snapshot.error}');
        } else {
          return CircularProgressIndicator(); // Отображаем индикатор загрузки, пока выполняется проверка
        }
      },
    );
  }

  Future<bool> isAuthenticated() async {
    // Проверяем, есть ли токен доступа в shared_preferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null; // Если токен доступа существует, значит пользователь авторизован
  }
}

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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3BB5E9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: Size(double.infinity, 70),
                      ),
                    ),
                  if (!snapshot.data!) // Если пользователь не авторизован
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignupPage()), // Переход на страницу регистрации
                        );
                      },
                      child: Text('Зарегистрироваться', style: TextStyle(fontSize: 20, color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3BB5E9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: Size(double.infinity, 70),
                      ),
                    ),
                  if (!snapshot.data!) 
                    SizedBox(height: 20),
                  // Если пользователь не авторизован
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text('Войти', style: TextStyle(fontSize: 20, color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3BB5E9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: Size(double.infinity, 70),
                    ),
                  ),
                  if (snapshot.data!) // Если пользователь авторизован
                    ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('token'); // Удаляем токен
                        Navigator.pushReplacement( // Перезагружаем страницу
                          context,
                          MaterialPageRoute(builder: (context) => ProfilePage()),
                        );
                        // Дополнительные действия при выходе
                      },
                      child: Text('Выйти'),
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

import 'package:flutter/material.dart';
import 'package:jol_tartip_flutter/main.dart';
import 'package:jol_tartip_flutter/screen/home_page.dart';
import '../auth/login_page.dart';
import '../user_data_page.dart'; // Импортируем файл с пользовательскими данными
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/signup_page.dart'; // Импортируем файл с регистрацией

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isAuthenticated(),
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserDataPage(),
        ),
      );
    },
    child: Text('Мои данные', style: TextStyle(fontSize: 20, color: Colors.white)),
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
                          MaterialPageRoute(builder: (context) => SignupPage()),
                        );
                      },
                      child: Text('Зарегистрироваться', style: TextStyle(fontSize: 20, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3BB5E9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: Size(double.infinity, 70),
                      ),
                    ),
                  if (!snapshot.hasData || !snapshot.data!) // Если пользователь не авторизован
                    SizedBox(height: 20),
                  if (!snapshot.hasData || !snapshot.data!) // Если пользователь не авторизован
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text('Войти', style: TextStyle(fontSize: 20, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3BB5E9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: Size(double.infinity, 70),
                      ),
                    ),

                  SizedBox(height: 20),
                  if (snapshot.data!)
                    ElevatedButton(
                      
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('token');
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => MyApp()),
                          (route) => false,
                        );
                      },
                      child: Text('Выйти', style: TextStyle(fontSize: 20, color: Colors.white)),
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
          return CircularProgressIndicator();
        }
      },
    );
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null;
  }
}

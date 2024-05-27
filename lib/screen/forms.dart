import 'package:flutter/material.dart';
import 'package:jol_tartip_flutter/forms/event_form.dart';
import 'package:jol_tartip_flutter/forms/review_form.dart';
import 'package:jol_tartip_flutter/sos/sos_form.dart';
import '../forms/application_form.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jol_tartip_flutter/screen/profile_page.dart'; // Импортируем страницу профиля

class FormsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isAuthenticated(), // Проверяем статус авторизации
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Показываем индикатор загрузки, пока проверяем статус авторизации
        } else {
          if (snapshot.data == true) {
            // Если пользователь авторизован, показываем все кнопки
            return _buildButtons(context);
          } else {
            // Если пользователь не авторизован, перенаправляем на страницу профиля
            return ProfilePage();
          }
        }
      },
    );
  }

  // Функция для построения кнопок форм
  Widget _buildButtons(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16),
          height: 70,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViolationFormPage()),
              );
            },
            child: Text(
              'violation'.tr(),
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3BB5E9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16),
          height: 70,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReviewForm()),
              );
            },
            child: Text('review'.tr(), style: TextStyle(fontSize: 20, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3BB5E9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16),
          height: 70,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EventFormPage()),
              );
            },
            child: Text('event'.tr(), style: TextStyle(fontSize: 20, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3BB5E9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16),
          height: 70,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateSosForm()),
              );
            },
            child: Text('SOS', style: TextStyle(fontSize: 20, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Функция для проверки статуса авторизации
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null;
  }
}

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'map_marker.dart'; // Импортируем страницу с картой

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Locale? _selectedLocale;

  @override
  Widget build(BuildContext context) {
    _selectedLocale ??= context.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr()),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'select_language'.tr(),
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<Locale>(
                value: _selectedLocale,
                onChanged: (Locale? newValue) {
                  setState(() {
                    _selectedLocale = newValue;
                    EasyLocalization.of(context)?.setLocale(newValue!);
                  });
                },
                items: <Locale>[
                  Locale('en', 'US'),
                  Locale('ky', 'KG'),
                  Locale('ru', 'RU'),
                ].map<DropdownMenuItem<Locale>>((Locale value) {
                  return DropdownMenuItem<Locale>(
                    value: value,
                    child: Text(
                      _getLanguageName(value.languageCode),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  hintText: 'select_language'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
              // SizedBox(height: 20), // Добавляем отступ перед кнопкой
              // ElevatedButton( // Создаем кнопку
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => MapMarkerPage()), // Переходим на страницу с картой
              //     );
              //   },
              //   child: Text('Open Map'), // Задаем текст кнопки
              // ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ky':
        return 'Кыргызча';
      case 'ru':
        return 'Русский';
      default:
        return 'Unknown';
    }
  }
}

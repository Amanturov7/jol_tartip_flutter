
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Locale? _selectedLocale;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
  'select_language'.tr(),
  style: TextStyle(fontSize: 18),
),
            SizedBox(height: 10),
            DropdownButton<Locale>(
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
                  child: Text(value.toString()),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

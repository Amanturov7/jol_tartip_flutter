import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jol_tartip_flutter/constants.dart';

class DetailedViewSOSPage extends StatelessWidget {
  final Map<String, dynamic> sos;
  final Function? sosList; // Функция обновления списка SOS

  const DetailedViewSOSPage({required this.sos, required this.sosList});

  Future<void> _deleteSOS(BuildContext context) async {
    try {
      final response = await http.delete(Uri.parse('${Constants.baseUrl}/rest/sos/delete/${sos['id']}'));
      if (response.statusCode == 204) {
        Navigator.pop(context);
        // Обновить список SOS на предыдущей странице
        if (sosList != null) {
          sosList!();
        }
      } else {
        throw Exception('Failed to delete SOS');
      }
    } catch (error) {
      print('Error deleting SOS: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Неудача'),
            content: Text('Ошибка удаления повторите еще раз'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Сигнал SOS'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showConfirmationDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: sos['title'],
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'title'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
                        SizedBox(height: 10),
                TextFormField(
              initialValue: sos['address'],
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'address'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: sos['description'],
              readOnly: true,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'description'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: sos['created'],
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'created'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Удалить'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Вы хотите удалить сигнал SOS?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Нет'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Да'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteSOS(context);
              },
            ),
          ],
        );
      },
    );
  }
}

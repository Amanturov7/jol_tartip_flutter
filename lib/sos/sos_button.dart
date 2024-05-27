import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:jol_tartip_flutter/constants.dart';
class SOSButton extends StatefulWidget {
  final void Function(bool hasNewSOS) onNewSOS;

  SOSButton({required this.onNewSOS});

  @override
  _SOSButtonState createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton> {
  bool hasNewSOS = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Запускаем таймер для мигания кнопки каждые 3 секунды
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      // Обновляем состояние кнопки
      setState(() {
        // Здесь проверяем, есть ли новые записи SOS
        // В данном примере просто генерируем случайное значение для демонстрации
        hasNewSOS = DateTime.now().second % 2 == 0; // Проверяем, является ли секунда четной
        // Вызываем функцию обратного вызова, передавая информацию о новых записях SOS
        widget.onNewSOS(hasNewSOS);
      });
    });
  }

  @override
  void dispose() {
    // Отменяем таймер при уничтожении виджета
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.warning),
      onPressed: () {
        Navigator.pushNamed(context, '/sos');
      },
      // Устанавливаем цвет иконки в красный, если есть новые записи SOS
      color: hasNewSOS ? Colors.red : null,
    );
  }
}
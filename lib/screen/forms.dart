import 'package:flutter/material.dart';
import '../forms/application_form.dart';

class FormsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViolationFormPage()),
    );
  },
  child: Text('Нарушения'),
),

        ElevatedButton(
          onPressed: () {
            // Действия при нажатии на кнопку "Отзывы"
          },
          child: Text('Отзывы'),
        ),
        ElevatedButton(
          onPressed: () {
            // Действия при нажатии на кнопку "События"
          },
          child: Text('События'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Главная'),
      ),
      body: Center(
        child: GridView.count(
          crossAxisCount: 3, // Три столбца
          childAspectRatio: 2 / 1, // Соотношение сторон 2:1 (ширина:высота)
          children: <Widget>[
            _buildTile(context, 'Нарушения'),
            _buildTile(context, 'Отзывы'),
            _buildTile(context, 'События'),
            _buildTile(context, 'Штрафы'),
            _buildTile(context, 'Тесты ПДД'),
            _buildTile(context, 'Новости'),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, String title) {
    return InkWell(
      onTap: () {
        // Здесь можно добавить обработчик для каждой кнопки-плитки
        // Например, Navigator.push для перехода на другой экран
      },
      child: Card(
        elevation: 5,
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../applications//applications_list.dart'; // Импортируем компонент ComplaintsList
import '../reviews/reviews_list.dart'; // Импортируем компонент ReviewsList
import '../events/event_list.dart'; // Импортируем компонент ReviewsList

//import 'events_list.dart'; // Импортируем компонент EventsList

class ComplaintsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Обращения'),
      ),
      body: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: TabBar(
            tabs: [
              Tab(text: 'Нарушения'),
              Tab(text: 'Отзывы'),
              Tab(text: 'События'),
            ],
 labelColor: Color(0xFF3BB5E9), // Цвет активного таба
            indicator: UnderlineTabIndicator( // Закрашиваем нижнюю границу
              borderSide: BorderSide( color: Color(0xFF3BB5E9)), // Устанавливаем цвет и ширину границы
            ),          ),
          body: TabBarView(
            children: [
              ApplicationsList(),
              ReviewsList(), // Вставляем ReviewsList в разделе отзывов
              ApplicationsList(),
            ],
          ),
        ),
      ),
    );
  }
}

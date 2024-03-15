import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Количество табов
      child: Scaffold(
        appBar: AppBar(
          title: Text('Уведомления'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Напоминание'),
              Tab(text: 'Рекомендация'),
              Tab(text: 'Информирование'),
              
            ],
             labelColor: Color(0xFF3BB5E9), // Цвет активного таба
            indicator: UnderlineTabIndicator( // Закрашиваем нижнюю границу
              borderSide: BorderSide( color: Color(0xFF3BB5E9)), // Устанавливаем цвет и ширину границы
            ),  
          ),
        ),
        body: TabBarView(
          children: [
            NotificationList(status: 'Напоминание'),
            NotificationList(status: 'Рекомендация'),
            NotificationList(status: 'Информирование'),
            
          ],
        ),
      ),
    );
  }
}

class NotificationList extends StatelessWidget {
  final String status;

  NotificationList({required this.status});

  @override
  Widget build(BuildContext context) {
    // Предположим, что у нас есть список уведомлений для каждого статуса
    // Вместо этого вы можете использовать свой собственный список уведомлений
    List<String> notifications = [
      'Уведомление 1',
      'Уведомление 2',
      'Уведомление 3',
    ];

    // Фильтруем уведомления по статусу
    List<String> filteredNotifications =
        notifications.where((notification) => notification.contains(status)).toList();

    return ListView.builder(
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(filteredNotifications[index]),
        );
      },
    );
  }
}

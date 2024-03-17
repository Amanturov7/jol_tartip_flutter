import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('notifications'.tr()),
          bottom: TabBar(
            tabs: [
              Tab(text: 'info'.tr()),
              Tab(text: 'reminder'.tr()),
              Tab(text: 'recommendation'.tr()),
              
            ],
             labelColor: Color(0xFF3BB5E9),
                             labelStyle:  TextStyle(fontSize: 13.0),
            indicator: UnderlineTabIndicator( 
              borderSide: BorderSide( color: Color(0xFF3BB5E9)), 
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

    List<String> notifications = [
      'Уведомление 1',
      'Уведомление 2',
      'Уведомление 3',
    ];

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

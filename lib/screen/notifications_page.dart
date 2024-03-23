import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:jol_tartip_flutter/constants.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> _notificationsData = [];
  List<Map<String, dynamic>> _statuses = [];

  @override
  void initState() {
    super.initState();
    _fetchNotificationStatuses().then((statuses) {
      setState(() {
        _statuses = statuses;
      });
      _fetchNotifications();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchNotificationStatuses() async {
    final url = Uri.parse('${Constants.baseUrl}/rest/common-reference/by-type/008');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      // Возвращаем список объектов статусов в формате {id, title}
      return data.map((status) => {'id': status['id'], 'title': status['title']}).toList();
    } else {
      throw Exception('Failed to load notification statuses');
    }
  }

  Future<void> _fetchNotifications() async {
    final url = Uri.parse('${Constants.baseUrl}/rest/notifications/all');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      final List<Map<String, dynamic>> notifications = List<Map<String, dynamic>>.from(data);
      setState(() {
        _notificationsData = notifications;
      });
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  List<Map<String, dynamic>> _filterNotificationsByStatus(int statusId) {
    return _notificationsData.where((notification) => notification['notificationTypeId'] == statusId).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _statuses.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('notifications'.tr()),
          bottom: TabBar(
            tabs: _statuses.map((status) => Tab(text: status['title'])).toList(),
            labelColor: Color(0xFF3BB5E9),
            labelStyle: TextStyle(fontSize: 13.0),
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: Color(0xFF3BB5E9)),
            ),
          ),
        ),
        body: TabBarView(
          children: _statuses.map((status) {
            final List<Map<String, dynamic>> filteredNotifications = _filterNotificationsByStatus(status['id']);
            return RefreshIndicator(
              onRefresh: _fetchNotifications, // Обновление страницы
              child: NotificationList(notifications: filteredNotifications),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class NotificationList extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;

  NotificationList({required this.notifications});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero, // Установка внешних отступов списка на ноль
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final createdDate = DateTime.parse(notification['createdDate']);
        final formattedDate = '${createdDate.year}-${createdDate.month}-${createdDate.day}';

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Установка внешних отступов блока
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              title: Text(
                '${notification['title']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${notification['description']}'),
                  SizedBox(height: 4),
                  Text('$formattedDate'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

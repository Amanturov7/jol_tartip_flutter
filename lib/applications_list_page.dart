import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jol_tartip_flutter/constants.dart';

class ApplicationsListPage extends StatefulWidget {
  final bool isArchived;

  ApplicationsListPage({required this.isArchived});

  @override
  _ApplicationsListPageState createState() => _ApplicationsListPageState();
}

class _ApplicationsListPageState extends State<ApplicationsListPage> {
  late int userId;

  @override
  void initState() {
    super.initState();
    fetchUserId();
  }

  Future<void> fetchUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/rest/user/user?token=$token'),
        headers: <String, String>{
          'token': token,
        },
      );
      if (response.statusCode == 200) {
        final userData = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          userId = userData['id'];
        });
      } else {
        throw Exception('Failed to load user data');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Скрываем кнопку "назад"
      ),
      body: FutureBuilder<List<ApplicationsDto>>(
        future: fetchApplications(widget.isArchived),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].title),
                  subtitle: Text(snapshot.data![index].description),
                  // Дополнительные поля заявки, если они есть
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Ошибка: ${snapshot.error}');
          }
          return Container();
        },
      ),
    );
  }

  Future<List<ApplicationsDto>> fetchApplications(bool isArchived) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/rest/applications/all/isarchived?isArchived=$isArchived&userId=$userId'),
      headers: <String, String>{
        'token': token!,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((application) => ApplicationsDto.fromJson(application)).toList();
    } else {
      throw Exception('Ошибка при загрузке заявок');
    }
  }
}

class ApplicationsDto {
  final String title;
  final String description;
  // Дополнительные поля заявки

  ApplicationsDto({required this.title, required this.description});

  factory ApplicationsDto.fromJson(Map<String, dynamic> json) {
    return ApplicationsDto(
      title: json['title'],
      description: json['description'],
      // Инициализируйте дополнительные поля заявки
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jol_tartip_flutter/constants.dart';

class ReviewsListPage extends StatefulWidget {
  final bool isArchived;

  ReviewsListPage({required this.isArchived});

  @override
  _ReviewsListPageState createState() => _ReviewsListPageState();
}

class _ReviewsListPageState extends State<ReviewsListPage> {
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
        automaticallyImplyLeading: false, // убираем кнопку "назад"
      ),
      body: FutureBuilder<List<ReviewDto>>(
        future: fetchReviews(widget.isArchived),
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
                  // Дополнительные поля отзыва, если они есть
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

  Future<List<ReviewDto>> fetchReviews(bool isArchived) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/rest/reviews/all/isarchived?isArchived=$isArchived&userId=$userId'),
      headers: <String, String>{
        'token': token!,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((review) => ReviewDto.fromJson(review)).toList();
    } else {
      throw Exception('Ошибка при загрузке отзывов');
    }
  }
}

class ReviewDto {
  final String title;
  final String description;

  ReviewDto({required this.title, required this.description});

  factory ReviewDto.fromJson(Map<String, dynamic> json) {
    return ReviewDto(
      title: json['title'],
      description: json['description'],
      // Инициализируйте дополнительные поля отзыва
    );
  }
}

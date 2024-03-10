import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> recentApplications = [];
  List<Map<String, dynamic>> recentReviews = [];

  @override
  void initState() {
    super.initState();
    fetchRecentApplications();
    fetchRecentReviews();
  }

  Future<void> fetchRecentApplications() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/rest/applications/latest'));
      final data = jsonDecode(response.body);
      if (data is List) {
        setState(() {
          recentApplications = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (error) {
      print('Error fetching recent applications: $error');
    }
  }

  Future<void> fetchRecentReviews() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/rest/reviews/latest'));
      final data = jsonDecode(response.body);
      if (data is List) {
        setState(() {
          recentReviews = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (error) {
      print('Error fetching recent reviews: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Главная'),
            Spacer(),
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView( // Обернуть в SingleChildScrollView
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Недавние нарушения',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: recentApplications.map((application) {
                return Container(
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            'http://localhost:8080/rest/attachments/download/applications/${application['id']}',
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Нарушение № ${application['id']}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Недавние отзывы',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: recentReviews.map((review) {
                return Container(
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            'http://localhost:8080/rest/attachments/download/reviews/${review['id']}',
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Отзыв № ${review['id']}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}

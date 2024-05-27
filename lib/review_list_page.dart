import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jol_tartip_flutter/reviews/detailed_vew_review.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jol_tartip_flutter/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:jol_tartip_flutter/applications/detailed_view_application.dart';

class ReviewsListPage extends StatefulWidget {
  final bool isArchived;

  ReviewsListPage({required this.isArchived});

  @override
  _ReviewsListPageState createState() => _ReviewsListPageState();
}

class _ReviewsListPageState extends State<ReviewsListPage> {
  late int userId;
  bool isLoading = false;
  List<dynamic> reviews = [];

  @override
  void initState() {
    super.initState();
    fetchUserId().then((_) {
      fetchReviews(widget.isArchived);
    });
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

  Future<void> fetchReviews(bool isArchived) async {
    setState(() {
      isLoading = true;
    });

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
      setState(() {
        reviews = data;
      });
    } else {
      throw Exception('Ошибка при загрузке отзывов');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3BB5E9)),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => fetchReviews(widget.isArchived),
              color: Color(0xFF3BB5E9),
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 5.0,
                          mainAxisSpacing: 5.0,
                        ),
                        itemCount: reviews.length,
                        itemBuilder: (BuildContext context, int index) {
                          final review = reviews[index];
                          return GestureDetector(
                            onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailedViewReviewPage(
              id: review['id'].toString(),
              fetchData: fetchReviews, // Передача функции fetchRecentReviews
            ),
          ),
        );                            },
                            child: Container(
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        '${Constants.baseUrl}/rest/attachments/download/reviews/${review['id']}',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      'review_number'.tr() + ' ${review['id']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

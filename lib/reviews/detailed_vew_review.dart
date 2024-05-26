import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:jol_tartip_flutter/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailedViewReviewPage extends StatefulWidget {
  final String id;
  final Function? fetchData;

  DetailedViewReviewPage({required this.id, required this.fetchData});

  @override
  _DetailedViewReviewPageState createState() => _DetailedViewReviewPageState();
}

class _DetailedViewReviewPageState extends State<DetailedViewReviewPage> {
  Map<String, dynamic>? reviewData;
  int? userId;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
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

    try {
      final response = await http.get(
          Uri.parse("${Constants.baseUrl}/rest/reviews/${widget.id}"));

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          reviewData = jsonData;
        });
      } else {
        throw Exception('Failed to load review details');
      }
    } catch (error) {
      print('Error fetching review details: $error');
    }
  }

  Future<void> deleteReview() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      try {
        final response = await http.delete(
          Uri.parse('${Constants.baseUrl}/rest/reviews/delete/${widget.id}'),
          headers: <String, String>{
            'token': token,
          },
        );
        if (response.statusCode == 200) {
          Navigator.pop(context);
          if (widget.fetchData != null) {
            widget.fetchData!();
          }
        } else {
          throw Exception('Failed to delete review');
        }
      } catch (error) {
        print('Error deleting review: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'review_number'.tr() + ' ${reviewData?['id'] ?? ''}',
        ),
        actions: [
          if (userId != null && userId == reviewData?['userId'])
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Удалить'),
                      content: Text('Вы хотите удалить отзыв?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Нет'),
                        ),
                        TextButton(
                          onPressed: () {
                            deleteReview();
                            Navigator.of(context).pop();
                          },
                          child: Text('Да'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.delete),
            ),
        ],
      ),
      body: reviewData != null
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Scaffold(
                            appBar: AppBar(),
                            body: Center(
                              child: Hero(
                                tag: 'image${reviewData!['id']}',
                                child: Image.network(
                                  '${Constants.baseUrl}/rest/attachments/download/reviews/${widget.id}',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: 'image${reviewData!['id']}',
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: NetworkImage(
                              '${Constants.baseUrl}/rest/attachments/download/reviews/${widget.id}',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller:
                        TextEditingController(text: reviewData!['title']),
                    decoration: InputDecoration(
                      labelText: 'review_title'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    readOnly: true,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller:
                        TextEditingController(text: reviewData!['description']),
                    decoration: InputDecoration(
                      labelText: 'review_description'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    readOnly: true,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller:
                        TextEditingController(text: reviewData!['locationAddress']),
                    decoration: InputDecoration(
                      labelText: 'review_location_address'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    readOnly: true,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller:
                        TextEditingController(text: reviewData!['createdDate']),
                    decoration: InputDecoration(
                      labelText: 'review_created_date'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    readOnly: true,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller:
                        TextEditingController(text: reviewData!['updatedDate']),
                    decoration: InputDecoration(
                      labelText: 'review_updated_date'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    readOnly: true,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller:
                        TextEditingController(text: reviewData!['statusName']),
                    decoration: InputDecoration(
                      labelText: 'review_status'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    readOnly: true,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller:
                        TextEditingController(text: reviewData!['lightName']),
                    decoration: InputDecoration(
                      labelText: 'review_light'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    readOnly: true,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller:
                        TextEditingController(text: reviewData!['roadSignName']),
                    decoration: InputDecoration(
                      labelText: 'review_road_sign'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    readOnly: true,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller:
                        TextEditingController(text: reviewData!['ecologicFactorsName']),
                    decoration: InputDecoration(
                      labelText: 'review_ecologic_factors'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    readOnly: true,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller:
                        TextEditingController(text: reviewData!['roadName']),
                    decoration: InputDecoration(
                      labelText: 'review_road'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    readOnly: true,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

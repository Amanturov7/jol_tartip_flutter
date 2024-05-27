import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jol_tartip_flutter/constants.dart';
import 'package:jol_tartip_flutter/applications/detailed_view_application.dart';

class ApplicationsListPage extends StatefulWidget {
  final bool isArchived;

  ApplicationsListPage({required this.isArchived});

  @override
  _ApplicationsListPageState createState() => _ApplicationsListPageState();
}

class _ApplicationsListPageState extends State<ApplicationsListPage> {
  late int userId;
  bool isLoading = false;
  List<dynamic> applications = [];

  @override
  void initState() {
    super.initState();
    fetchUserId().then((_) {
      fetchApplications(widget.isArchived);
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

  Future<void> fetchApplications(bool isArchived) async {
    setState(() {
      isLoading = true;
    });

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
      setState(() {
        applications = data;
      });
    } else {
      throw Exception('Ошибка при загрузке заявок');
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
              onRefresh: () => fetchApplications(widget.isArchived),
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
                        itemCount: applications.length,
                        itemBuilder: (BuildContext context, int index) {
                          final application = applications[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailedViewApplicationPage(
                                    id: application['id'].toString(),
                                    fetchData: () => fetchApplications(widget.isArchived),
                                  ),
                                ),
                              );
                            },
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
                                        '${Constants.baseUrl}/rest/attachments/download/applications/${application['id']}',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      'violation_number'.tr() + ' ${application['id']}',
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

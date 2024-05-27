import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jol_tartip_flutter/applications/detailed_view_application.dart';
import 'package:jol_tartip_flutter/reviews/detailed_vew_review.dart';
import 'package:jol_tartip_flutter/sos/sos_button.dart';
import 'dart:convert';
import '../search_results_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:jol_tartip_flutter/constants.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = '';
  bool hasNewSOS = false;

  TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> recentApplications = [];
  List<Map<String, dynamic>> recentReviews = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    searchQuery = '';
 fetchRecentApplications();  
 fetchRecentReviews();
  }


Future<void> fetchRecentReviews() async {
  try {
    final response = await http.get(Uri.parse('${Constants.baseUrl}/rest/reviews/latest'));
    final reviewData = jsonDecode(response.body);
    
    if (reviewData is List) {
      setState(() {
        recentReviews = List<Map<String, dynamic>>.from(reviewData);
        isLoading = false;
      });
    }
  } catch (error) {
    print('Error fetching recent reviews: $error');
    setState(() {
      isLoading = false;
    });
  }
}


 Future<void> fetchRecentApplications() async {
  try {
    final response = await http.get(Uri.parse('${Constants.baseUrl}/rest/applications/latest'));
    final applicationData = jsonDecode(response.body);
    
    if (applicationData is List) {
      setState(() {
        recentApplications = List<Map<String, dynamic>>.from(applicationData);
        isLoading = false;
      });
    }
  } catch (error) {
    print('Error fetching recent applications: $error');
    setState(() {
      isLoading = false;
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
  title: Row(
    children: [
      Text('home'.tr()),
      Spacer(),
      IconButton(
        icon: Icon(Icons.notifications),
        onPressed: () {
          Navigator.pushNamed(context, '/notifications');
        },
      ),
            SOSButton(
              onNewSOS: (bool newSOS) {
                setState(() {
                  hasNewSOS = newSOS;
                });
              },
            ),
    ],
  ),
),

      body: isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3BB5E9)))) // Show loading indicator with specified color
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'check_gos_number'.tr(),
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '01KG777AAA',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        suffixIcon: InkWell(
                          onTap: () {
                            _search();
                          },
                          borderRadius: BorderRadius.circular(30.0),
                          child: Container(
                            padding: const EdgeInsets.all(7.0),
                            margin: const EdgeInsets.all(7.0),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'recent_applications'.tr(),
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 5.0,
    mainAxisSpacing: 5.0,
  ),
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  itemCount: recentApplications.length,
  itemBuilder: (BuildContext context, int index) {
    final application = recentApplications[index];
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailedViewApplicationPage(
              id: application['id'].toString(),
              fetchData: fetchRecentApplications, // Передача функции fetchRecentApplications
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
            SizedBox(height: 8),
            Text(
              'violation_number'.tr() + '${application['id']}',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  },
),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'recent_reviews'.tr(),
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
   GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 5.0,
    mainAxisSpacing: 5.0,
  ),
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  itemCount: recentReviews.length,
  itemBuilder: (BuildContext context, int index) {
    final review = recentReviews[index];
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailedViewReviewPage(
              id: review['id'].toString(),
              fetchData: fetchRecentReviews, // Передача функции fetchRecentReviews
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
            SizedBox(height: 10),
            Text(
              'review_number'.tr() + '${review['id']}',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  },
),

                ],
              ),
            ),
    );
  }

  void _search() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchResultsPage(searchQuery: _searchController.text)),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}

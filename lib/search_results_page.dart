import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchResultsPage extends StatefulWidget {
  final String searchQuery;

  SearchResultsPage({required this.searchQuery});

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late List<Map<String, dynamic>> searchResults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSearchResults();
  }

  Future<void> fetchSearchResults() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/rest/applications/by-gos-number?gosNumber=${widget.searchQuery}'),
        headers: {
          'Accept-Charset': 'utf-8',
        },
      );
      final data = jsonDecode(response.body);
      if (data is List) {
        setState(() {
          searchResults = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching search results: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Результаты поиска'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : searchResults.isNotEmpty
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 5.0,
                          mainAxisSpacing: 5.0,
                        ),
                        itemCount: searchResults.length,
                        itemBuilder: (BuildContext context, int index) {
                          final application = searchResults[index];
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
                        },
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Text('Нарушений нет!', style: TextStyle(color: Colors.green, fontSize: 20),),
                ),
    );
  }
}
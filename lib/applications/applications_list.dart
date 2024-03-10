import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApplicationsList extends StatefulWidget {
  @override
  _ApplicationsListState createState() => _ApplicationsListState();
}

class _ApplicationsListState extends State<ApplicationsList> {
  List<dynamic> applications = [];
  List<dynamic> filterOptions = [];
  int? selectedFilter;
  String title = '';
  int? id;
  String numberAuto = '';
  int pageNumber = 1;

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchFilterOptions();
  }

  Future<void> fetchData() async {
    try {
      String url = 'http://localhost:8080/rest/applications/all';
      url += '?page=$pageNumber';

      if (selectedFilter != null) {
        url += '&typeViolations=$selectedFilter';
      }

      if (title.isNotEmpty) {
        url += '&title=$title';
      }

      if (id != null) {
        url += '&id=$id';
      }

      if (numberAuto.isNotEmpty) {
        url += '&numberAuto=$numberAuto';
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          applications = jsonData['content'];
        });
      } else {
        throw Exception('Failed to load applications');
      }
    } catch (error) {
      print('Error fetching applications: $error');
    }
  }

  Future<void> fetchFilterOptions() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:8080/rest/violations/all'));
      if (response.statusCode == 200) {
        setState(() {
          filterOptions = json.decode(utf8.decode(response.bodyBytes));
        });
      } else {
        throw Exception('Failed to fetch filter options');
      }
    } catch (error) {
      print('Error fetching filter options: $error');
    }
  }

  void handleFilterChange(int? value) {
    setState(() {
      selectedFilter = value;
    });
  }

  void handleTitleChange(String value) {
    setState(() {
      title = value;
    });
  }

  void handleIdChange(String value) {
    setState(() {
      id = int.tryParse(value);
    });
  }

  void handleNumberAutoChange(String value) {
    setState(() {
      numberAuto = value;
    });
  }

  void resetFilters() {
    setState(() {
      selectedFilter = null;
      title = '';
      id = null;
      numberAuto = '';
    });
    fetchData();
  }

  void applyFilters() {
    fetchData();
    Navigator.pop(context); // Close the bottom sheet after applying filters
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Нарушения'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.filter_alt),
                color: selectedFilter != null ||
                        title != '' ||
                        id != null ||
                        numberAuto != ''
                    ? Colors.blue
                    : null,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return SingleChildScrollView(
                            child: Container(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Фильтры'),
                                  SizedBox(height: 16),
                                  // Filter options UI here
                                  Text('Нарушения'),
                                  Column(
                                    children: filterOptions.map((factor) {
                                      return RadioListTile(
                                        title: Text(factor['title']),
                                        value: factor['id'].toInt(),
                                        groupValue: selectedFilter,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedFilter = value as int?;
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                  SizedBox(height: 8),
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: 'ID',
                                    ),
                                    onChanged: handleIdChange,
                                    keyboardType: TextInputType.number,
                                  ),
                                  SizedBox(height: 8),
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Номер авто',
                                    ),
                                    onChanged: handleNumberAutoChange,
                                  ),
                                  SizedBox(height: 8),
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Заголовок',
                                    ),
                                    onChanged: handleTitleChange,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        onPressed: applyFilters,
                                        child: Text('Применить'),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        icon: Icon(Icons.close),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Icon(
                  Icons.circle,
                  size: 12,
                  color: selectedFilter != null ||
                          title != '' ||
                          id != null ||
                          numberAuto != ''
                      ? Colors.blue
                      : Colors.transparent,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.clear),
            tooltip: 'Сбросить фильтры',
            onPressed: resetFilters,
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

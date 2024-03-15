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
      resizeToAvoidBottomInset: false,
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
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return SingleChildScrollView(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: Container(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 16),
                                  DropdownButtonFormField<int?>(
                                    
                                    value: selectedFilter,
                                    
                                    decoration: InputDecoration(
                                      
                                      border: OutlineInputBorder(
                                        
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),

                                    contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),                                
                                    ),
                                    
                                    items: [
                                      DropdownMenuItem<int?>(
                                        value: null,
                                        child: Text('Выберите тип нарушения',         ),
                                      ),
                                      ...filterOptions.map<DropdownMenuItem<int?>>((factor) {
                                        return DropdownMenuItem<int?>(
                                          value: factor['id'].toInt(),
                                          child: Text(factor['title'],),
                                        );
                                      }).toList(),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedFilter = value;
                                      });
                                    },
                                  ),
                                  SizedBox(height: 8),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      hintText: '№ нарушения',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Color(0xFF3BB5E9)), // Установите желаемый цвет для границы при активном состоянии
                                          borderRadius: BorderRadius.circular(30.0),
                                        ),
                                    ),
                                    onChanged: handleIdChange,
                                    keyboardType: TextInputType.number,
                                  ),
                                  SizedBox(height: 8),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Color(0xFF3BB5E9)), 
                                            borderRadius: BorderRadius.circular(30.0),
                                        ),
                                      hintText: 'Гос номер',
                                    ),
                                    onChanged: handleNumberAutoChange,
                                  ),
                                  SizedBox(height: 8),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      hintText: 'Описание',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                             focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Color(0xFF3BB5E9)), 
                                            borderRadius: BorderRadius.circular(30.0),
                                        ),
                                    ),
                                    onChanged: handleTitleChange,
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        onPressed: applyFilters,
                                        child: Container(
                                          padding: EdgeInsets.all(16),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Применить',
                                            style: TextStyle(fontSize: 20, color: Colors.white),
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF3BB5E9),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
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

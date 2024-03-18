import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:jol_tartip_flutter/constants.dart';

class DetailedViewApplicationPage extends StatefulWidget {
  final String id;

  DetailedViewApplicationPage({required this.id});

  @override
  _DetailedViewApplicationPageState createState() => _DetailedViewApplicationPageState();
}

class _DetailedViewApplicationPageState extends State<DetailedViewApplicationPage> {
  late TextEditingController titleController;
  late TextEditingController dateController;
  late TextEditingController numberAutoController;
  late TextEditingController descriptionController;

  List<dynamic> violationsList = [];
  Map<String, dynamic>? applicationData;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchViolations();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse("${Constants.baseUrl}/rest/applications/${widget.id}"));

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          applicationData = jsonData;
          titleController = TextEditingController(text: applicationData!['title']);
          dateController = TextEditingController(text: applicationData!['dateOfViolation']);
          numberAutoController = TextEditingController(text: applicationData!['numberAuto']);
          descriptionController = TextEditingController(text: applicationData!['description']);
        });
      } else {
        throw Exception('Failed to load application details');
      }
    } catch (error) {
      print('Error fetching application details: $error');
    }
  }

  Future<void> fetchViolations() async {
    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}:8080/rest/violations/all'));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        setState(() {
          violationsList = data;
        });
      }
    } catch (error) {
      print('Error fetching violations: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('violation_number'.tr()  +' ${applicationData!['id']}'),
        actions: [
          isEditing
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      isEditing = false;
                    });
                  },
                  icon: Icon(Icons.close),
                )
              : IconButton(
                  onPressed: () {
                    setState(() {
                      isEditing = true;
                    });
                  },
                  icon: Icon(Icons.edit),
                ),
        ],
      ),
      body: applicationData != null
          ? SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                                tag: 'image${applicationData!['id']}',
                                child: Image.network(
                                  '${Constants.baseUrl}/rest/attachments/download/applications/${widget.id}',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: NetworkImage('${Constants.baseUrl}/rest/attachments/download/applications/${widget.id}'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      TextFormField(
                        controller: TextEditingController(text: applicationData!['title']),
                        decoration: InputDecoration(
                          labelText: 'violation_type'.tr(),
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
                      SizedBox(height: 10),
                      TextFormField(
                        controller: dateController,
                        decoration: InputDecoration(
                          labelText: 'Date_time_violation'.tr(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        readOnly: !isEditing,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: numberAutoController,
                        decoration: InputDecoration(
                          labelText: 'gos_nomer'.tr(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        readOnly: !isEditing,
                      ),
                      SizedBox(height: 10),

                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'description'.tr(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        readOnly: !isEditing,
                      ),
                      SizedBox(height: 20),
                      isEditing
                          ?  
                          Container( child: ElevatedButton(
                            
              onPressed: (){},
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                alignment: Alignment.center,
                child: Text(
                  'save'.tr(),
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3BB5E9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: Size(double.infinity, 70),
              ),
            )
                          )
                          : SizedBox.shrink(),
                    ],
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

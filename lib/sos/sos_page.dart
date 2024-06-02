import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jol_tartip_flutter/constants.dart';
import 'package:jol_tartip_flutter/sos/detailed_sos_page.dart'; 

class SOSPage extends StatefulWidget {
  @override
  _SOSPageState createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> {
  List<Map<String, dynamic>> sosList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSOSList();
  }

  Future<void> fetchSOSList() async {
    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/rest/sos/all'));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));      
          setState(() {
          sosList = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load SOS list');
      }
    } catch (error) {
      print('Error fetching SOS list: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Сигналы SOS'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: sosList.length,
              itemBuilder: (BuildContext context, int index) {
                final sos = sosList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailedViewSOSPage(sos: sos,sosList:fetchSOSList), // Передача данных SOS на страницу detailedViewSos
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          '${sos['title']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${sos['description']}'),
                            SizedBox(height: 4),
                            Text('${sos['created']}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
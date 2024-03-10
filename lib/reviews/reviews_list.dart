import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReviewsList extends StatefulWidget {
  @override
  _ReviewsListState createState() => _ReviewsListState();
}

class _ReviewsListState extends State<ReviewsList> {
  List<dynamic> reviews = [];
  List<dynamic> roadSigns = [];
  List<dynamic> lights = [];
  List<dynamic> roads = [];
  List<dynamic> ecologicFactors = [];
  int? selectedRoadSignId;
  int? selectedLightId;
  int? selectedRoadId;
  int? selectedEcologicFactorId;

  @override
  void initState() {
    super.initState();
    fetchFilterOptions();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      String url = 'http://localhost:8080/rest/reviews/all?';

      if (selectedRoadSignId != null) {
        url += '&roadSignId=$selectedRoadSignId';
      }
      if (selectedLightId != null) {
        url += '&lightId=$selectedLightId';
      }
      if (selectedRoadId != null) {
        url += '&roadId=$selectedRoadId';
      }
      if (selectedEcologicFactorId != null) {
        url += '&ecologicFactorId=$selectedEcologicFactorId';
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          reviews = jsonData['content'];
        });
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (error) {
      print('Error fetching reviews: $error');
    }
  }

  Future<void> fetchFilterOptions() async {
    try {
      final ecologicFactorsUrl = Uri.parse(
          'http://localhost:8080/rest/common-reference/by-type/007');
      final roadSignsUrl = Uri.parse(
          'http://localhost:8080/rest/common-reference/by-type/003');
      final lightsUrl = Uri.parse(
          'http://localhost:8080/rest/common-reference/by-type/004');
      final roadsUrl = Uri.parse(
          'http://localhost:8080/rest/common-reference/by-type/005');

      final ecologicFactorsResponse = await http.get(ecologicFactorsUrl);
      final roadSignsResponse = await http.get(roadSignsUrl);
      final lightsResponse = await http.get(lightsUrl);
      final roadsResponse = await http.get(roadsUrl);

      setState(() {
        ecologicFactors =
            json.decode(utf8.decode(ecologicFactorsResponse.bodyBytes));
        roadSigns = json.decode(utf8.decode(roadSignsResponse.bodyBytes));
        lights = json.decode(utf8.decode(lightsResponse.bodyBytes));
        roads = json.decode(utf8.decode(roadsResponse.bodyBytes));
      });
    } catch (error) {
      print('Error fetching filter options: $error');
    }
  }

  void applyFilters() {
    fetchData();
    Navigator.pop(context);
  }

  void resetFilters() {
    setState(() {
      selectedRoadSignId = null;
      selectedLightId = null;
      selectedRoadId = null;
      selectedEcologicFactorId = null;
    });
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Отзывы'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.filter_alt),
                color: selectedRoadSignId != null ||
                        selectedLightId != null ||
                        selectedRoadId != null ||
                        selectedEcologicFactorId != null
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
                                  Text('Дорожные знаки:'),
                                  Column(
                                    children: roadSigns.map((sign) {
                                      return RadioListTile(
                                        title: Text(sign['title']),
                                        value: sign['id'].toInt(),
                                        groupValue: selectedRoadSignId,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedRoadSignId = value as int?;
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                  Text('Освещение:'),
                                  Column(
                                    children: lights.map((light) {
                                      return RadioListTile(
                                        title: Text(light['title']),
                                        value: light['id'].toInt(),
                                        groupValue: selectedLightId,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedLightId = value as int?;
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                  Text('Дороги:'),
                                  Column(
                                    children: roads.map((road) {
                                      return RadioListTile(
                                        title: Text(road['title']),
                                        value: road['id'].toInt(),
                                        groupValue: selectedRoadId,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedRoadId = value as int?;
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                  Text('Экологические факторы:'),
                                  Column(
                                    children: ecologicFactors.map((factor) {
                                      return RadioListTile(
                                        title: Text(factor['title']),
                                        value: factor['id'].toInt(),
                                        groupValue: selectedEcologicFactorId,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedEcologicFactorId =
                                                value as int?;
                                          });
                                        },
                                      );
                                    }).toList(),
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
                  color: selectedRoadSignId != null ||
                          selectedLightId != null ||
                          selectedRoadId != null ||
                          selectedEcologicFactorId != null
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
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
        ),
        itemCount: reviews.length,
        itemBuilder: (BuildContext context, int index) {
          final review = reviews[index];
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
                SizedBox(height: 8),
                Text(
                  'Отзыв № ${review['id']}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

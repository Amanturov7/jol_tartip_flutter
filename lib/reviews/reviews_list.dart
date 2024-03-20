import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:jol_tartip_flutter/constants.dart';

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
      String url = '${Constants.baseUrl}/rest/reviews/all?';

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
          '${Constants.baseUrl}/rest/common-reference/by-type/007');
      final roadSignsUrl = Uri.parse(
          '${Constants.baseUrl}/rest/common-reference/by-type/003');
      final lightsUrl = Uri.parse(
          '${Constants.baseUrl}/rest/common-reference/by-type/004');
      final roadsUrl = Uri.parse(
          '${Constants.baseUrl}/rest/common-reference/by-type/005');

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

  Future<void> onRefresh() async {
    fetchData();
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
        title: Text('reviews'.tr()),
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
                                  SizedBox(height: 8),
                                  DropdownButtonFormField<int?>(
                                    value: selectedRoadSignId,
                                    decoration: InputDecoration(
                                      hintText: 'Дорожные знаки:',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                                    ),
                                    items: [
                                      DropdownMenuItem<int?>(
                                        value: null,
                                        child: Text('Выберите дорожной знак'),
                                      ),
                                      ...roadSigns.map<DropdownMenuItem<int?>>((sign) {
                                        return DropdownMenuItem<int?>(
                                          value: sign['id'].toInt(),
                                          child: Text(sign['title']),
                                        );
                                      }).toList(),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedRoadSignId = value;
                                        selectedLightId = null;
                                        selectedRoadId = null;
                                        selectedEcologicFactorId = null;
                                      });
                                    },
                                  ),
                                  SizedBox(height: 8),
                                  DropdownButtonFormField<int?>(
                                    value: selectedLightId,
                                    decoration: InputDecoration(
                                      hintText: 'Освещение:',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                                    ),
                                    items: [
                                      DropdownMenuItem<int?>(
                                        value: null,
                                        child: Text('Выберите тип освещения'),
                                      ),
                                      ...lights.map<DropdownMenuItem<int?>>((light) {
                                        return DropdownMenuItem<int?>(
                                          value: light['id'].toInt(),
                                          child: Text(light['title']),
                                        );
                                      }).toList(),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedLightId = value;
                                        selectedRoadSignId = null;
                                        selectedRoadId = null;
                                        selectedEcologicFactorId = null;
                                      });
                                    },
                                  ),
                                  SizedBox(height: 8),
                                  DropdownButtonFormField<int?>(
                                    value: selectedRoadId,
                                    decoration: InputDecoration(
                                      hintText: 'Дороги:',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                                    ),
                                    items: [
                                      DropdownMenuItem<int?>(
                                        value: null,
                                        child: Text('Выберите тип дороги'),
                                      ),
                                      ...roads.map<DropdownMenuItem<int?>>((road) {
                                        return DropdownMenuItem<int?>(
                                          value: road['id'].toInt(),
                                          child: Text(road['title']),
                                        );
                                      }).toList(),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedRoadId = value;
                                        selectedRoadSignId = null;
                                        selectedLightId = null;
                                        selectedEcologicFactorId = null;
                                      });
                                    },
                                  ),
                                  SizedBox(height: 8),
                                  DropdownButtonFormField<int?>(
                                    value: selectedEcologicFactorId,
                                    decoration: InputDecoration(
                                      hintText: 'Экологические факторы:',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                                    ),
                                    items: [
                                      DropdownMenuItem<int?>(
                                        value: null,
                                        child: Text('Выберите экологический фактор'),
                                      ),
                                      ...ecologicFactors.map<DropdownMenuItem<int?>>((factor) {
                                        return DropdownMenuItem<int?>(
                                          value: factor['id'].toInt(),
                                          child: Text(factor['title']),
                                        );
                                      }).toList(),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedEcologicFactorId = value;
                                        selectedRoadId = null;
                                        selectedRoadSignId = null;
                                        selectedLightId = null;
                                      });
                                    },
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        onPressed: applyFilters,
                                        child: Container(
                                          padding: EdgeInsets.all(16),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'accept'.tr(),
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
            tooltip: 'reset_filters'.tr(),
            onPressed: resetFilters,
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: GridView.builder(
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
                        '${Constants.baseUrl}/rest/attachments/download/reviews/${review['id']}',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'review_number'.tr() + '${review['id']}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


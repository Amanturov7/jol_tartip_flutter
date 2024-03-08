import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReviewsList extends StatefulWidget {
  @override
  _ReviewsListState createState() => _ReviewsListState();
}

class _ReviewsListState extends State<ReviewsList> {
  List<dynamic> reviews = [];
  List<dynamic> ecologicFactors = [];
  List<dynamic> roadSigns = [];
  List<dynamic> lights = [];
  List<dynamic> roads = [];
  String selectedEcologicFactor = '';
  String selectedRoadSign = '';
  String selectedLight = '';
  String selectedRoad = '';

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchFilterOptions();
  }

  Future<void> fetchData() async {
    try {
      String url = 'http://localhost:8080/rest/reviews/all';

      if (selectedEcologicFactor.isNotEmpty || selectedRoadSign.isNotEmpty || selectedLight.isNotEmpty || selectedRoad.isNotEmpty) {
        url += '?';
        if (selectedEcologicFactor.isNotEmpty) {
          url += 'ecologicFactorId=$selectedEcologicFactor&';
        }
        if (selectedRoadSign.isNotEmpty) {
          url += 'roadSignId=$selectedRoadSign&';
        }
        if (selectedLight.isNotEmpty) {
          url += 'lightId=$selectedLight&';
        }
        if (selectedRoad.isNotEmpty) {
          url += 'roadId=$selectedRoad&';
        }
        url = url.substring(0, url.length - 1); // Remove last '&'
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
      final ecologicFactorsUrl = Uri.parse('http://localhost:8080/rest/common-reference/by-type/007');
      final roadSignsUrl = Uri.parse('http://localhost:8080/rest/common-reference/by-type/003');
      final lightsUrl = Uri.parse('http://localhost:8080/rest/common-reference/by-type/004');
      final roadsUrl = Uri.parse('http://localhost:8080/rest/common-reference/by-type/005');

      final ecologicFactorsResponse = await http.get(ecologicFactorsUrl);
      final roadSignsResponse = await http.get(roadSignsUrl);
      final lightsResponse = await http.get(lightsUrl);
      final roadsResponse = await http.get(roadsUrl);

      setState(() {
        ecologicFactors = json.decode(ecologicFactorsResponse.body)['content'];
        roadSigns = json.decode(roadSignsResponse.body)['content'];
        lights = json.decode(lightsResponse.body)['content'];
        roads = json.decode(roadsResponse.body)['content'];
      });
    } catch (error) {
      print('Error fetching filter options: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Отзывы'),
      ),
      body: Column(
        children: [
          // Filter options
          Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: selectedEcologicFactor,
                  onChanged: (String? value) {
                    setState(() {
                      selectedEcologicFactor = value ?? '';
                      fetchData();
                    });
                  },
                  items: ecologicFactors.map<DropdownMenuItem<String>>((factor) {
                    return DropdownMenuItem<String>(
                      value: factor['id'].toString(),
                      child: Text(factor['ecologicFactorsName']),
                    );
                  }).toList(),
                  hint: Text('Выберите экологический фактор'),
                ),
                DropdownButton<String>(
                  value: selectedRoadSign,
                  onChanged: (String? value) {
                    setState(() {
                      selectedRoadSign = value ?? '';
                      fetchData();
                    });
                  },
                  items: roadSigns.map<DropdownMenuItem<String>>((sign) {
                    return DropdownMenuItem<String>(
                      value: sign['id'].toString(),
                      child: Text(sign['roadSignName']),
                    );
                  }).toList(),
                  hint: Text('Выберите дорожный знак'),
                ),
                DropdownButton<String>(
                  value: selectedLight,
                  onChanged: (String? value) {
                    setState(() {
                      selectedLight = value ?? '';
                      fetchData();
                    });
                  },
                  items: lights.map<DropdownMenuItem<String>>((light) {
                    return DropdownMenuItem<String>(
                      value: light['id'].toString(),
                      child: Text(light['lightName']),
                    );
                  }).toList(),
                  hint: Text('Выберите освещение'),
                ),
                DropdownButton<String>(
                  value: selectedRoad,
                  onChanged: (String? value) {
                    setState(() {
                      selectedRoad = value ?? '';
                      fetchData();
                    });
                  },
                  items: roads.map<DropdownMenuItem<String>>((road) {
                    return DropdownMenuItem<String>(
                      value: road['id'].toString(),
                      child: Text(road['roadName']),
                    );
                  }).toList(),
                  hint: Text('Выберите дорожное условие'),
                ),
              ],
            ),
          ),
          // Reviews list
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Количество колонок
                crossAxisSpacing: 5.0, // Промежуток между колонками
                mainAxisSpacing: 5.0, // Промежуток между строками
              ),
              itemCount: reviews.length,
              itemBuilder: (BuildContext context, int index) {
                final review = reviews[index];
                return Container(
                  margin: EdgeInsets.all(5), // Отступы для блока
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // Закругленные углы
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            'http://localhost:8080/rest/attachments/download/reviews/${review['id']}', // Замените 'URL_ИЗОБРАЖЕНИЯ' на реальный URL изображения
                            fit: BoxFit.cover, // Масштабирование изображения
                            width: double.infinity,
                          ),
                        ),
                      ),
                      SizedBox(height: 8), // Отступ между изображением и текстом
                      Text(
                        'Отзыв № ${review['id']}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

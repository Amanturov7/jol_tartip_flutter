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
  String? selectedFilter = ''; // Обновлено объявление типа
  String title = '';
  String id = '';
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

      if (selectedFilter!.isNotEmpty) { // Обновлено использование selectedFilter
        url += '&typeViolations=$selectedFilter';
      }

      if (title.isNotEmpty) {
        url += '&title=$title';
      }

      if (id.isNotEmpty) {
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
      final response = await http.get(Uri.parse('http://localhost:8080/rest/violations/all'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          filterOptions = jsonData['content'] ?? []; // Используйте пустой список по умолчанию, если данные 'content' отсутствуют или имеют неправильный тип
        });
      } else {
        throw Exception('Failed to fetch filter options');
      }
    } catch (error) {
      print('Error fetching filter options: $error');
    }
  }

  void handlePageChange(int newPageNumber) {
    setState(() {
      pageNumber = newPageNumber;
      fetchData();
    });
  }

  void handleFilterChange(String? value) { // Обновлено объявление типа
    setState(() {
      selectedFilter = value;
      fetchData();
    });
  }

  void handleTitleChange(String value) {
    setState(() {
      title = value;
      fetchData();
    });
  }

  void handleIdChange(String value) {
    setState(() {
      id = value;
      fetchData();
    });
  }

  void handleNumberAutoChange(String value) {
    setState(() {
      numberAuto = value;
      fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Нарушения'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '№',
                      ),
                      onChanged: handleIdChange,
                      controller: TextEditingController(text: id),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Гос номер',
                      ),
                      onChanged: handleNumberAutoChange,
                      controller: TextEditingController(text: numberAuto),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedFilter,
                      onChanged: handleFilterChange as void Function(String?)?, // Преобразование типа
                      items: filterOptions.map<DropdownMenuItem<String>>((option) {
                        return DropdownMenuItem<String>(
                          value: option['id'].toString(),
                          child: Text(option['title']),
                        );
                      }).toList(),
                      hint: Text('Тип нарушения'),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Описание',
                      ),
                      onChanged: handleTitleChange,
                      controller: TextEditingController(text: title),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20), // Добавляем отступ между фильтрами и приложениями
            Container(
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Количество колонок
                  crossAxisSpacing: 5.0, // Промежуток между колонками
                  mainAxisSpacing: 5.0, // Промежуток между строками
                ),
                itemCount: applications.length,
                itemBuilder: (BuildContext context, int index) {
                  final application = applications[index];
                  return Container(
                    margin: EdgeInsets.all(5), // Отступы для блока
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // Закругленные углы
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              'http://localhost:8080/rest/attachments/download/applications/${application['id']}',
                              fit: BoxFit.cover, // Масштабирование изображения
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                        SizedBox(height: 8), // Отступ между изображением и текстом
                        Text(
                          'Нарушение № ${application['id']}',
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jol_tartip_flutter/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:jol_tartip_flutter/map_marker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateSosForm extends StatefulWidget {
  @override
  _CreateSosFormState createState() => _CreateSosFormState();
}

class _CreateSosFormState extends State<CreateSosForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  double _latitude = 0.0; // Initialize latitude
  double _longitude = 0.0; // Initialize longitude
  late TextEditingController _addressController;
  List<Map<String, dynamic>> _sosTypes = [];
  int userId = 0;

  int? _selectedSosType;
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _addressController = TextEditingController();
    fetchSosTypes(); // Call function to load SOS types list
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void fetchSosTypes() async {
    try {
      final response = await http.get(
          Uri.parse('${Constants.baseUrl}/rest/common-reference/by-type/010'));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;

        List<Map<String, dynamic>> sosTypes = [];
        for (var item in data) {
          sosTypes.add({
            'title': item['title'],
            'id': item['id'],
          });
        }

        setState(() {
          _sosTypes = sosTypes;
        });
      } else {
        throw Exception('Failed to load SOS types');
      }
    } catch (error) {
      print('Error fetching SOS types: $error');
    }
  }

Future<void> _submitForm() async {
  if (_formKey.currentState!.validate()) {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        final responseUser = await http.get(
          Uri.parse('${Constants.baseUrl}/rest/user/user?token=$token'),
          headers: <String, String>{
            'token': token,
          },
        );

        if (responseUser.statusCode == 200) {
          final userData = json.decode(utf8.decode(responseUser.bodyBytes));
          setState(() {
            userId = userData['id'] ?? 0;
          });

          final sosData = {
            'title': _titleController.text,
            'description': _descriptionController.text,
            'address': _addressController.text,
            'lat': _latitude, 
            'lon': _longitude,
            'userId': userId, 
            'typeSosId': _selectedSosType,
          };

          final response = await http.post(
            Uri.parse('${Constants.baseUrl}/rest/sos/create'),
            body: json.encode(sosData),
            headers: {
              'Content-Type': 'application/json',
              'token': token, 
            },
          );

if (response.statusCode == 200 || response.statusCode == 201) {

  // Clear form fields
  _titleController.clear();
  _descriptionController.clear();
  _addressController.clear();
  setState(() {
    _latitude = 0.0; 
    _longitude = 0.0;
  });
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('success'.tr()),
        content: Text('event_saved_successfully'.tr()),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); 
              Navigator.of(context).pop(); 
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
} else {
  // Error creating SOS
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Failed to create SOS')),
  );
  print('Error response body: ${response.body}');
}

        } else {
          throw Exception('Failed to load user data');
        }
      } else {
        throw Exception('Token not found');
      }
    } catch (error) {
      // Handle network errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }
}



  void _handleLocationSelection(double latitude, double longitude) {
    setState(() {
      _latitude = latitude;
      _longitude = longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Сигнал SOS'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  value: _selectedSosType,
                  items: _sosTypes.map<DropdownMenuItem<int>>((sosType) {
                    return DropdownMenuItem<int>(
                      value: sosType['id'] as int,
                      child: Text(sosType['title'].toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSosType = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Выберите тип SOS',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF3BB5E9)),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),

                SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                      SizedBox(height: 10),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'address'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapMarkerPage(
                          onSave: _handleLocationSelection,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      'Указать адрес на карте',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 169, 208, 158),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: Size(double.infinity, 70),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: Text(
                      'SOS',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: Size(double.infinity, 70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

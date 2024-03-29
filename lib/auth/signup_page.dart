import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'terms_page.dart'; 
import 'package:easy_localization/easy_localization.dart';
import 'package:jol_tartip_flutter/main.dart';
import 'package:jol_tartip_flutter/constants.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  bool _agreedToTerms = false;

  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _innController = TextEditingController();
  final TextEditingController _passportController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Future<void> _signup() async {
    if (_formKey.currentState!.validate() && _agreedToTerms) {

      final String apiUrl = '${Constants.baseUrl}/auth/signup';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'login': _loginController.text,
          'password': _passwordController.text,
          'address': _addressController.text,
          'inn': _innController.text,
          'passport': _passportController.text,
          'phone': _phoneController.text,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
          (route) => false,
        );
      } else {
        print('Failed to signup: ${response.statusCode}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('register'.tr()),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _loginController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите логин';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'login'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                           focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Color(0xFF3BB5E9)), 
                                            borderRadius: BorderRadius.circular(30.0),
                                        ),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите пароль';
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'password'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                           focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Color(0xFF3BB5E9)), 
                                            borderRadius: BorderRadius.circular(30.0),
                                        ),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите адрес';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'address'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                           focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Color(0xFF3BB5E9)), 
                                            borderRadius: BorderRadius.circular(30.0),
                                        ),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _innController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите ИНН';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'inn'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                           focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Color(0xFF3BB5E9)), 
                                            borderRadius: BorderRadius.circular(30.0),
                                        ),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passportController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите пасспортные данные';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'passport_serial'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                           focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Color(0xFF3BB5E9)), 
                                            borderRadius: BorderRadius.circular(30.0),
                                        ),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите номер телефона';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'phone_number'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                           focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Color(0xFF3BB5E9)), 
                                            borderRadius: BorderRadius.circular(30.0),
                                        ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreedToTerms = value!;
                        });
                      },
                        activeColor: Color(0xFF3BB5E9) , 
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    GestureDetector(
                      onTap: () {
                    
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TermsPage(),
                            settings: RouteSettings(name: 'TermsPage'),
                          ),
                        );
                      },
                      child: Text(
                        'i_agree'.tr(),
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _agreedToTerms ? _signup : null,
                  child: Text(
                    'to_register'.tr(),
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _agreedToTerms ? Color(0xFF3BB5E9) : Colors.grey,
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

import 'package:flutter/material.dart';
import 'package:jol_tartip_flutter/main.dart';
import 'package:jol_tartip_flutter/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_page.dart';
import '../auth/signup_page.dart';
import '../user_data_page.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text('profile'.tr()),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                
                children: [
                  
                  if (snapshot.data!)
                  
                    Container(
                      
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                       height: 70,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserDataPage(),
                            ),
                          );
                        },
                        
                        child: Text(
                          'my_details'.tr(),
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3BB5E9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  if (!snapshot.data!)
                    Container(
                       height: 70,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignupPage()),
                          );
                        },
                        child: Text(
                          'to_register'.tr(),
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3BB5E9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  if (!snapshot.hasData || !snapshot.data!) SizedBox(height: 20),
                  if (!snapshot.hasData || !snapshot.data!)
                    Container(
                       height: 70,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        },
                        child: Text(
                          'sign_in'.tr(),
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3BB5E9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: 20),

                     Container(
                      
                       height: 70,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SettingsPage()),
                          );
                        },
                        child: Text(
                          'settings'.tr(),
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3BB5E9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                
                        SizedBox(height: 20),
                        Container(
                       height: 70,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                        onPressed: () async {
                        },
                        child: Text(
                          'about'.tr(),
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3BB5E9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        
                      ),
                      ),
                          SizedBox(height: 20),
                        Container(
                       height: 70,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                        onPressed: () async {
                        },
                        child: Text(
                          'contact'.tr(),
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3BB5E9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        
                      ),
                      
                    ),
                      SizedBox(height: 20),
                  if (snapshot.data!)
                                                 
                    Container(
                       height: 70,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('token');
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => MyApp()),
                            (route) => false,
                          );
                        },
                        child: Text(
                          'log_out'.tr(),
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        
                      ),

                    ),
                   
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('error'.tr() + '${snapshot.error}');
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null;
  }
}

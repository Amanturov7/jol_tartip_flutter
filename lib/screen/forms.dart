import 'package:flutter/material.dart';
import 'package:jol_tartip_flutter/forms/event_form.dart';
import 'package:jol_tartip_flutter/forms/review_form.dart';
import '../forms/application_form.dart';
import 'package:easy_localization/easy_localization.dart';

class FormsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16),
            height: 70, 

          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViolationFormPage()),
              );
            },
            child: Text(
              'violation'.tr(),
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
      
        SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16),
            height: 70, 

          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReviewForm()),
              );
            },
            child: Text('review'.tr(), style: TextStyle(fontSize: 20, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3BB5E9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16),
            height: 70, 

          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EventFormPage()),
              );
            },
            child: Text('event'.tr(), style: TextStyle(fontSize: 20, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3BB5E9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
       
         SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16),
            height: 70,

          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViolationFormPage()),
              );
            },
            child: Text('SOS', style: TextStyle(fontSize: 20, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

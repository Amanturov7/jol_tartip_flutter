import 'package:flutter/material.dart';
import '../applications//applications_list.dart'; 
import '../reviews/reviews_list.dart';
import '../events/event_list.dart'; 
import 'package:easy_localization/easy_localization.dart';

class ComplaintsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('applications'.tr()),
      ),
      body: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: TabBar(
            tabs: [
              Tab(text: 'violations'.tr()),
              Tab(text: 'reviews'.tr()),
              Tab(text: 'events'.tr()),
            ],
 labelColor: Color(0xFF3BB5E9), 
            indicator: UnderlineTabIndicator( 
              borderSide: BorderSide( color: Color(0xFF3BB5E9)), 
            ),          ),
          body: TabBarView(
            children: [
              ApplicationsList(),
              ReviewsList(),
              EventsList(),
            ],
          ),
        ),
      ),
    );
  }
}

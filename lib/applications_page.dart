import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:jol_tartip_flutter/applications_list_page.dart';

class ApplicationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Нарушения'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Не архивированные'),
                            Tab(text: 'Архивированные'),

            ],
          ),
        ),
        body: TabBarView(
          children: [
            ApplicationsListPage(isArchived: false),
                        ApplicationsListPage(isArchived: true),

          ],
        ),
      ),
    );
  }
}
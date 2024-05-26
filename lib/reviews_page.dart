import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:jol_tartip_flutter/review_list_page.dart';

class ReviewsPage extends StatefulWidget {
  @override
  _ReviewsPageState createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Отзывы'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Не архивированные'),
            Tab(text: 'Архивированные'),
        
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ReviewsListPage(isArchived: false),
          ReviewsListPage(isArchived: true),
        ],
      ),
    );
  }
}

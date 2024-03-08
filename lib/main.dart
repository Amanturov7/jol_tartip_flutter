import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './auth/login_page.dart';
import './auth/signup_page.dart';
import './screen/home_page.dart';
import './screen/maps_page.dart';
import './screen/profile_page.dart';
import './screen/notifications_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JolTartip',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/home': (context) => HomePage(),
        '/maps': (context) => MapsPage(),
        '/profile': (context) => ProfilePage(),
        '/notifications': (context) => NotificationsPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    MapsPage(),
    ProfilePage(),
    NotificationsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('JolTartip'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
     bottomNavigationBar: BottomNavigationBar(
  items: const <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Главная',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.map),
      label: 'Карты',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Профиль',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.notifications),
      label: 'Уведомления',
    ),
  ],
  currentIndex: _selectedIndex,
  selectedItemColor: Colors.blue,
  unselectedItemColor: Colors.black, // Черный цвет для неактивных иконок
   showSelectedLabels: true, // Показывать метки для выбранных пунктов
  showUnselectedLabels: true, // Показывать метки для не выбранных пунктов
  onTap: _onItemTapped,
),

    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

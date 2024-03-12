import 'package:flutter/material.dart';
import './auth/login_page.dart';
import './auth/signup_page.dart';
import './screen/home_page.dart';
import './screen/maps_page.dart';
import './screen/notifications_page.dart';
import './screen/profile_page.dart';
import './screen/complaints_page.dart';
import 'screen/forms.dart'; // Импортируем новый файл с формами

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
        '/signup': (context) => SignupPage(),
        '/home': (context) => HomePage(),
        '/maps': (context) => MapsPage(),
        '/notifications': (context) => NotificationsPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/login') {
          return MaterialPageRoute(builder: (context) => LoginPage());
        }
        return null;
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
    ComplaintsPage(),
    FormsPage(), // Используем новый виджет с формами
    MapsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Обращения',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_add), // Используем новый значок "playlist_add"
            label: 'Создать', // Название новой вкладки
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Карты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        showSelectedLabels: true,
        showUnselectedLabels: true,
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

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:jol_tartip_flutter/sos/sos_page.dart';
import './auth/login_page.dart';
import './auth/signup_page.dart';
import './screen/home_page.dart';
import './screen/maps_page.dart';
import './screen/notifications_page.dart';
import './screen/profile_page.dart';
import './screen/complaints_page.dart';
import './screen/forms.dart';
import './settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();


  runApp(
    EasyLocalization(
      child: MyApp(),
      supportedLocales: [Locale('en', 'US'), Locale('ru', 'RU'), Locale('ky', 'KG')],
      path: 'assets/translations',
      fallbackLocale: Locale('ru', 'RU'),
      startLocale: Locale('ru', 'RU'),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'JolTartip',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Color(0xFF3BB5E9),
          selectionColor: Color(0xFF3BB5E9),
          selectionHandleColor: Color(0xFF3BB5E9),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        '/signup': (context) => SignupPage(),
        '/home': (context) => HomePage(),
        '/maps': (context) => MapsPage(),
        '/notifications': (context) => NotificationsPage(),
        '/settings': (context) => SettingsPage(),
        '/sos': (context) => SOSPage(),
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
    FormsPage(),
    MapsPage(),
    ProfilePage(),
  ];

  final List<String> _labels = [
    'home'.tr(),
    'applications'.tr(),
    'create'.tr(),
    'maps'.tr(),
    'profile'.tr(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: _labels[0],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: _labels[1],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_add),
            label: _labels[2],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: _labels[3],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: _labels[4],
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

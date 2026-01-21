import 'package:flutter/material.dart';
import 'screens/smart_home.dart';
import 'screens/shop_page.dart';
import 'screens/reports_page.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(brightness: Brightness.dark, primaryColor: Colors.amber),
  home: MainNavigation(),
));

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    SmartHomePage(), 
    ReportsPage(), // ربط صفحة طلباتي هنا
    ReportsPage(), // ربط صفحة التقارير هنا
    ShopPage(), 
    Center(child: Text("حسابي")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: "طلباتي"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "التقارير"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "المتجر"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "حسابي"),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/smart_home.dart';
import 'screens/shop_page.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
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
    Center(child: Text("صفحة الطلبات", style: TextStyle(color: Colors.white))),
    Center(child: Text("صفحة التقارير", style: TextStyle(color: Colors.white))),
    ShopPage(), 
    Center(child: Text("حسابي", style: TextStyle(color: Colors.white))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "طلباتي"),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: "التقارير"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "المتجر"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "حسابي"),
        ],
      ),
    );
  }
}

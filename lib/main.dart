import 'package:flutter/material.dart';
import 'screens/shop_page.dart';
import 'screens/reports_page.dart';
import 'screens/smart_home.dart';

void main() => runApp(MaterialApp(debugShowCheckedModeBanner: false, home: Nav()));

class Nav extends StatefulWidget { @override _NavState createState() => _NavState(); }
class _NavState extends State<Nav> {
  int _idx = 0;
  final _p = [SmartHomePage(), ReportsPage(isTracking: true), ReportsPage(isTracking: false), ShopPage(), Center(child: Text("حسابي"))];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _p[_idx],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black, unselectedItemColor: Colors.grey, selectedItemColor: Colors.amber, type: BottomNavigationBarType.fixed,
        currentIndex: _idx, onTap: (i) => setState(() => _idx = i),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: "طلباتي"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "التقارير"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "المتجر"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "حسابي"),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ShopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("SMART SHOP", style: TextStyle(color: Colors.amber)),
      ),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          _buildProductCard("ماكينة سيكور إيطالي", "5,500 ريال", Icons.settings_input_component),
          _buildProductCard("شاشة داخلية للمصعد", "1,200 ريال", Icons.tv),
          _buildProductCard("أزرار استدعاء ذكية", "450 ريال", Icons.touch_app),
        ],
      ),
    );
  }

  Widget _buildProductCard(String title, String price, IconData icon) {
    return Card(
      color: Color(0xFF333333),
      child: ListTile(
        leading: Icon(icon, color: Colors.amber, size: 30),
        title: Text(title, style: TextStyle(color: Colors.white)),
        subtitle: Text(price, style: TextStyle(color: Colors.greenAccent)),
        trailing: Icon(Icons.add_shopping_cart, color: Colors.white),
      ),
    );
  }
}

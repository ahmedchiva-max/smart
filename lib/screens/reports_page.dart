import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(title: Text("التقارير والطلبات"), backgroundColor: Colors.black),
      body: ListView(
        children: [
          _trackCard("ماكينة إيطالية", "في الطريق", "OTP: 4432"),
          _trackCard("لوحة كنترول", "تم الاستلام", "2026/01/21"),
        ],
      ),
    );
  }

  Widget _trackCard(String item, String status, String info) {
    return Card(
      color: Color(0xFF333333),
      margin: EdgeInsets.all(10),
      child: ListTile(
        title: Text(item, style: TextStyle(color: Colors.white)),
        subtitle: Text(status, style: TextStyle(color: Colors.green)),
        trailing: Text(info, style: TextStyle(color: Colors.amber)),
      ),
    );
  }
}

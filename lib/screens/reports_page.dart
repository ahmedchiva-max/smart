import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(title: Text("الملف الرقمي للمصعد"), backgroundColor: Colors.black),
      body: Column(
        children: [
          _infoCard("رقم المصعد", "E-992283", Icons.tag),
          _infoCard("تاريخ التركيب", "2026/01/10", Icons.calendar_today),
          _infoCard("حالة الضمان", "ساري (باقي 350 يوم)", Icons.verified_user),
          Divider(color: Colors.amber),
          Text("تتبع القطع الحالية", style: TextStyle(color: Colors.amber)),
          _trackItem("ماكينة إيطالية", "في الطريق - OTP: 5541"),
        ],
      ),
    );
  }

  Widget _infoCard(String t, String v, IconData i) {
    return ListTile(leading: Icon(i, color: Colors.amber), title: Text(t, style: TextStyle(color: Colors.white70)), trailing: Text(v, style: TextStyle(color: Colors.white)));
  }

  Widget _trackItem(String item, String status) {
    return Card(color: Color(0xFF333333), margin: EdgeInsets.all(10), child: ListTile(title: Text(item, style: TextStyle(color: Colors.white)), subtitle: Text(status, style: TextStyle(color: Colors.green))));
  }
}

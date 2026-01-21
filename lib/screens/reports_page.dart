import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(backgroundColor: Colors.black, title: Text("التتبع والتقارير", style: TextStyle(color: Colors.amber))),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          _buildOrderCard("ماكينة إيطالية 5.5hp", "قيد التوصيل", "OTP: 7742", Colors.blue),
          _buildOrderCard("كنترول سمارت ذكي", "تم الاستلام", "مكتمل", Colors.green),
          _buildOrderCard("أبواب ستانلس ذهبي", "جاري التصنيع", "تحت الإجراء", Colors.orange),
        ],
      ),
    );
  }

  Widget _buildOrderCard(String item, String status, String otp, Color color) {
    return Card(
      color: Color(0xFF2D2D2D),
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.inventory_2, color: color),
        title: Text(item, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text("الحالة: $status", style: TextStyle(color: color)),
        trailing: Text(otp, style: TextStyle(color: Colors.amber, fontSize: 12)),
      ),
    );
  }
}

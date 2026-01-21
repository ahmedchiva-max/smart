import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(backgroundColor: Colors.black, title: Text("التقارير والفواتير")),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          _buildReportItem("فاتورة رقم #9921", "ماكينة سيكور + تركيب", "2026/01/21"),
          _buildReportItem("طلب رقم #9922", "كنترول سمارت 4 أدوار", "2026/01/21"),
        ],
      ),
    );
  }

  Widget _buildReportItem(String id, String item, String date) {
    return Card(
      color: Color(0xFF2D2D2D),
      child: ListTile(
        title: Text(id, style: TextStyle(color: Colors.amber)),
        subtitle: Text("$item\n$date", style: TextStyle(color: Colors.white70)),
        trailing: ElevatedButton.icon(
          onPressed: () { /* كود توليد PDF */ },
          icon: Icon(Icons.picture_as_pdf),
          label: Text("تحميل PDF"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
        ),
      ),
    );
  }
}

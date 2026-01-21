import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(backgroundColor: Colors.black, title: Text("طلباتي والتتبع")),
      body: ListView(padding: EdgeInsets.all(15), children: [
        _buildTrackCard("ماكينة سيكور + تركيب", "قيد التوصيل", "OTP: 7741", Colors.blue, "سيصل في: 06:00 PM"),
        _buildTrackCard("كنترول سمارت 4 أدوار", "جاري التحقق", "OTP: 9902", Colors.orange, "بانتظار مراجعة الإيصال"),
      ]),
    );
  }

  Widget _buildTrackCard(String item, String status, String otp, Color color, String time) {
    return Card(color: Color(0xFF2D2D2D), margin: EdgeInsets.only(bottom: 15), child: Padding(padding: EdgeInsets.all(15), child: Column(children: [
      ListTile(
        leading: Icon(Icons.local_shipping, color: color),
        title: Text(item, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text("الحالة: $status", style: TextStyle(color: color)),
        trailing: Text(otp, style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
      ),
      Divider(color: Colors.grey),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(time, style: TextStyle(color: Colors.grey, fontSize: 11)),
        ElevatedButton.icon(onPressed: () {}, icon: Icon(Icons.picture_as_pdf, size: 16), label: Text("الفاتورة PDF"), style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent)),
      ]),
    ])));
  }
}

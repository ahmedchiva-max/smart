import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(backgroundColor: Colors.black, title: Text("طلباتي وتتبع الشحن")),
      body: ListView(padding: EdgeInsets.all(15), children: [
        _buildTrackCard("ماكينة سيكور + تركيب", "في الطريق", "OTP: 8841", Colors.blue, "سيصل الساعة 8:00 مساءً"),
        _buildTrackCard("كنترول ذكي 4 أدوار", "جاري التجهيز", "OTP: 2210", Colors.orange, "يتم مراجعة الإيصال"),
      ]),
    );
  }

  Widget _buildTrackCard(String item, String status, String otp, Color color, String time) {
    return Card(color: Color(0xFF2D2D2D), margin: EdgeInsets.only(bottom: 15), child: Padding(padding: EdgeInsets.all(15), child: Column(children: [
      ListTile(leading: Icon(Icons.local_shipping, color: color), title: Text(item, style: TextStyle(color: Colors.white)), subtitle: Text("الحالة: $status", style: TextStyle(color: color)), trailing: Text(otp, style: TextStyle(color: Colors.amber))),
      Divider(),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(time, style: TextStyle(color: Colors.grey, fontSize: 10)), ElevatedButton.icon(onPressed: () {}, icon: Icon(Icons.picture_as_pdf, size: 15), label: Text("تحميل الفاتورة PDF"), style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent))])
    ])));
  }
}

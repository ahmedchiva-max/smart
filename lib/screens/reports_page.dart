import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  final bool isTracking; // تفرقة بين صفحة الطلبات والتقارير
  ReportsPage({this.isTracking = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(backgroundColor: Colors.black, title: Text(isTracking ? "طلباتي (تتبع)" : "التقارير المالية")),
      body: ListView(padding: EdgeInsets.all(15), children: [
        _item("فاتورة #8812", "ماكينة سيكور", isTracking ? "قيد التوصيل" : "تم السداد", isTracking ? "OTP: 4421" : "PDF جاهز"),
        _item("فاتورة #8813", "كنترول ذكي", isTracking ? "جاري التجهيز" : "تم السداد", isTracking ? "OTP: 9901" : "PDF جاهز"),
      ]),
    );
  }

  Widget _item(String t, String s, String st, String extra) {
    return Card(color: Color(0xFF1E1E1E), child: ListTile(
      title: Text(t, style: TextStyle(color: Colors.amber)),
      subtitle: Text("$s - $st", style: TextStyle(color: Colors.white70)),
      trailing: ElevatedButton(onPressed: () {}, child: Text(isTracking ? extra : "طباعة PDF", style: TextStyle(fontSize: 10))),
    ));
  }
}

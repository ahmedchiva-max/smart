import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("طلباتي وتتبع الشحنات", style: TextStyle(color: Colors.amber)),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          _buildTrackingCard("ماكينة سيكور إيطالي", "في الطريق", "OTP: 5592", Colors.blue, "سيصل خلال 2 ساعة"),
          _buildTrackingCard("كنترول سمارت 4 أدوار", "جاري التجهيز", "OTP: 1102", Colors.orange, "يتم مراجعة الإيصال"),
          _buildTrackingCard("أزرار ذهبية", "تم الاستلام", "مكتمل", Colors.green, "تم التسليم بنجاح"),
        ],
      ),
    );
  }

  Widget _buildTrackingCard(String item, String status, String otp, Color color, String time) {
    return Card(
      color: Color(0xFF2D2D2D),
      margin: EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: color.withOpacity(0.5))),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.local_shipping, color: color, size: 30),
              title: Text(item, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text("الحالة: $status", style: TextStyle(color: color)),
              trailing: Text(otp, style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            ),
            Divider(color: Colors.grey),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(time, style: TextStyle(color: Colors.grey, fontSize: 12)),
                ElevatedButton(
                  onPressed: () {}, 
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  child: Text("تحميل الفاتورة PDF", style: TextStyle(fontSize: 10)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

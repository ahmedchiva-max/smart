import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("سجل الطلبات والتتبع", style: TextStyle(color: Colors.amber)),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          _buildTrackCard("ماكينة سيكور إيطالي", "قيد التوصيل", "2026/01/21", "OTP: 8842", Colors.blue),
          _buildTrackCard("كنترول ذكي 4 أدوار", "تم التركيب", "2026/01/15", "مكتمل", Colors.green),
          _buildTrackCard("أزرار استدعاء ذهبية", "جاري التجهيز", "2026/01/21", "قيد المعالجة", Colors.orange),
        ],
      ),
    );
  }

  Widget _buildTrackCard(String title, String status, String date, String otp, Color statusColor) {
    return Card(
      color: Color(0xFF2D2D2D),
      margin: EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  child: Text(status, style: TextStyle(color: statusColor, fontSize: 12)),
                ),
              ],
            ),
            Divider(color: Colors.grey[700], height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("تاريخ الطلب: $date", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    SizedBox(height: 5),
                    Text("رقم التحقق: $otp", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                  child: Text("تتبع الشحنة"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

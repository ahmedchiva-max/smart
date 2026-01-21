import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(backgroundColor: Colors.black, title: Text("تتبع طلباتي", style: TextStyle(color: Colors.amber))),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          _buildOrderCard(
            context,
            title: "طلب ماكينة سيكور",
            status: "في الطريق",
            progress: 0.75,
            otp: "5582",
            estimatedTime: "24 دقيقة",
            color: Colors.blue
          ),
          _buildOrderCard(
            context,
            title: "قطع غيار اكسسوارات",
            status: "تم التسليم",
            progress: 1.0,
            otp: "مكتمل",
            estimatedTime: "وصلت في 04:10 PM",
            color: Colors.green
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, {required String title, required String status, required double progress, required String otp, required String estimatedTime, required Color color}) {
    return Card(
      color: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Container(padding: EdgeInsets.all(5), color: color.withOpacity(0.2), child: Text(status, style: TextStyle(color: color, fontSize: 12))),
            ]),
            SizedBox(height: 15),
            LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[800], color: color),
            SizedBox(height: 15),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("الوقت المتوقع", style: TextStyle(color: Colors.grey, fontSize: 11)),
                Text(estimatedTime, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text("رمز الاستلام OTP", style: TextStyle(color: Colors.amber, fontSize: 11)),
                Text(otp, style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18)),
              ]),
            ]),
            Divider(color: Colors.grey[800], height: 30),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _actionBtn(Icons.map, "تتبع المندوب"),
              _actionBtn(Icons.call, "اتصال"),
              _actionBtn(Icons.picture_as_pdf, "الفاتورة"),
            ])
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(IconData i, String l) => Column(children: [Icon(i, color: Colors.grey, size: 20), Text(l, style: TextStyle(color: Colors.grey, fontSize: 10))]);
}

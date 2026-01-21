import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  void _showSignatureDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text("توقيع استلام الشحنة", style: TextStyle(color: Colors.amber, fontFamily: 'Arial')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white10,
                border: Border.all(color: Colors.amber),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text("وقع هنا بالأصبع", style: TextStyle(color: Colors.grey, fontFamily: 'Arial'))),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: TextStyle(color: Colors.red))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showDone();
            },
            child: Text("تأكيد الاستلام"),
          ),
        ],
      ),
    );
  }

  void _showDone() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.check_circle, color: Colors.green, size: 60),
        Text("تم الاستلام بنجاح!", style: TextStyle(fontFamily: 'Arial')),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(backgroundColor: Colors.black, title: Text("تتبع طلباتي", style: TextStyle(color: Colors.amber, fontFamily: 'Arial'))),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          _buildOrderCard(
            title: "طلب ماكينة سيكور",
            status: "في الطريق",
            progress: 0.75,
            otp: "5582",
            time: "24 دقيقة",
            color: Colors.blue,
            id: "ORD-8812"
          ),
          _buildOrderCard(
            title: "كنترول سمارت ذكي",
            status: "وصلت الوجهة",
            progress: 0.95,
            otp: "9901",
            time: "المندوب عند الموقع",
            color: Colors.orange,
            id: "ORD-9901"
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard({required String title, required String status, required double progress, required String otp, required String time, required Color color, required String id}) {
    return Card(
      color: Color(0xFF1E1E1E),
      margin: EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Arial')),
              Text(status, style: TextStyle(color: color, fontSize: 12, fontFamily: 'Arial')),
            ]),
            SizedBox(height: 10),
            LinearProgressIndicator(value: progress, color: color, backgroundColor: Colors.white10),
            SizedBox(height: 15),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("الرمز: $otp", style: TextStyle(color: Colors.amber, fontFamily: 'Arial')),
              Text(time, style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Arial')),
            ]),
            Divider(color: Colors.white10),
            if (progress > 0.9)
              SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => _showSignatureDialog(id), icon: Icon(Icons.edit), label: Text("توقيع واستلام")))
            else
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _actionIcon(Icons.call, "اتصال", () => launchUrl(Uri.parse("tel:966590000000"))),
                _actionIcon(Icons.map, "تتبع المندوب", () {}),
                _actionIcon(Icons.picture_as_pdf, "الفاتورة", () {}),
              ])
          ],
        ),
      ),
    );
  }

  Widget _actionIcon(IconData i, String l, VoidCallback onTap) {
    return InkWell(onTap: onTap, child: Column(children: [Icon(i, color: Colors.grey, size: 20), Text(l, style: TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'Arial'))]));
  }
}

import 'package:flutter/material.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  // دالة إظهار لوحة التوقيع
  void _showSignatureDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text("توقيع استلام الطلب $orderId", style: TextStyle(color: Colors.amber, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("يرجى التوقيع داخل المربع أدناه للاستلام:", style: TextStyle(color: Colors.white70, fontSize: 12)),
            SizedBox(height: 15),
            // محاكاة لوحة التوقيع
            GestureDetector(
              onPanUpdate: (details) {
                // هنا يتم رصد حركة الإصبع للتوقيع
              },
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Icon(Icons.edit, color: Colors.white24, size: 50)),
              ),
            ),
            SizedBox(height: 10),
            Text("بموجب هذا التوقيع، أقر باستلام الشحنة سليمة", style: TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: TextStyle(color: Colors.red))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.pop(ctx);
              _showSuccessPopup();
            },
            child: Text("اعتماد التوقيع والاستلام"),
          ),
        ],
      ),
    );
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            SizedBox(height: 20),
            Text("تم استلام الطلب بنجاح", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text("شكراً لتعاملك مع SMART للمصاعد", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [Center(child: TextButton(onPressed: () => Navigator.pop(ctx), child: Text("تم", style: TextStyle(color: Colors.amber))))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(backgroundColor: Colors.black, title: Text("تتبع طلباتي", style: TextStyle(color: Colors.amber))),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          _buildOrderCard("طلب ماكينة سيكور", "في الطريق", 0.75, "5582", "24 دقيقة", Colors.blue, "ORD-8812"),
          _buildOrderCard("كنترول سمارت ذكي", "وصلت الوجهة", 0.95, "9901", "المندوب عند الموقع", Colors.orange, "ORD-9901"),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context2, {required String title, required String status, required double progress, required String otp, required String estimatedTime, required Color color, required String orderId}) {
    return Card(
      color: Color(0xFF1E1E1E),
      margin: EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(status, style: TextStyle(color: color, fontSize: 12)),
            ]),
            SizedBox(height: 10),
            LinearProgressIndicator(value: progress, color: color, backgroundColor: Colors.white10),
            SizedBox(height: 15),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("الرمز: $otp", style: TextStyle(color: Colors.amber)),
              Text(estimatedTime, style: TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
            Divider(color: Colors.white10),
            if (progress > 0.9) // يظهر الزر فقط عند وصول الشحنة
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showSignatureDialog(orderId),
                  icon: Icon(Icons.draw),
                  label: Text("توقيع واستلام الطلب"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                ),
              )
            else
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _iconBtn(Icons.call, "اتصال"),
                _iconBtn(Icons.map, "تتبع المندوب"),
                _iconBtn(Icons.picture_as_pdf, "الفاتورة"),
              ]),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData i, String l) => Column(children: [Icon(i, color: Colors.grey, size: 20), Text(l, style: TextStyle(color: Colors.grey, fontSize: 10))]);
}

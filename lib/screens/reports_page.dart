import 'package:flutter/material.dart';

class ReportsPage extends StatefulWidget {
  final bool isTracking;
  ReportsPage({this.isTracking = false});
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  // دالة محاكاة تحميل الفاتورة بالتفصيل
  void _downloadPDF(String orderId) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text("الفاتورة الضريبية #$orderId"),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("شركة SMART للمصاعد", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("الرقم الضريبي: 300012345600003"),
            Divider(),
            Text("العميل: أحمد محمد"),
            Text("الجوال: 05XXXXXXXX"),
            Text("الموقع: الرياض - حي النرجس"),
            Divider(),
            _pdfRow("ماكينة سيكور", "4500 ريال"),
            _pdfRow("رسوم التركيب", "500 ريال"),
            Divider(),
            _pdfRow("المجموع الفرعي", "5000 ريال"),
            _pdfRow("القيمة المضافة (15%)", "750 ريال"),
            Text("الإجمالي الشامل: 5750 ريال", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text("تحميل الآن (PDF)"))],
    ));
  }

  Widget _pdfRow(String t, String v) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(t), Text(v)]);

  // بوب أب التوقيع والـ OTP
  void _showSignaturePad() {
    final otpController = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text("تأكيد الاستلام النهائي"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: otpController, decoration: InputDecoration(hintText: "أدخل رمز OTP المستلم")),
        SizedBox(height: 20),
        Container(
          height: 100, width: double.infinity,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text("وقع هنا بالأصبع", style: TextStyle(color: Colors.grey))),
        )
      ]),
      actions: [ElevatedButton(onPressed: () => Navigator.pop(ctx), child: Text("تأكيد وتسليم"))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(backgroundColor: Colors.black, title: Text(widget.isTracking ? "تتبع شحناتي" : "سجل الفواتير")),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          _buildOrderCard("طلب رقم #8812", "ماكينة سيكور 5.5 حصان", 1), // حالة الشحن: في الطريق
          _buildOrderCard("طلب رقم #8815", "كنترول سمارت ذكي", 3), // حالة الشحن: تم الوصول
        ],
      ),
    );
  }

  Widget _buildOrderCard(String id, String item, int stage) {
    return Card(
      color: Color(0xFF1E1E1E),
      margin: EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            ListTile(
              title: Text(id, style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              subtitle: Text(item, style: TextStyle(color: Colors.white)),
              trailing: IconButton(icon: Icon(Icons.picture_as_pdf, color: Colors.red), onPressed: () => _downloadPDF(id)),
            ),
            Divider(color: Colors.grey[800]),
            // نظام التتبع (Stepper)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _step("المخزن", stage >= 0),
                _step("الشحن", stage >= 1),
                _step("الوصول", stage >= 2),
                _step("الاستلام", stage >= 3),
              ],
            ),
            SizedBox(height: 15),
            if (stage == 2) // إذا وصلت الشحنة يظهر زر التوقيع والـ OTP
              ElevatedButton.icon(
                onPressed: _showSignaturePad,
                icon: Icon(Icons.verified_user),
                label: Text("تأكيد الاستلام بالـ OTP والتوقيع"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              )
          ],
        ),
      ),
    );
  }

  Widget _step(String title, bool active) => Column(children: [
    Icon(active ? Icons.check_circle : Icons.radio_button_unchecked, color: active ? Colors.amber : Colors.grey, size: 20),
    Text(title, style: TextStyle(color: active ? Colors.white : Colors.grey, fontSize: 10)),
  ]);
}

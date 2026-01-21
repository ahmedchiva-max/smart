import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(brightness: Brightness.dark, primaryColor: Colors.amber),
  home: MaintenanceSystem(),
));

class MaintenanceSystem extends StatefulWidget { @override _MaintenanceSystemState createState() => _MaintenanceSystemState(); }
class _MaintenanceSystemState extends State<MaintenanceSystem> {
  int _idx = 1; // البدء من صفحة التتبع لتجربة الخريطة مباشرة
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _idx == 1 ? LiveTrackingPage() : Center(child: Text("باقي الصفحات مرفوعة مسبقاً")),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx, onTap: (i) => setState(() => _idx = i),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.build), label: "طلب جديد"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "تتبع الفني"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "التقارير"),
        ],
      ),
    );
  }
}

// --- صفحة التتبع الحي (Live Tracking) ---
class LiveTrackingPage extends StatefulWidget { @override _LiveTrackingPageState createState() => _LiveTrackingPageState(); }
class _LiveTrackingPageState extends State<LiveTrackingPage> {
  double _vehiclePosition = 0.1; // موقع السيارة الافتراضي
  int _eta = 15; // الوقت المتوقع للوصول بالدقائق
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // محاكاة تحرك الفني كل 3 ثواني
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          if (_vehiclePosition < 0.8) {
            _vehiclePosition += 0.05;
            _eta -= 1;
          } else {
            _timer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("تتبع الفني: م. أحمد علي"),
        leading: Icon(Icons.arrow_back),
        actions: [IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: () => Navigator.pop(context))],
      ),
      body: Stack(
        children: [
          // محاكاة الخريطة (شبكة خلفية)
          Container(
            color: Color(0xFF1A1A1A),
            child: CustomPaint(painter: MapGridPainter(), child: Container()),
          ),
          
          // مسار الفني
          Center(
            child: Container(
              height: 400, width: 5,
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
            ),
          ),

          // أيقونة الفني المتحركة
          AnimatedAlign(
            duration: Duration(seconds: 2),
            alignment: Alignment(0, 1 - (_vehiclePosition * 2)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(10)),
                  child: Text("الفني قادم", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
                ),
                Icon(Icons.directions_car, size: 50, color: Colors.amber),
              ],
            ),
          ),

          // موقع العميل (الثابت)
          Align(
            alignment: Alignment(0, -0.9),
            child: Icon(Icons.location_on, size: 60, color: Colors.red),
          ),

          // لوحة معلومات الوصول
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.all(20), padding: EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.amber)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text("الوقت المتوقع:", style: TextStyle(fontSize: 16)),
                    Text("$_eta دقيقة", style: TextStyle(fontSize: 22, color: Colors.amber, fontWeight: FontWeight.bold)),
                  ]),
                  SizedBox(height: 10),
                  Text("سيارة: تويوتا هايلوكس | رقم: أ ب ج 123", style: TextStyle(color: Colors.grey)),
                  Divider(color: Colors.white24),
                  if (_vehiclePosition >= 0.8) 
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: Size(double.infinity, 50)),
                      onPressed: () => _confirmCompletion(context),
                      child: Text("الفني وصل - إنهاء وتوقيع الاستلام", style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  else
                    Text("الفني في الطريق إليك الآن...", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.amber)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _confirmCompletion(BuildContext ctx) {
    showDialog(context: ctx, barrierDismissible: false, builder: (c) => AlertDialog(
      title: Text("إتمام عملية الصيانة"),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("يرجى إدخال الـ OTP المرسل لجوالك:"),
          TextField(keyboardType: TextInputType.number, decoration: InputDecoration(hintText: "****")),
          SizedBox(height: 20),
          Text("توقيع العميل:"),
          Container(
            height: 120, width: double.infinity, 
            decoration: BoxDecoration(color: Colors.white12, border: Border.all(color: Colors.white24)),
            child: Center(child: Text("وقع هنا", style: TextStyle(color: Colors.grey))),
          ),
        ]),
      ),
      actions: [
        ElevatedButton(onPressed: () { Navigator.pop(c); _showSuccess(); }, child: Text("تأكيد وإرسال التقرير"))
      ],
    ));
  }

  void _showSuccess() {
    showDialog(context: context, builder: (c) => AlertDialog(
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.check_circle, size: 80, color: Colors.green),
        Text("\nتم بنجاح!"),
        Text("تم إرسال تقرير الصيانة والفاتورة للواتساب والتقارير."),
      ]),
    ));
  }
}

// رسم شبكة الخريطة البسيطة
class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth = 1.0;
    for (double i = 0; i < size.width; i += 40) { canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint); }
    for (double i = 0; i < size.height; i += 40) { canvas.drawLine(Offset(0, i), Offset(size.width, i), paint); }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

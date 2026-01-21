import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(brightness: Brightness.dark, primaryColor: Colors.amber, fontFamily: 'Arial'),
  home: MaintenanceSystem(),
));

class MaintenanceSystem extends StatefulWidget { @override _MaintenanceSystemState createState() => _MaintenanceSystemState(); }
class _MaintenanceSystemState extends State<MaintenanceSystem> {
  int _idx = 0;
  final _pages = [MaintenanceHome(), LiveTrackingPage(), ReportsPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx, onTap: (i) => setState(() => _idx = i),
        backgroundColor: Colors.black, selectedItemColor: Colors.amber,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.build), label: "طلب خدمة"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "تتبع الفني"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "التقارير"),
        ],
      ),
    );
  }
}

// --- الهيكل الموحد لـ AppBar (الملاحة المطلوبة) ---
PreferredSizeWidget commonAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: Colors.black,
    leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.amber), onPressed: () => Navigator.maybePop(context)),
    title: Text(title, style: TextStyle(fontSize: 16)),
    actions: [
      IconButton(icon: Icon(Icons.home, color: Colors.white), onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (c) => MaintenanceSystem()), (r) => false)),
      IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: () => SystemNavigator.pop()),
    ],
  );
}

// --- صفحة طلب الخدمة ---
class MaintenanceHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar(context, "مركز خدمات SMART"),
      body: Column(
        children: [
          _serviceCard(context, "بلاغ عطل طارئ", Icons.error, Colors.red),
          _serviceCard(context, "طلب صيانة دورية", Icons.moped, Colors.blue),
        ],
      ),
    );
  }

  Widget _serviceCard(BuildContext context, String t, IconData i, Color c) => Expanded(
    child: InkWell(
      onTap: () => _showRequestForm(context, t),
      child: Container(
        margin: EdgeInsets.all(15),
        decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: c)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 70, color: c), Text(t, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
      ),
    ),
  );

  void _showRequestForm(BuildContext context, String type) {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("بيانات طلب $type"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(decoration: InputDecoration(hintText: "الاسم")),
        TextField(decoration: InputDecoration(hintText: "الجوال (05XXXXXXXX)"), keyboardType: TextInputType.phone),
      ]),
      actions: [ElevatedButton(onPressed: () => Navigator.pop(c), child: Text("التالي"))],
    ));
  }
}

// --- صفحة التتبع الحي (Live Tracking) ---
class LiveTrackingPage extends StatefulWidget { @override _LiveTrackingPageState createState() => _LiveTrackingPageState(); }
class _LiveTrackingPageState extends State<LiveTrackingPage> {
  double _pos = 0.0;
  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 2), (t) { if(mounted && _pos < 0.8) setState(() => _pos += 0.05); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar(context, "تتبع الفني مباشر"),
      body: Stack(
        children: [
          Container(color: Colors.white10, child: Center(child: Icon(Icons.map, size: 200, color: Colors.white12))),
          AnimatedAlign(
            duration: Duration(seconds: 1),
            alignment: Alignment(0, 1 - (_pos * 2)),
            child: Icon(Icons.directions_car, size: 50, color: Colors.amber),
          ),
          Align(alignment: Alignment(0, -0.8), child: Icon(Icons.location_on, size: 50, color: Colors.red)),
          
          // لوحة معلومات الفني والتحكم
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.all(15), padding: EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.amber)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.amber, child: Icon(Icons.person, color: Colors.black)),
                    title: Text("م. أحمد علي (خبير أوتيس)"),
                    subtitle: Text("يصل خلال: ${(10 - (_pos * 10)).toInt()} دقيقة"),
                    trailing: IconButton(icon: Icon(Icons.call, color: Colors.green), onPressed: () {}),
                  ),
                  if(_pos >= 0.7) ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: Size(double.infinity, 45)),
                    onPressed: () => _showCompletionDialog(context),
                    child: Text("الفني وصل - إنهاء الخدمة"),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("التوقيع وإغلاق الطلب"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(decoration: InputDecoration(hintText: "كود الاستلام OTP")),
        SizedBox(height: 10),
        Container(height: 100, color: Colors.white10, child: Center(child: Text("وقع هنا بالأصبع"))),
      ]),
      actions: [ElevatedButton(onPressed: () => Navigator.pop(c), child: Text("اعتماد التقرير والفاتورة"))],
    ));
  }
}

// --- صفحة التقارير والفواتير ---
class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar(context, "السجلات المالية والفنية"),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (c, i) => Card(
          margin: EdgeInsets.all(10),
          child: ListTile(
            leading: Icon(Icons.picture_as_pdf, color: Colors.red),
            title: Text("تقرير صيانة ضريبي #$i"),
            subtitle: Text("العميل: فهد العتيبي | الضريبة 15%"),
            trailing: Icon(Icons.download, color: Colors.amber),
            onTap: () {},
          ),
        ),
      ),
    );
  }
}

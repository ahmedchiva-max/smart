import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(brightness: Brightness.dark, primaryColor: Colors.amber, fontFamily: 'Arial'),
  home: MasterMaintenanceApp(),
));

class MasterMaintenanceApp extends StatefulWidget { @override _MasterMaintenanceAppState createState() => _MasterMaintenanceAppState(); }
class _MasterMaintenanceAppState extends State<MasterMaintenanceApp> {
  int _screenIdx = 0;
  final _screens = [CustomerHome(), LiveTrackingScreen(), FinanceReports()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_screenIdx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _screenIdx, onTap: (i) => setState(() => _screenIdx = i),
        backgroundColor: Colors.black, selectedItemColor: Colors.amber,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.build_circle), label: "طلب صيانة"),
          BottomNavigationBarItem(icon: Icon(Icons.location_searching), label: "تتبع الفني"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "التقارير"),
        ],
      ),
    );
  }
}

// --- نظام الملاحة الموحد (Back, Home, X) ---
PreferredSizeWidget smartAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: Colors.black, elevation: 10,
    leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: Colors.amber, size: 20), onPressed: () => Navigator.maybePop(context)),
    title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    actions: [
      IconButton(icon: Icon(Icons.home_outlined, color: Colors.white), onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (c)=>MasterMaintenanceApp()), (r)=>false)),
      IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: () => SystemNavigator.pop()),
    ],
  );
}

// --- الصفحة الرئيسية (بدون المتجر) ---
class CustomerHome extends StatelessWidget {
  void _warn(BuildContext ctx, String msg) => showDialog(context: ctx, builder: (c) => AlertDialog(title: Text("تنبيه هـام"), content: Text(msg), actions: [ElevatedButton(onPressed: () => Navigator.pop(c), child: Text("حسناً"))]));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: smartAppBar(context, "Uber Elevators - الصيانة"),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: [
          _serviceBox(context, "إبلاغ عن عطل (فوري)", Icons.flash_on, Colors.red, "عطل"),
          SizedBox(height: 20),
          _serviceBox(context, "طلب صيانة دورية", Icons.settings_suggest, Colors.blue, "صيانة"),
        ]),
      ),
    );
  }

  Widget _serviceBox(BuildContext ctx, String t, IconData i, Color c, String type) => Expanded(
    child: InkWell(
      onTap: () => _openRequestFlow(ctx, type),
      child: Container(
        width: double.infinity, decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(25), border: Border.all(color: c, width: 2)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 80, color: c), SizedBox(height: 10), Text(t, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))]),
      ),
    ),
  );

  // --- تدفق الطلب (Flow) ---
  void _openRequestFlow(BuildContext ctx, String type) {
    final n = TextEditingController();
    final p = TextEditingController();
    showDialog(context: ctx, barrierDismissible: false, builder: (c) => AlertDialog(
      title: Text("بيانات العميل - $type"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: n, decoration: InputDecoration(hintText: "الاسم الثلاثي")),
        TextField(controller: p, keyboardType: TextInputType.phone, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)], decoration: InputDecoration(hintText: "الجوال (05XXXXXXXX)")),
      ]),
      actions: [ElevatedButton(onPressed: () {
        if (n.text.length < 5 || p.text.length != 10 || !p.text.startsWith("05")) {
          _warn(ctx, "يرجى إدخال اسم ثلاثي ورقم جوال صحيح يبدأ بـ 05");
        } else { Navigator.pop(c); _locationFlow(ctx); }
      }, child: Text("التالي"))],
    ));
  }

  void _locationFlow(BuildContext ctx) {
    showModalBottomSheet(context: ctx, shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))), builder: (c) => Container(
      padding: EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text("تحديد موقع المصعد", style: TextStyle(fontSize: 18, color: Colors.amber)),
        Divider(),
        ListTile(leading: Icon(Icons.gps_fixed, color: Colors.blue), title: Text("مشاركة موقعي الحالي"), onTap: () { Navigator.pop(c); _brandFlow(ctx); }),
        ListTile(leading: Image.network("https://upload.wikimedia.org/wikipedia/commons/6/6b/WhatsApp.svg", width: 24), title: Text("إرسال عبر الواتساب"), onTap: () { launchUrl(Uri.parse("https://wa.me/966500000000")); Navigator.pop(c); _brandFlow(ctx); }),
        ListTile(leading: Icon(Icons.link, color: Colors.red), title: Text("لصق رابط جوجل ماب"), onTap: () { Navigator.pop(c); _manualInput(ctx, "الصق رابط الخريطة هنا"); }),
        ListTile(leading: Icon(Icons.edit_location, color: Colors.orange), title: Text("وصف الموقع يدوياً"), onTap: () { Navigator.pop(c); _manualInput(ctx, "اكتب وصف العنوان بالتفصيل"); }),
      ]),
    ));
  }

  void _manualInput(BuildContext ctx, String hint) {
    final t = TextEditingController();
    showDialog(context: ctx, barrierDismissible: false, builder: (c) => AlertDialog(
      content: TextField(controller: t, maxLines: 3, decoration: InputDecoration(hintText: hint)),
      actions: [ElevatedButton(onPressed: () {
        if(t.text.trim().isEmpty) { _warn(ctx, "هذا الحقل إجباري للمتابعة"); return; }
        Navigator.pop(c); _brandFlow(ctx);
      }, child: Text("تأكيد الموقع"))],
    ));
  }

  void _brandFlow(BuildContext ctx) {
    final brands = ["إيطالي", "فوجي", "فوجي تك", "أوتيس", "شيندلر", "ميتسوبيشي", "كوني", "هوم ليفت"];
    showDialog(context: ctx, builder: (c) => AlertDialog(
      title: Text("اختر نوع المصعد"),
      content: Container(width: double.maxFinite, child: GridView.builder(shrinkWrap: true, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2), itemCount: brands.length, itemBuilder: (cc, i) => Card(child: InkWell(onTap: () { Navigator.pop(c); _techChoiceFlow(ctx, brands[i]); }, child: Center(child: Text(brands[i])))))),
    ));
  }

  void _techChoiceFlow(BuildContext ctx, String brand) {
    showDialog(context: ctx, builder: (c) => AlertDialog(
      title: Text("فنيين متخصصين في $brand"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _techTile(ctx, "م. خالد السعدي", "هوية: 1109XXX", "الأقرب - متاح", "4.9"),
        _techTile(ctx, "م. ياسر فيصل", "هوية: 1088XXX", "متاح حالياً", "4.8"),
      ]),
    ));
  }

  Widget _techTile(BuildContext ctx, String n, String id, String st, String rate) => ListTile(
    leading: CircleAvatar(child: Icon(Icons.person)), title: Text(n), subtitle: Text("$id\n$st"), trailing: Text(" $rate"),
    onTap: () { HapticFeedback.vibrate(); Navigator.pop(ctx); _paymentFlow(ctx); },
  );

  void _paymentFlow(BuildContext ctx) {
    showDialog(context: ctx, builder: (c) => AlertDialog(
      title: Text("طريقة الدفع"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _payItem(ctx, "Apple Pay", Colors.black, Icons.apple),
        _payItem(ctx, "STC Pay", Color(0xFF4F008C), Icons.account_balance_wallet),
        _payItem(ctx, "تحويل بنكي", Colors.grey, Icons.account_balance),
        Padding(padding: const EdgeInsets.all(8.0), child: Text("IBAN: SA00000000000000001234", style: TextStyle(fontSize: 10, color: Colors.amber))),
      ]),
    ));
  }

  Widget _payItem(BuildContext ctx, String t, Color c, IconData i) => InkWell(onTap: () { Navigator.pop(ctx); _receiptUpload(ctx); }, child: Card(color: c, child: ListTile(leading: Icon(i, color: Colors.white), title: Text(t, style: TextStyle(color: Colors.white)))));

  void _receiptUpload(BuildContext ctx) {
    showDialog(context: ctx, barrierDismissible: false, builder: (c) => AlertDialog(
      title: Text("رفع إثبات التحويل"),
      content: Icon(Icons.add_a_photo, size: 60, color: Colors.amber),
      actions: [ElevatedButton(onPressed: () { Navigator.pop(c); _warn(ctx, "تم اعتماد طلبك! يمكنك الآن تتبع الفني خطوة بخطوة."); }, child: Text("إتمام الطلب"))],
    ));
  }
}

// --- صفحة التتبع الحي (Live Tracking) ---
class LiveTrackingScreen extends StatefulWidget { @override _LiveTrackingScreenState createState() => _LiveTrackingScreenState(); }
class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  double _carPos = 0.0;
  int _minutes = 12;
  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 3), (t) { if(mounted && _carPos < 0.8) setState(() { _carPos += 0.05; _minutes--; }); });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: smartAppBar(context, "تتبع مسار الفني"),
      body: Stack(children: [
        Container(color: Colors.white12, child: Center(child: Icon(Icons.map, size: 200, color: Colors.white10))),
        AnimatedAlign(duration: Duration(seconds: 2), alignment: Alignment(0, 1 - (_carPos * 2)), child: Icon(Icons.directions_car, size: 50, color: Colors.amber)),
        Align(alignment: Alignment(0, -0.9), child: Icon(Icons.location_on, size: 60, color: Colors.red)),
        Align(alignment: Alignment.bottomCenter, child: Container(
          margin: EdgeInsets.all(20), padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.amber)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text("الوقت المقدر للوصول: $_minutes دقيقة", style: TextStyle(fontSize: 18, color: Colors.amber, fontWeight: FontWeight.bold)),
            Divider(),
            if(_carPos >= 0.7) ElevatedButton(onPressed: () => _showCompletionReport(context), child: Text("الفني وصل - عرض التقرير والتوقيع"))
            else Text("الفني في الطريق إليك الآن..."),
          ]),
        ))
      ]),
    );
  }

  void _showCompletionReport(BuildContext context) {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("تقرير الفني المعتمد"),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text("تشيك ليست الصيانة:", style: TextStyle(color: Colors.amber)),
        Text(" فحص الزيت\n فحص الحبال\n تنظيف الكنترول\n حساسات الأبواب"),
        Divider(),
        Text("قطع غيار مستبدلة:"),
        Text("- حساس باب خارجي (مصور قبل/بعد)"),
        SizedBox(height: 10),
        Container(height: 100, color: Colors.white10, child: Center(child: Text("توقيع العميل هنا"))),
      ])),
      actions: [ElevatedButton(onPressed: () => Navigator.pop(c), child: Text("إغلاق وإرسال للواتساب"))],
    ));
  }
}

// --- صفحة التقارير المالية والفنية ---
class FinanceReports extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: smartAppBar(context, "التقارير والفواتير"),
      body: ListView.builder(itemCount: 5, itemBuilder: (c, i) => Card(
        margin: EdgeInsets.all(10), child: ListTile(
          leading: Icon(Icons.picture_as_pdf, color: Colors.red),
          title: Text("فاتورة ضريبية #INV-770$i"),
          subtitle: Text("التاريخ: 2026/01/21 | القيمة: 575 ريال\n(شامل الضريبة 15%)"),
          trailing: Icon(Icons.share_outlined, color: Colors.amber),
          onTap: () {},
        ),
      )),
    );
  }
}

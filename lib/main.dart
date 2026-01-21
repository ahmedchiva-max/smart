import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(brightness: Brightness.dark, primaryColor: Colors.amber, fontFamily: 'Arial'),
  home: UberElevatorsMaster(),
));

class UberElevatorsMaster extends StatefulWidget { @override _UberElevatorsMasterState createState() => _UberElevatorsMasterState(); }
class _UberElevatorsMasterState extends State<UberElevatorsMaster> {
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: _customAppBar(context, "UBER ELEVATORS"),
      body: _idx == 0 ? _buildHomeScreen(context) : Center(child: Text("قيد العمل")),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx, onTap: (i) => setState(() => _idx = i),
        backgroundColor: Colors.black, selectedItemColor: Colors.amber, unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "طلباتي"),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: "التقارير"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "المتجر"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "حسابي"),
        ],
      ),
    );
  }

  // --- الواجهة المطابقة للصور حرفياً ---
  Widget _buildHomeScreen(BuildContext context) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: EdgeInsets.all(15), child: Text("مصاعدي المسجلة", style: TextStyle(fontWeight: FontWeight.bold))),
        Row(children: [
          _elevatorMiniCard("مصعد المنزل", "حي النرجس"),
          _elevatorMiniCard("مصعد المكتب", "برج رافال"),
        ]),
        // زر إبلاغ عطل فوري (الأحمر)
        _redAlertButton(context),
        // شبكة الخدمات الـ 6 (مطابقة للصورة)
        GridView.count(
          shrinkWrap: true, physics: NeverScrollableScrollPhysics(), crossAxisCount: 3, padding: EdgeInsets.all(10),
          children: [
            _serviceTile(Icons.add_box, "تركيب جديد", Colors.green, context),
            _serviceTile(Icons.update, "تحديث", Colors.amber, context),
            _serviceTile(Icons.build, "صيانة", Colors.blue, context),
            _serviceTile(Icons.store, "المتجر", Colors.yellow, context),
            _serviceTile(Icons.photo_library, "الأعمال", Colors.purple, context),
            _serviceTile(Icons.headset_mic, "تواصل", Colors.teal, context),
          ],
        ),
      ]),
    );
  }

  // --- زر البلاغ الفوري ---
  Widget _redAlertButton(BuildContext ctx) => Container(
    margin: EdgeInsets.all(15), height: 60, decoration: BoxDecoration(color: Colors.red[900], borderRadius: BorderRadius.circular(10)),
    child: ListTile(
      leading: Icon(Icons.bolt, color: Colors.white), title: Text("إبلاغ عن عطل (فوري)", style: TextStyle(fontWeight: FontWeight.bold)),
      trailing: Icon(Icons.arrow_forward_ios, size: 15), onTap: () => _startRequestFlow(ctx, "بلاغ عطل"),
    ),
  );

  Widget _serviceTile(IconData i, String l, Color c, BuildContext ctx) => InkWell(
    onTap: () => _startRequestFlow(ctx, l),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, color: c, size: 35), SizedBox(height: 5), Text(l, style: TextStyle(fontSize: 12))]),
  );

  Widget _elevatorMiniCard(String n, String l) => Container(
    width: 140, margin: EdgeInsets.only(left: 15), padding: EdgeInsets.all(10),
    decoration: BoxDecoration(color: Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.elevator, color: Colors.amber, size: 18), Text(n, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), Text(l, style: TextStyle(fontSize: 9, color: Colors.grey))]),
  );

  // --- تدفق الطلب المليء بالتفاصيل (The Heavy Logic) ---
  void _startRequestFlow(BuildContext context, String type) {
    final nameC = TextEditingController();
    final phoneC = TextEditingController();
    
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (c) => Container(
      height: MediaQuery.of(context).size.height * 0.9, decoration: BoxDecoration(color: Color(0xFF121212), borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      child: Column(children: [
        _customAppBar(context, "طلب $type"),
        Expanded(child: ListView(padding: EdgeInsets.all(20), children: [
          _inputLabel("البيانات الشخصية"),
          _field(nameC, "الاسم الثلاثي"),
          _field(phoneC, "الجوال (05XXXXXXXX)", isPhone: true),
          SizedBox(height: 20),
          _inputLabel("موقع المصعد (إجباري)"),
          _locOption(context, "مشاركة الموقع الحالي (GPS)", Icons.my_location),
          _locOption(context, "واتساب المؤسسة (إرسال الموقع)", Icons.chat, isWhatsApp: true),
          _locOption(context, "لصق رابط جوجل ماب", Icons.link, isLink: true),
          _locOption(context, "وصف الموقع يدوياً", Icons.text_snippet, isDesc: true),
          SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, minimumSize: Size(double.infinity, 50)),
            onPressed: () {
              if (nameC.text.length < 5 || phoneC.text.length != 10 || !phoneC.text.startsWith("05")) {
                _errorPop(context, "بيانات خاطئة! تأكد من الاسم ورقم الجوال (05)");
              } else { Navigator.pop(c); _brandSelection(context); }
            }, child: Text("التالي (نوع المصعد)", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ]))
      ]),
    ));
  }

  // --- اختيار نوع المصعد والفني ---
  void _brandSelection(BuildContext ctx) {
    final brands = ["إيطالي", "فوجي", "فوجي تك", "أوتيس", "شيندلر", "ميتسوبيشي", "كوني", "هوم ليفت"];
    showDialog(context: ctx, builder: (c) => AlertDialog(
      title: Text("اختر نوع المصعد"),
      content: Wrap(spacing: 10, children: brands.map((b) => ActionChip(label: Text(b), onPressed: () { Navigator.pop(c); _techChoice(ctx, b); })).toList()),
    ));
  }

  void _techChoice(BuildContext ctx, String b) {
    showDialog(context: ctx, builder: (c) => AlertDialog(
      title: Text("الفني الأقرب لـ $b"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _techTile(ctx, "م. فهد العتيبي", "ID: 1102XXX", "متاح - خبير $b"),
        _techTile(ctx, "م. سامي الحربي", "ID: 1099XXX", "متاح حالياً"),
      ]),
    ));
  }

  Widget _techTile(BuildContext ctx, String n, String id, String s) => ListTile(
    leading: CircleAvatar(child: Icon(Icons.person)), title: Text(n), subtitle: Text("$id\n$s"),
    onTap: () { HapticFeedback.heavyImpact(); Navigator.pop(ctx); _paymentFinal(ctx); },
  );

  void _paymentFinal(BuildContext ctx) {
    showDialog(context: ctx, builder: (c) => AlertDialog(
      title: Text("طرق الدفع"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _pBtn("Apple Pay", Colors.black, Icons.apple),
        _pBtn("STC Pay", Color(0xFF4F008C), Icons.account_balance_wallet),
        _pBtn("تحويل بنكي", Colors.grey, Icons.account_balance),
      ]),
    ));
  }

  Widget _pBtn(String t, Color c, IconData i) => Card(color: c, child: ListTile(leading: Icon(i, color: Colors.white), title: Text(t, style: TextStyle(color: Colors.white)), onTap: () {}));

  // --- الأدوات المساعدة ---
  Widget _customAppBar(BuildContext ctx, String t) => AppBar(
    backgroundColor: Colors.black, leading: IconButton(icon: Icon(Icons.arrow_back_ios, size: 18, color: Colors.amber), onPressed: () => Navigator.maybePop(ctx)),
    title: Text(t, style: TextStyle(fontSize: 15)),
    actions: [IconButton(icon: Icon(Icons.home), onPressed: () => Navigator.of(ctx).pushAndRemoveUntil(MaterialPageRoute(builder: (c)=>UberElevatorsMaster()), (r)=>false)), IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: () => SystemNavigator.pop())],
  );

  Widget _field(TextEditingController c, String h, {bool isPhone = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(controller: c, keyboardType: isPhone ? TextInputType.phone : TextInputType.text, decoration: InputDecoration(hintText: h, filled: true, fillColor: Colors.white10, border: OutlineInputBorder())),
  );

  Widget _locOption(BuildContext ctx, String t, IconData i, {bool isWhatsApp=false, bool isLink=false, bool isDesc=false}) => ListTile(
    leading: Icon(i, color: isWhatsApp ? Colors.green : Colors.amber), title: Text(t, style: TextStyle(fontSize: 13)),
    onTap: () { if(isWhatsApp) {} else if(isLink || isDesc) { _manualPop(ctx, t); } },
  );

  void _manualPop(BuildContext ctx, String t) => showDialog(context: ctx, builder: (c) => AlertDialog(content: TextField(decoration: InputDecoration(hintText: t)), actions: [ElevatedButton(onPressed: () => Navigator.pop(c), child: Text("تأكيد"))]));

  void _errorPop(BuildContext ctx, String m) => showDialog(context: ctx, builder: (c) => AlertDialog(title: Text("خطأ"), content: Text(m), actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text("حسناً"))]));

  Widget _inputLabel(String t) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(t, style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)));
}

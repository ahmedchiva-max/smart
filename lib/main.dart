import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(brightness: Brightness.dark, primaryColor: Colors.amber, fontFamily: 'Arial'),
  home: MaintenanceSystem(),
));

class MaintenanceSystem extends StatefulWidget { @override _MaintenanceSystemState createState() => _MaintenanceSystemState(); }
class _MaintenanceSystemState extends State<MaintenanceSystem> {
  int _idx = 0;
  final _pages = [MaintenanceHome(), OrdersPage(), ReportsPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx, onTap: (i) => setState(() => _idx = i),
        backgroundColor: Colors.black, selectedItemColor: Colors.amber,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.build), label: "طلب خدمة"),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: "تتبع طلباتي"),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: "تقارير وفواتير"),
        ],
      ),
    );
  }
}

// --- الصفحة الرئيسية للطلب ---
class MaintenanceHome extends StatefulWidget { @override _MaintenanceHomeState createState() => _MaintenanceHomeState(); }
class _MaintenanceHomeState extends State<MaintenanceHome> {
  final name = TextEditingController();
  final phone = TextEditingController();
  String? elevatorBrand;
  
  final brands = ["إيطالي", "فوجي", "فوجي تك", "أوتيس", "شيندلر", "ميتسوبيشي", "كوني", "هوم ليفت"];

  void _pop(String t, String m) => showDialog(context: context, builder: (c) => AlertDialog(title: Text(t), content: Text(m), actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text("حسناً"))]));

  // الخطوة 1: البيانات الشخصية والموقع
  void _startRequest(String type) {
    showDialog(context: context, barrierDismissible: false, builder: (c) => AlertDialog(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("طلب $type"), IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: () => Navigator.pop(c))]),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: InputDecoration(hintText: "اسم العميل الثلاثي")),
          SizedBox(height: 10),
          TextField(controller: phone, keyboardType: TextInputType.phone, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)], decoration: InputDecoration(hintText: "الجوال (05XXXXXXXX)")),
        ]),
      ),
      actions: [ElevatedButton(onPressed: () {
        if (name.text.length < 5 || phone.text.length != 10 || !phone.text.startsWith("05")) {
          _pop("خطأ في البيانات", "يرجى إدخال اسم ثلاثي ورقم جوال صحيح يبدأ بـ 05");
        } else { Navigator.pop(c); _locationStep(); }
      }, child: Text("التالي (الموقع)"))],
    ));
  }

  void _locationStep() {
    showModalBottomSheet(context: context, builder: (c) => Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: Icon(Icons.my_location, color: Colors.blue), title: Text("موقعي الحالي"), onTap: () { Navigator.pop(c); _brandStep(); }),
      ListTile(leading: Icon(Icons.chat, color: Colors.green), title: Text("واتساب (تلقائي)"), onTap: () { launchUrl(Uri.parse("https://wa.me/966500000000")); Navigator.pop(c); _brandStep(); }),
      ListTile(leading: Icon(Icons.map, color: Colors.red), title: Text("لصق رابط جوجل ماب"), onTap: () => _manualInput("رابط جوجل ماب")),
      ListTile(leading: Icon(Icons.edit, color: Colors.orange), title: Text("وصف الموقع يدوياً"), onTap: () => _manualInput("وصف الموقع")),
    ]));
  }

  void _manualInput(String h) {
    final t = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      content: TextField(controller: t, decoration: InputDecoration(hintText: h)),
      actions: [ElevatedButton(onPressed: () {
        if(t.text.isEmpty) { _pop("تنبيه", "الحقل إجباري"); return; }
        Navigator.pop(context); _brandStep();
      }, child: Text("تأكيد"))],
    ));
  }

  // الخطوة 2: نوع المصعد
  void _brandStep() {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("اختر نوع المصعد"),
      content: Container(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemCount: brands.length, itemBuilder: (cc, i) => Card(
            child: InkWell(onTap: () { setState(() => elevatorBrand = brands[i]); Navigator.pop(c); _techStep(); },
            child: Center(child: Text(brands[i], textAlign: TextAlign.center))),
          ),
        ),
      ),
    ));
  }

  // الخطوة 3: اختيار الفني
  void _techStep() {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("الفنيون المتاحون لنوع ($elevatorBrand)"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _techTile("م. أحمد علي", "هوية: 1092XXXX", "متاح - خبير $elevatorBrand", "5 دقائق"),
        _techTile("م. سامي محمد", "هوية: 1055XXXX", "متاح - فني متخصص", "12 دقيقة"),
      ]),
    ));
  }

  Widget _techTile(String n, String id, String st, String time) => ListTile(
    leading: CircleAvatar(child: Icon(Icons.person)),
    title: Text(n), subtitle: Text("$id\n$st"),
    trailing: Text(time, style: TextStyle(color: Colors.amber)),
    onTap: () { HapticFeedback.heavyImpact(); Navigator.pop(context); _payment(); },
  );

  // الخطوة 4: الدفع والرفع
  void _payment() {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("الدفع لفتح تذكرة الخدمة"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _payBtn("Apple Pay", Colors.black, Icons.apple),
        _payBtn("STC Pay", Color(0xFF4F008C), Icons.account_balance_wallet),
        _payBtn("تحويل بنكي", Colors.grey, Icons.account_balance),
        Text("\nIBAN: SA10000000000000123456", style: TextStyle(fontSize: 10, color: Colors.amber)),
      ]),
    ));
  }

  Widget _payBtn(String t, Color c, IconData i) => InkWell(onTap: () { Navigator.pop(context); _upload(); }, child: Card(color: c, child: ListTile(leading: Icon(i, color: Colors.white), title: Text(t, style: TextStyle(color: Colors.white)))));

  void _upload() {
    showDialog(context: context, barrierDismissible: false, builder: (c) => AlertDialog(
      title: Text("رفع إيصال الدفع (إجباري)"),
      content: Icon(Icons.camera_alt, size: 50, color: Colors.amber),
      actions: [ElevatedButton(onPressed: () { Navigator.pop(c); _pop("تم بنجاح", "تم توجيه الفني لموقعك، يمكنك تتبعه الآن"); }, child: Text("إرسال"))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("خدمات SMART للمصاعد"), backgroundColor: Colors.black, actions: [IconButton(icon: Icon(Icons.home), onPressed: (){})]),
      body: Column(children: [
        _mainTile("طلب صيانة دورية", Icons.calendar_today, Colors.blue, () => _startRequest("صيانة")),
        _mainTile("بلاغ عطل طارئ", Icons.warning, Colors.red, () => _startRequest("بلاغ عطل")),
      ]),
    );
  }

  Widget _mainTile(String t, IconData i, Color c, VoidCallback f) => Expanded(child: InkWell(onTap: f, child: Container(margin: EdgeInsets.all(15), decoration: BoxDecoration(color: c.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: c)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 80, color: c), Text(t, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))]))));
}

// --- صفحة التتبع والخريطة ---
class OrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("تتبع الفني الآن"), backgroundColor: Colors.black),
      body: Column(children: [
        Container(height: 300, color: Colors.white10, child: Center(child: Icon(Icons.map, size: 100, color: Colors.grey))),
        Padding(padding: EdgeInsets.all(20), child: Column(children: [
          ListTile(leading: Icon(Icons.local_shipping, color: Colors.amber), title: Text("الفني في الطريق إليك"), subtitle: Text("الوقت المتوقع: 4 دقائق")),
          Divider(),
          ElevatedButton(onPressed: () => _deliveryDialog(context), child: Text("إنهاء الخدمة وتوقيع العميل")),
        ])),
      ]),
    );
  }

  void _deliveryDialog(BuildContext ctx) {
    showDialog(context: ctx, builder: (c) => AlertDialog(
      title: Text("توقيع العميل وإغلاق التذكرة"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text("أدخل رمز الـ OTP:"),
        TextField(keyboardType: TextInputType.number),
        SizedBox(height: 10),
        Container(height: 100, color: Colors.white12, child: Center(child: Text("وقع هنا بالأصبع"))),
      ]),
      actions: [ElevatedButton(onPressed: () => Navigator.pop(c), child: Text("اعتماد الاستلام"))],
    ));
  }
}

// --- صفحة التقارير والفواتير الاحترافية ---
class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("سجلات الصيانة والتقارير"), backgroundColor: Colors.black),
      body: ListView.builder(itemCount: 3, itemBuilder: (c, i) => Card(
        margin: EdgeInsets.all(10),
        child: ExpansionTile(
          leading: Icon(Icons.picture_as_pdf, color: Colors.red),
          title: Text("تقرير صيانة #M-770$i"),
          subtitle: Text("التاريخ: 2026/01/21 | الفني: م. أحمد"),
          children: [
            Padding(padding: EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("قائمة الفحص (Checklist):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
              Text(" زيت الماكينة\n أسلاك الجر\n لوحة الكنترول\n حساسات الأبواب"),
              Divider(),
              Text("قطع تم تغييرها:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("- حساس باب خارجي (قبل/بعد مصور)"),
              Divider(),
              Text("الفاتورة الضريبية:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("الإجمالي: 500 ريال\nالضريبة (15%): 75 ريال\nالصافي: 575 ريال"),
              ElevatedButton.icon(onPressed: () {}, icon: Icon(Icons.share), label: Text("إرسال للواتساب")),
            ])),
          ],
        ),
      )),
    );
  }
}

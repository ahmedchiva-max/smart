import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(fontFamily: 'Arial', brightness: Brightness.dark, primaryColor: Colors.amber),
  home: MainContainer(),
));

class MainContainer extends StatefulWidget { @override _MainContainerState createState() => _MainContainerState(); }
class _MainContainerState extends State<MainContainer> {
  int _idx = 3;
  final _pages = [Center(child: Text("الرئيسية")), OrdersPage(), ReportsPage(), ShopPage(), Center(child: Text("حسابي"))];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx, onTap: (i) => setState(() => _idx = i),
        backgroundColor: Colors.black, selectedItemColor: Colors.amber, unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: "طلباتي"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "التقارير"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "المتجر"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "حسابي"),
        ],
      ),
    );
  }
}

class ShopPage extends StatefulWidget { @override _ShopPageState createState() => _ShopPageState(); }
class _ShopPageState extends State<ShopPage> {
  List<Map<String, dynamic>> cart = [];
  String? currentCat;
  final cats = ["قسم المكائن", "قسم الكهرباء", "الميكانيكا", "الأبواب", "الكبائن", "الكنترول", "الاكسسوارات"];
  final Map<String, List<Map<String, dynamic>>> prods = {
    "قسم المكائن": [{"n": "ماكينة سيكور 5.5 حصان", "p": 4500.0}],
    "قسم الكهرباء": [{"n": "انفرتر ياسكاوا 4 كيلو", "p": 1900.0}],
    "الميكانيكا": [{"n": "حبال صلب 10 ملم", "p": 150.0}],
    "الأبواب": [{"n": "باب أتوماتيك تيسن", "p": 3200.0}],
    "الكبائن": [{"n": "كبينة ذهبية ملكي", "p": 15000.0}],
    "الكنترول": [{"n": "كنترول سمارت 4 أدوار", "p": 2800.0}],
    "الاكسسوارات": [{"n": "أزرار استدعاء ذهبية", "p": 85.0}],
  };

  void _pop(String t, String m) => showDialog(context: context, builder: (c) => AlertDialog(title: Text(t), content: Text(m), actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text("حسناً"))]));

  void _startOrderFlow() {
    if (cart.isEmpty) { _pop("تنبيه", "السلة فارغة"); return; }
    final n = TextEditingController();
    final p = TextEditingController();
    showDialog(context: context, barrierDismissible: false, builder: (c) => AlertDialog(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("بيانات العميل"), IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: () => Navigator.pop(c))]),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: n, decoration: InputDecoration(hintText: "الاسم الثلاثي")),
        TextField(controller: p, keyboardType: TextInputType.number, inputFormatters: [LengthLimitingTextInputFormatter(10)], decoration: InputDecoration(hintText: "الجوال (05XXXXXXXX)")),
      ]),
      actions: [ElevatedButton(onPressed: () {
        if (n.text.length < 5 || p.text.length != 10 || !p.text.startsWith("05")) { _pop("خطأ", "تأكد من الاسم والجوال (05)"); return; }
        Navigator.pop(c); _loc();
      }, child: Text("التالي"))],
    ));
  }

  void _loc() {
    showModalBottomSheet(context: context, builder: (c) => Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: Icon(Icons.my_location), title: Text("موقعي الحالي"), onTap: () { Navigator.pop(c); _pay(); }),
      ListTile(leading: Icon(Icons.chat), title: Text("واتساب"), onTap: () { launchUrl(Uri.parse("https://wa.me/966500000000")); Navigator.pop(c); _pay(); }),
      ListTile(leading: Icon(Icons.map), title: Text("رابط جوجل ماب"), onTap: () => _manual("لصق الرابط")),
      ListTile(leading: Icon(Icons.edit), title: Text("وصف يدوي"), onTap: () => _manual("اكتب الوصف")),
    ]));
  }

  void _manual(String h) {
    final t = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      content: TextField(controller: t, decoration: InputDecoration(hintText: h)),
      actions: [ElevatedButton(onPressed: () { if(t.text.isEmpty) return; Navigator.pop(c); _pay(); }, child: Text("تأكيد"))],
    ));
  }

  void _pay() {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("الدفع"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _pBtn("Apple Pay", Colors.black, Icons.apple),
        _pBtn("تحويل بنكي", Colors.blueGrey, Icons.account_balance),
        Text("IBAN: SA12345678901234567890", style: TextStyle(color: Colors.amber, fontSize: 10)),
      ]),
    ));
  }

  Widget _pBtn(String t, Color c, IconData i) => InkWell(onTap: () { Navigator.pop(context); _up(); }, child: Card(color: c, child: ListTile(leading: Icon(i, color: Colors.white), title: Text(t, style: TextStyle(color: Colors.white)))));

  void _up() {
    showDialog(context: context, barrierDismissible: false, builder: (c) => AlertDialog(
      title: Text("رفع الإيصال (إجباري)"),
      content: Icon(Icons.upload_file, size: 50, color: Colors.amber),
      actions: [ElevatedButton(onPressed: () { setState(() => cart.clear()); Navigator.pop(c); _pop("نجاح", "تم استلام طلبك"); }, child: Text("تأكيد الرفع"))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: currentCat != null ? IconButton(icon: Icon(Icons.arrow_back, color: Colors.amber), onPressed: () => setState(() => currentCat = null)) : Icon(Icons.home, color: Colors.amber),
        title: Text(currentCat ?? "متجر SMART"),
        actions: [
          Stack(alignment: Alignment.center, children: [
            IconButton(icon: Icon(Icons.shopping_cart), onPressed: _startOrderFlow),
            if(cart.isNotEmpty) Positioned(top: 5, right: 5, child: CircleAvatar(radius: 8, backgroundColor: Colors.red, child: Text("${cart.length}", style: TextStyle(fontSize: 10))))
          ]),
          IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: () => SystemNavigator.pop()),
        ],
      ),
      body: currentCat == null ? _grid() : _list(),
    );
  }

  Widget _grid() => GridView.builder(padding: EdgeInsets.all(10), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2), itemCount: cats.length, itemBuilder: (c, i) => Card(color: Color(0xFF1E1E1E), child: InkWell(onTap: () => setState(() => currentCat = cats[i]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.settings, color: Colors.amber), Text(cats[i])]))));

  Widget _list() {
    final ps = prods[currentCat] ?? [];
    return ListView.builder(itemCount: ps.length, itemBuilder: (c, i) => ListTile(title: Text(ps[i]['n'].toString()), subtitle: Text("${ps[i]['p']} ريال", style: TextStyle(color: Colors.amber)), trailing: ElevatedButton(onPressed: () => setState(() => cart.add(ps[i])), child: Text("إضافة"))));
  }
}

class OrdersPage extends StatefulWidget { @override _OrdersPageState createState() => _OrdersPageState(); }
class _OrdersPageState extends State<OrdersPage> {
  void _sign(String id) {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("توقيع استلام $id"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(decoration: InputDecoration(hintText: "أدخل OTP المستلم")),
        SizedBox(height: 10),
        Container(height: 100, color: Colors.white10, child: Center(child: Text("لوحة التوقيع بالأصبع"))),
      ]),
      actions: [ElevatedButton(onPressed: () { Navigator.pop(c); }, child: Text("تأكيد التوقيع"))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(backgroundColor: Colors.black, title: Text("طلباتي"), leading: Icon(Icons.local_shipping, color: Colors.amber)),
      body: ListView(padding: EdgeInsets.all(10), children: [
        Card(color: Color(0xFF1E1E1E), child: ListTile(
          title: Text("ORD-9901 - وصلت الوجهة", style: TextStyle(color: Colors.amber)),
          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("تم الطلب -> في الشحن -> وصلت"), LinearProgressIndicator(value: 1.0, color: Colors.amber)]),
          trailing: ElevatedButton(onPressed: () => _sign("ORD-9901"), child: Text("استلام وتوقيع")),
        ))
      ]),
    );
  }
}

class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(backgroundColor: Colors.black, title: Text("التقارير المالية")),
      body: ListView.builder(itemCount: 3, itemBuilder: (c, i) => Card(color: Color(0xFF1E1E1E), child: ListTile(
        leading: Icon(Icons.picture_as_pdf, color: Colors.red),
        title: Text("فاتورة ضريبية #INV-$i"),
        subtitle: Text("القيمة: 5175 ريال (شامل ضريبة 15%)"),
        trailing: IconButton(icon: Icon(Icons.print), onPressed: () {}),
      ))),
    );
  }
}

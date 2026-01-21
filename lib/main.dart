import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false, 
  theme: ThemeData(fontFamily: 'Arial', primaryColor: Colors.amber), 
  home: MainNavigation()
));

class MainNavigation extends StatefulWidget { @override _MainNavigationState createState() => _MainNavigationState(); }
class _MainNavigationState extends State<MainNavigation> {
  int _index = 3; 
  final _pages = [Center(child: Text("الرئيسية")), OrdersPage(), ReportsPage(), ShopPage(), Center(child: Text("حسابي"))];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black, unselectedItemColor: Colors.grey, selectedItemColor: Colors.amber, type: BottomNavigationBarType.fixed,
        currentIndex: _index, onTap: (i) => setState(() => _index = i),
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

// --- صفحة المتجر المتكاملة ---
class ShopPage extends StatefulWidget { @override _ShopPageState createState() => _ShopPageState(); }
class _ShopPageState extends State<ShopPage> {
  List<Map<String, dynamic>> cart = [];
  String? currentCat;
  final cats = ["قسم المكائن", "قسم الكهرباء", "الميكانيكا", "الأبواب", "الكبائن", "الكنترول", "الاكسسوارات"];
  
  final Map<String, List<Map<String, dynamic>>> products = {
    "قسم المكائن": [{"n": "ماكينة سيكور 5.5 حصان", "p": 4500.0}],
    "قسم الكهرباء": [{"n": "انفرتر ياسكاوا 4 كيلو", "p": 1900.0}],
    "الميكانيكا": [{"n": "حبال صلب 10 ملم", "p": 150.0}],
    "الأبواب": [{"n": "باب أتوماتيك تيسن", "p": 3200.0}],
    "الكبائن": [{"n": "كبينة ذهبية ملكي", "p": 15000.0}],
    "الكنترول": [{"n": "كنترول سمارت 4 أدوار", "p": 2800.0}],
    "الاكسسوارات": [{"n": "أزرار استدعاء ذهبية", "p": 85.0}],
  };

  void _startCheckout() {
    if (cart.isEmpty) { _msg("السلة فارغة!"); return; }
    _showInstall();
  }

  void _showInstall() {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("خيار التنفيذ"),
      content: Text("هل الشراء للقطعة فقط أم مع التركيب؟"),
      actions: [
        ElevatedButton(onPressed: () { Navigator.pop(c); _userInfo(); }, child: Text("قطعة فقط")),
        ElevatedButton(onPressed: () { Navigator.pop(c); _userInfo(); }, child: Text("مع التركيب")),
      ],
    ));
  }

  void _userInfo() {
    final n = TextEditingController();
    final p = TextEditingController();
    showDialog(context: context, barrierDismissible: false, builder: (c) => AlertDialog(
      title: Text("بيانات العميل"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: n, decoration: InputDecoration(hintText: "الاسم الكامل")),
        TextField(controller: p, keyboardType: TextInputType.phone, decoration: InputDecoration(hintText: "الجوال (05XXXXXXXX)")),
      ]),
      actions: [
        ElevatedButton(onPressed: () {
          if (n.text.isEmpty) return;
          if (p.text.length == 10 && p.text.startsWith("05")) { Navigator.pop(c); _loc(); }
          else { _msg("يجب أن يبدأ بـ 05 ويتكون من 10 أرقام"); }
        }, child: Text("التالي"))
      ],
    ));
  }

  void _loc() {
    showModalBottomSheet(context: context, builder: (c) => Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: Icon(Icons.my_location), title: Text("موقعي الحالي"), onTap: () { Navigator.pop(c); _pay(); }),
      ListTile(leading: Icon(Icons.chat), title: Text("واتساب"), onTap: () { launchUrl(Uri.parse("https://wa.me/966590000000")); _pay(); }),
      ListTile(leading: Icon(Icons.map), title: Text("لصق رابط جوجل ماب"), onTap: () => _manual("رابط الموقع")),
      ListTile(leading: Icon(Icons.edit), title: Text("وصف الموقع يدوياً"), onTap: () => _manual("اكتب الوصف")),
    ]));
  }

  void _manual(String h) {
    showDialog(context: context, builder: (c) => AlertDialog(
      content: TextField(decoration: InputDecoration(hintText: h)),
      actions: [ElevatedButton(onPressed: () { Navigator.pop(c); _pay(); }, child: Text("تأكيد"))],
    ));
  }

  void _pay() {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("طريقة الدفع"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _pBtn("Apple Pay", Colors.black, Icons.apple),
        _pBtn("تحويل بنكي", Colors.blueGrey, Icons.account_balance),
        Text("\nIBAN: SA9380000001234567890", style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
      ]),
    ));
  }

  Widget _pBtn(String t, Color c, IconData i) => GestureDetector(
    onTap: () { Navigator.pop(context); _upload(); },
    child: Card(color: c, child: ListTile(leading: Icon(i, color: Colors.white), title: Text(t, style: TextStyle(color: Colors.white)))),
  );

  void _upload() {
    showDialog(context: context, barrierDismissible: false, builder: (c) => AlertDialog(
      title: Text("رفع الإيصال (إجباري)"),
      content: Icon(Icons.upload_file, size: 50, color: Colors.amber),
      actions: [ElevatedButton(onPressed: () { setState(() => cart.clear()); Navigator.pop(c); _msg("تم الطلب بنجاح!"); }, child: Text("تأكيد الرفع"))],
    ));
  }

  void _msg(String m) => showDialog(context: context, builder: (c) => AlertDialog(content: Text(m), actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text("حسناً"))]));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black, title: Text(currentCat ?? "متجر المصاعد"),
        actions: [
          Stack(alignment: Alignment.center, children: [
            IconButton(icon: Icon(Icons.shopping_cart), onPressed: _startCheckout),
            if(cart.isNotEmpty) Positioned(top: 5, right: 5, child: CircleAvatar(radius: 8, backgroundColor: Colors.red, child: Text("${cart.length}", style: TextStyle(fontSize: 10))))
          ]),
        ],
      ),
      body: currentCat == null ? _grid() : _list(),
    );
  }

  Widget _grid() => GridView.builder(padding: EdgeInsets.all(10), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2), itemCount: cats.length, itemBuilder: (c, i) => Card(color: Color(0xFF222222), child: InkWell(onTap: () => setState(() => currentCat = cats[i]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.category, color: Colors.amber), Text(cats[i], style: TextStyle(color: Colors.white))]))));

  Widget _list() {
    final ps = products[currentCat] ?? [];
    return ListView.builder(itemCount: ps.length, itemBuilder: (c, i) => ListTile(title: Text(ps[i]['n'], style: TextStyle(color: Colors.white)), subtitle: Text("${ps[i]['p']} ريال", style: TextStyle(color: Colors.amber)), trailing: ElevatedButton(onPressed: () => setState(() => cart.add(ps[i])), child: Text("إضافة"))));
  }
}

// --- صفحة طلباتي (تتبع وتوقيع) ---
class OrdersPage extends StatefulWidget { @override _OrdersPageState createState() => _OrdersPageState(); }
class _OrdersPageState extends State<OrdersPage> {
  void _sign(String id) {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("توقيع استلام الشحنة"),
      content: Container(height: 100, width: double.infinity, decoration: BoxDecoration(color: Colors.white10, border: Border.all(color: Colors.white24)), child: Center(child: Text("وقع هنا", style: TextStyle(color: Colors.grey)))),
      actions: [ElevatedButton(onPressed: () { Navigator.pop(c); _done(); }, child: Text("اعتماد"))],
    ));
  }
  void _done() => showDialog(context: context, builder: (c) => AlertDialog(content: Text("تم الاستلام بنجاح!")));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(backgroundColor: Colors.black, title: Text("تتبع طلباتي")),
      body: ListView(padding: EdgeInsets.all(15), children: [
        _order("ORD-8812", "وصلت الوجهة", 0.95, true),
        _order("ORD-7721", "في الطريق", 0.50, false),
      ]),
    );
  }

  Widget _order(String id, String st, double p, bool sign) => Card(
    color: Color(0xFF1E1E1E), child: Padding(padding: EdgeInsets.all(15), child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(id, style: TextStyle(color: Colors.amber)), Text(st, style: TextStyle(color: Colors.white))]),
      SizedBox(height: 10),
      LinearProgressIndicator(value: p, color: Colors.amber),
      SizedBox(height: 10),
      if(sign) ElevatedButton(onPressed: () => _sign(id), child: Text("توقيع واستلام"))
      else Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Icon(Icons.call, color: Colors.green), Icon(Icons.map, color: Colors.blue), Icon(Icons.picture_as_pdf, color: Colors.red)]),
    ])),
  );
}

// --- صفحة التقارير ---
class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 2, child: Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(backgroundColor: Colors.black, title: Text("التقارير"), bottom: TabBar(tabs: [Tab(text: "الجديدة"), Tab(text: "الأرشيف")])),
      body: TabBarView(children: [_list(), _list()]),
    ));
  }
  Widget _list() => ListView(children: [ListTile(title: Text("فاتورة ضريبية #8812", style: TextStyle(color: Colors.white)), subtitle: Text("5750 ريال", style: TextStyle(color: Colors.amber)), trailing: Icon(Icons.picture_as_pdf, color: Colors.red))]);
}

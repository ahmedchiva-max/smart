import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(fontFamily: 'Arial', primaryColor: Colors.amber),
  home: MainNav(),
));

class MainNav extends StatefulWidget { @override _MainNavState createState() => _MainNavState(); }
class _MainNavState extends State<MainNav> {
  int _idx = 3;
  final _pages = [Center(child: Text("الرئيسية")), OrdersPage(), ReportsPage(), ShopPage(), Center(child: Text("حسابي"))];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_idx],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black, unselectedItemColor: Colors.grey, selectedItemColor: Colors.amber, type: BottomNavigationBarType.fixed,
        currentIndex: _idx, onTap: (i) => setState(() => _idx = i),
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

// --- صفحة المتجر ---
class ShopPage extends StatefulWidget { @override _ShopPageState createState() => _ShopPageState(); }
class _ShopPageState extends State<ShopPage> {
  List<Map<String, dynamic>> cart = [];
  String? currentCat;
  final cats = ["قسم المكائن", "قسم الكهرباء", "الميكانيكا", "الأبواب", "الكبائن", "الكنترول", "الاكسسوارات"];
  final prods = {
    "قسم المكائن": [{"n": "ماكينة سيكور 5.5 حصان", "p": 4500.0}],
    "قسم الكهرباء": [{"n": "انفرتر ياسكاوا 4 كيلو", "p": 1900.0}],
    "الميكانيكا": [{"n": "حبال صلب 10 ملم", "p": 150.0}],
    "الأبواب": [{"n": "باب أتوماتيك تيسن", "p": 3200.0}],
    "الكبائن": [{"n": "كبينة ذهبية ملكي", "p": 15000.0}],
    "الكنترول": [{"n": "كنترول سمارت 4 أدوار", "p": 2800.0}],
    "الاكسسوارات": [{"n": "أزرار استدعاء ذهبية", "p": 85.0}],
  };

  void _validateAndOrder() {
    if (cart.isEmpty) { _pop("تنبيه", "السلة فارغة، أضف بضاعة أولاً"); return; }
    _showInstallChoice();
  }

  void _showInstallChoice() {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("نوع الطلب"),
      content: Text("هل تريد شراء القطعة فقط أم مع التركيب؟"),
      actions: [
        ElevatedButton(onPressed: () { Navigator.pop(c); _userData(); }, child: Text("قطعة فقط")),
        ElevatedButton(onPressed: () { Navigator.pop(c); _userData(); }, child: Text("مع التركيب")),
      ],
    ));
  }

  void _userData() {
    final n = TextEditingController();
    final p = TextEditingController();
    showDialog(context: context, barrierDismissible: false, builder: (c) => AlertDialog(
      title: Text("بيانات العميل"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: n, decoration: InputDecoration(hintText: "الاسم الثلاثي")),
        TextField(controller: p, keyboardType: TextInputType.phone, inputFormatters: [LengthLimitingTextInputFormatter(10)], decoration: InputDecoration(hintText: "الجوال (05XXXXXXXX)")),
      ]),
      actions: [
        ElevatedButton(onPressed: () {
          if (n.text.trim().length < 5) { _pop("خطأ", "يرجى كتابة الاسم الثلاثي كاملاً"); return; }
          if (p.text.length != 10 || !p.text.startsWith("05")) { _pop("خطأ", "الجوال يجب أن يبدأ بـ 05 ويتكون من 10 أرقام"); return; }
          Navigator.pop(c); _loc();
        }, child: Text("التالي"))
      ],
    ));
  }

  void _loc() {
    showModalBottomSheet(context: context, builder: (c) => Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: Icon(Icons.my_location), title: Text("موقعي الحالي (يتطلب سماح)"), onTap: () { Navigator.pop(c); _pay(); }),
      ListTile(leading: Icon(Icons.chat), title: Text("إرسال واتساب"), onTap: () { launchUrl(Uri.parse("https://wa.me/966590000000")); _pay(); }),
      ListTile(leading: Icon(Icons.map), title: Text("لصق رابط جوجل ماب"), onTap: () => _manual("رابط الموقع")),
      ListTile(leading: Icon(Icons.edit), title: Text("وصف الموقع يدوياً"), onTap: () => _manual("اكتب الوصف")),
    ]));
  }

  void _manual(String h) {
    showDialog(context: context, builder: (c) => AlertDialog(
      content: TextField(decoration: InputDecoration(hintText: h), maxLines: 2),
      actions: [ElevatedButton(onPressed: () { Navigator.pop(c); _pay(); }, child: Text("تأكيد"))],
    ));
  }

  void _pay() {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("طريقة الدفع"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _pTile("Apple Pay", Colors.black, Icons.apple),
        _pTile("STC Pay", Color(0xFF4F008C), Icons.account_balance_wallet),
        _pTile("تحويل بنكي", Colors.blueGrey, Icons.account_balance),
        Text("\nIBAN: SA9380000001234567890", style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
      ]),
    ));
  }

  Widget _pTile(String t, Color c, IconData i) => GestureDetector(
    onTap: () { HapticFeedback.mediumImpact(); Navigator.pop(context); _up(); },
    child: Card(color: c, child: ListTile(leading: Icon(i, color: Colors.white), title: Text(t, style: TextStyle(color: Colors.white)))),
  );

  void _up() {
    showDialog(context: context, barrierDismissible: false, builder: (c) => AlertDialog(
      title: Text("إثبات الحوالة (إجباري)"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.upload_file, size: 50, color: Colors.amber), Text("يجب رفع صورة الإيصال لإتمام البيع")]),
      actions: [ElevatedButton(onPressed: () { setState(() => cart.clear()); Navigator.pop(c); _pop("نجاح", "تم استلام طلبك، راجع طلباتي"); }, child: Text("رفع الصورة"))],
    ));
  }

  void _pop(String t, String m) => showDialog(context: context, builder: (c) => AlertDialog(title: Text(t), content: Text(m), actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text("حسناً"))]));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black, title: Text(currentCat ?? "متجر SMART للمصاعد"),
        actions: [
          Stack(alignment: Alignment.center, children: [
            IconButton(icon: Icon(Icons.shopping_cart), onPressed: _validateAndOrder),
            if(cart.isNotEmpty) Positioned(top: 5, right: 5, child: CircleAvatar(radius: 8, backgroundColor: Colors.red, child: Text("${cart.length}", style: TextStyle(fontSize: 10))))
          ]),
          IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: currentCat == null ? _grid() : _list(),
    );
  }

  Widget _grid() => GridView.builder(padding: EdgeInsets.all(10), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2), itemCount: cats.length, itemBuilder: (c, i) => Card(color: Color(0xFF1E1E1E), child: InkWell(onTap: () => setState(() => currentCat = cats[i]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.category, color: Colors.amber, size: 40), Text(cats[i], style: TextStyle(color: Colors.white))]))));

  Widget _list() {
    final ps = prods[currentCat] ?? [];
    return ListView.builder(itemCount: ps.length, itemBuilder: (c, i) => ListTile(title: Text(ps[i]['n'], style: TextStyle(color: Colors.white)), subtitle: Text("${ps[i]['p']} ريال", style: TextStyle(color: Colors.amber)), trailing: ElevatedButton(onPressed: () { setState(() => cart.add(ps[i])); HapticFeedback.lightImpact(); }, child: Text("إضافة"))));
  }
}

// --- صفحة طلباتي ---
class OrdersPage extends StatefulWidget { @override _OrdersPageState createState() => _OrdersPageState(); }
class _OrdersPageState extends State<OrdersPage> {
  void _sign(String id) {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("توقيع الاستلام لطلب $id"),
      content: Container(height: 120, width: double.infinity, decoration: BoxDecoration(color: Colors.white10, border: Border.all(color: Colors.white24)), child: Center(child: Text("وقع هنا بالأصبع", style: TextStyle(color: Colors.grey)))),
      actions: [ElevatedButton(onPressed: () { Navigator.pop(c); _msg("تم الاستلام بنجاح!"); }, child: Text("تأكيد"))],
    ));
  }
  void _msg(String m) => showDialog(context: context, builder: (c) => AlertDialog(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(backgroundColor: Colors.black, title: Text("تتبع طلباتي")),
      body: ListView(padding: EdgeInsets.all(15), children: [
        _order("ORD-8812", "وصلت الوجهة", 0.95, "5541", true),
        _order("ORD-1022", "في الطريق", 0.40, "---", false),
      ]),
    );
  }
  Widget _order(String id, String st, double p, String otp, bool sign) => Card(
    color: Color(0xFF1E1E1E), child: Padding(padding: EdgeInsets.all(15), child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(id, style: TextStyle(color: Colors.amber)), Text(st, style: TextStyle(color: Colors.white))]),
      LinearProgressIndicator(value: p, color: Colors.amber),
      SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Text("OTP: $otp", style: TextStyle(color: Colors.white)),
        if(sign) ElevatedButton(onPressed: () => _sign(id), child: Text("توقيع واستلام"))
        else Row(children: [Icon(Icons.call, color: Colors.green), SizedBox(width: 10), Icon(Icons.map, color: Colors.blue)]),
      ])
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
  Widget _list() => ListView(padding: EdgeInsets.all(10), children: [
    Card(color: Color(0xFF1E1E1E), child: ListTile(
      title: Text("فاتورة #8812", style: TextStyle(color: Colors.white)),
      subtitle: Text("المبلغ: 5750 ريال (شامل VAT)", style: TextStyle(color: Colors.amber)),
      trailing: Icon(Icons.picture_as_pdf, color: Colors.red),
    ))
  ]);
}

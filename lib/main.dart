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
  int _index = 3; // البدء بصفحة المتجر مباشرة
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

class ShopPage extends StatefulWidget { @override _ShopPageState createState() => _ShopPageState(); }
class _ShopPageState extends State<ShopPage> {
  List<Map<String, dynamic>> cart = [];
  String? currentCat;
  final List<String> cats = ["قسم المكائن", "قسم الكهرباء", "الميكانيكا", "الأبواب", "الكبائن", "الكنترول", "الاكسسوارات"];
  
  final Map<String, List<Map<String, dynamic>>> products = {
    "قسم المكائن": [{"n": "ماكينة سيكور 5.5 حصان", "p": 4500.0}, {"n": "ماكينة مونتناري", "p": 6200.0}],
    "قسم الكهرباء": [{"n": "انفرتر ياسكاوا 4 كيلو", "p": 1900.0}],
    "الميكانيكا": [{"n": "حبال صلب 10 ملم", "p": 150.0}],
    "الأبواب": [{"n": "باب أتوماتيك تيسن", "p": 3200.0}],
    "الكبائن": [{"n": "كبينة ذهبية ملكي", "p": 15000.0}],
    "الكنترول": [{"n": "كنترول سمارت 4 أدوار", "p": 2800.0}],
    "الاكسسوارات": [{"n": "أزرار استدعاء ذهبية", "p": 85.0}],
  };

  void _addToCart(String name, double price) {
    setState(() => cart.add({'n': name, 'p': price}));
    HapticFeedback.lightImpact();
  }

  void _startCheckout() {
    if (cart.isEmpty) { _msg("السلة فارغة!"); return; }
    _showInstallDialog();
  }

  void _showInstallDialog() {
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
    final name = TextEditingController();
    final phone = TextEditingController();
    showDialog(context: context, barrierDismissible: false, builder: (c) => AlertDialog(
      title: Text("بيانات العميل (إلزامي)"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: InputDecoration(hintText: "الاسم الثلاثي")),
        TextField(controller: phone, keyboardType: TextInputType.phone, decoration: InputDecoration(hintText: "الجوال (05XXXXXXXX)")),
      ]),
      actions: [
        ElevatedButton(onPressed: () {
          if (name.text.isEmpty) return;
          if (phone.text.length == 10 && phone.text.startsWith("05")) { Navigator.pop(c); _locationOptions(); }
          else { _msg("خطأ: الرقم يجب أن يبدأ بـ 05 ويتكون من 10 أرقام"); }
        }, child: Text("التالي"))
      ],
    ));
  }

  void _locationOptions() {
    showModalBottomSheet(context: context, builder: (c) => Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: Icon(Icons.my_location), title: Text("استخدام موقعي الحالي (يطلب إذن)"), onTap: () { Navigator.pop(c); _payment(); }),
      ListTile(leading: Icon(Icons.chat), title: Text("إرسال الموقع واتساب"), onTap: () { launchUrl(Uri.parse("https://wa.me/966590000000")); _payment(); }),
      ListTile(leading: Icon(Icons.map), title: Text("لصق رابط جوجل ماب"), onTap: () => _manualIn("جوجل ماب", "أدخل الرابط هنا")),
      ListTile(leading: Icon(Icons.edit), title: Text("وصف الموقع يدوياً"), onTap: () => _manualIn("وصف الموقع", "اكتب الوصف بالتفصيل")),
    ]));
  }

  void _manualIn(String title, String hint) {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text(title),
      content: TextField(maxLines: 2, decoration: InputDecoration(hintText: hint)),
      actions: [ElevatedButton(onPressed: () { Navigator.pop(c); _payment(); }, child: Text("تأكيد"))],
    ));
  }

  void _payment() {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("طريقة الدفع"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _pBtn("Apple Pay", Colors.black, Icons.apple),
        _pBtn("STC Pay", Color(0xFF4F008C), Icons.account_balance_wallet),
        _pBtn("تحويل بنكي", Colors.blueGrey, Icons.account_balance),
        Text("\nIBAN الشركة: SA9380000001234567890", style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
      ]),
    ));
  }

  Widget _pBtn(String t, Color c, IconData i) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: GestureDetector(
      onTap: () { HapticFeedback.heavyImpact(); Navigator.pop(context); _upload(); },
      child: Card(color: c, child: ListTile(leading: Icon(i, color: Colors.white), title: Text(t, style: TextStyle(color: Colors.white)))),
    ),
  );

  void _upload() {
    showDialog(context: context, barrierDismissible: false, builder: (c) => AlertDialog(
      title: Text("رفع إيصال الحوالة (إجباري)"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.camera_alt, size: 50, color: Colors.amber),
        Text("يجب رفع صورة الإيصال لإتمام الطلب"),
      ]),
      actions: [ElevatedButton(onPressed: () { setState(() => cart.clear()); Navigator.pop(c); _msg("شكراً لك! طلبك الآن تحت المراجعة."); }, child: Text("اختيار صورة ورفع"))],
    ));
  }

  void _msg(String m) => showDialog(context: context, builder: (c) => AlertDialog(content: Text(m), actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text("حسناً"))]));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black, title: Text(currentCat ?? "متجر SMART للمصاعد"),
        leading: currentCat != null ? IconButton(icon: Icon(Icons.arrow_back), onPressed: () => setState(() => currentCat = null)) : null,
        actions: [
          Stack(alignment: Alignment.center, children: [
            IconButton(icon: Icon(Icons.shopping_cart), onPressed: _startCheckout),
            if(cart.isNotEmpty) Positioned(top: 5, right: 5, child: CircleAvatar(radius: 8, backgroundColor: Colors.red, child: Text("${cart.length}", style: TextStyle(fontSize: 10))))
          ]),
          IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: currentCat == null ? _buildGrid() : _buildList(),
    );
  }

  Widget _buildGrid() => GridView.builder(padding: EdgeInsets.all(15), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: cats.length, itemBuilder: (c, i) => Card(color: Color(0xFF1E1E1E), child: InkWell(onTap: () => setState(() => currentCat = cats[i]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.category, color: Colors.amber, size: 40), SizedBox(height: 10), Text(cats[i], style: TextStyle(color: Colors.white, fontSize: 12))]))));

  Widget _buildList() {
    final list = products[currentCat] ?? [];
    return ListView.builder(itemCount: list.length, itemBuilder: (c, i) => ListTile(title: Text(list[i]['n'], style: TextStyle(color: Colors.white)), subtitle: Text("${list[i]['p']} ريال", style: TextStyle(color: Colors.amber)), trailing: ElevatedButton(onPressed: () => _addToCart(list[i]['n'], list[i]['p']), child: Text("إضافة"))));
  }
}

class OrdersPage extends StatefulWidget { @override _OrdersPageState createState() => _OrdersPageState(); }
class _OrdersPageState extends State<OrdersPage> {
  void _sign(String id) {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("توقيع استلام الشحنة"),
      content: Container(height: 150, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[200], border: Border.all(color: Colors.black24)), child: Center(child: Text("وقع هنا بالأصبع", style: TextStyle(color: Colors.black54)))),
      actions: [ElevatedButton(onPressed: () { Navigator.pop(c); _msg("تم الاستلام بنجاح!"); }, child: Text("اعتماد التوقيع"))],
    ));
  }
  void _msg(String m) => showDialog(context: context, builder: (c) => AlertDialog(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(backgroundColor: Colors.black, title: Text("تتبع طلباتي")),
      body: ListView(padding: EdgeInsets.all(15), children: [
        _orderCard("ORD-2026", "وصلت الوجهة", 0.95, "5541", true),
        _orderCard("ORD-1044", "في الطريق (شحن)", 0.55, "---", false),
      ]),
    );
  }

  Widget _orderCard(String id, String st, double p, String otp, bool sign) => Card(
    color: Color(0xFF1E1E1E), margin: EdgeInsets.only(bottom: 15), child: Padding(padding: EdgeInsets.all(15), child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(id, style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)), Text(st, style: TextStyle(color: Colors.white70))]),
      SizedBox(height: 10),
      LinearProgressIndicator(value: p, color: Colors.amber, backgroundColor: Colors.white12),
      SizedBox(height: 15),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Column(children: [Text("OTP", style: TextStyle(color: Colors.grey, fontSize: 10)), Text(otp, style: TextStyle(color: Colors.white))]),
        if(sign) ElevatedButton.icon(onPressed: () => _sign(id), icon: Icon(Icons.edit), label: Text("توقيع واستلام"))
        else Row(children: [Icon(Icons.call, color: Colors.green), SizedBox(width: 5), Text("اتصال", style: TextStyle(color: Colors.white))])
      ])
    ])),
  );
}

class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 2, child: Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(backgroundColor: Colors.black, title: Text("التقارير المالية"), bottom: TabBar(tabs: [Tab(text: "التقارير الجديدة"), Tab(text: "الأرشيف")], indicatorColor: Colors.amber)),
      body: TabBarView(children: [_list(true), _list(false)]),
    ));
  }
  Widget _list(bool isNew) => ListView.builder(itemCount: 2, itemBuilder: (c, i) => Card(color: Color(0xFF1E1E1E), child: ListTile(
    title: Text("فاتورة ضريبية #88$i", style: TextStyle(color: Colors.white)),
    subtitle: Text("التاريخ: 2026/01/21 | الوقت: 07:09 PM", style: TextStyle(color: Colors.grey, fontSize: 10)),
    trailing: Column(children: [Text("5750 ريال", style: TextStyle(color: Colors.amber)), Icon(Icons.picture_as_pdf, color: Colors.red, size: 20)]),
  )));
}

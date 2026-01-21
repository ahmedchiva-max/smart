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
  final _pages = [ShopPage(), OrdersPage(), ReportsPage(), ShopPage(), Center(child: Text("حسابي"))];
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

class ShopPage extends StatefulWidget { @override _ShopPageState createState() => _ShopPageState(); }
class _ShopPageState extends State<ShopPage> {
  List<Map<String, dynamic>> cart = [];
  String? currentCat;
  final cats = ["قسم المكائن", "قسم الكهرباء", "الميكانيكا", "الأبواب", "الكبائن", "الكنترول", "الاكسسوارات"];

  // إظهار بوب اب التحذير
  void _pop(String t, String m) => showDialog(context: context, builder: (c) => AlertDialog(title: Text(t), content: Text(m), actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text("حسناً"))]));

  // خطوة بيانات العميل
  void _userData() {
    final n = TextEditingController();
    final p = TextEditingController();
    showDialog(context: context, barrierDismissible: false, builder: (c) => AlertDialog(
      title: Row(children: [Icon(Icons.person), Text(" بيانات العميل")]),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: n, decoration: InputDecoration(hintText: "الاسم الثلاثي")),
        TextField(controller: p, keyboardType: TextInputType.phone, decoration: InputDecoration(hintText: "الجوال (05XXXXXXXX)")),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: Text("إلغاء", style: TextStyle(color: Colors.red))),
        ElevatedButton(onPressed: () {
          if (n.text.isEmpty || p.text.length != 10 || !p.text.startsWith("05")) {
            _pop("بيانات خاطئة", "يرجى كتابة الاسم وجوال يبدأ بـ 05");
          } else { Navigator.pop(c); _locationChoice(); }
        }, child: Text("التالي")),
      ],
    ));
  }

  // خيارات الموقع
  void _locationChoice() {
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (c) => Container(
      padding: EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text("أين تريد تسليم البضاعة؟", style: TextStyle(fontWeight: FontWeight.bold)),
        ListTile(leading: Icon(Icons.my_location, color: Colors.blue), title: Text("موقعي الحالي (إرسال الإحداثيات)"), onTap: () { Navigator.pop(c); _payment(); }),
        ListTile(leading: Icon(Icons.chat, color: Colors.green), title: Text("إرسال عبر واتساب"), onTap: () { launchUrl(Uri.parse("https://wa.me/966590000000")); Navigator.pop(c); _payment(); }),
        ListTile(leading: Icon(Icons.edit, color: Colors.orange), title: Text("وصف الموقع يدوياً"), onTap: () { Navigator.pop(c); _manualInput("وصف الموقع يدوياً"); }),
        ListTile(leading: Icon(Icons.map, color: Colors.red), title: Text("لصق رابط جوجل ماب"), onTap: () { Navigator.pop(c); _manualInput("رابط جوجل ماب"); }),
      ]),
    ));
  }

  void _manualInput(String type) {
    final input = TextEditingController();
    showDialog(context: context, barrierDismissible: false, builder: (c) => AlertDialog(
      title: Text("أدخل $type"),
      content: TextField(controller: input, maxLines: 3, decoration: InputDecoration(hintText: "اكتب هنا...")),
      actions: [
        ElevatedButton(onPressed: () {
          if (input.text.trim().isEmpty) { _pop("تنبيه", "يجب كتابة $type أولاً"); }
          else { Navigator.pop(c); _payment(); }
        }, child: Text("تأكيد ومتابعة"))
      ],
    ));
  }

  // بوابة الدفع (تم إصلاح الضغط)
  void _payment() {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("اختر طريقة الدفع"),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _payBtn("Apple Pay", Colors.black, Icons.apple, c),
          _payBtn("مدى / Mada", Colors.blue, Icons.credit_card, c),
          _payBtn("STC Pay", Color(0xFF4F008C), Icons.account_balance_wallet, c),
          _payBtn("تحويل بنكي", Colors.grey, Icons.account_balance, c),
          SizedBox(height: 10),
          Text("IBAN: SA9380000001234567890", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber)),
        ]),
      ),
    ));
  }

  Widget _payBtn(String t, Color c, IconData i, BuildContext ctx) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: InkWell(
      onTap: () { HapticFeedback.heavyImpact(); Navigator.pop(ctx); _uploadReceipt(); },
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(10)),
        child: Row(children: [Icon(i, color: Colors.white), SizedBox(width: 15), Text(t, style: TextStyle(color: Colors.white))]),
      ),
    ),
  );

  void _uploadReceipt() {
    showDialog(context: context, barrierDismissible: false, builder: (c) => AlertDialog(
      title: Text("إرفاق إيصال الدفع"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.cloud_upload, size: 50), Text("يجب رفع صورة الحوالة لإتمام الطلب")]),
      actions: [ElevatedButton(onPressed: () { setState(() => cart.clear()); Navigator.pop(c); _pop("تم بنجاح", "تم استلام طلبك وإرسال الفاتورة للتقارير"); }, child: Text("رفع الصورة وإتمام الشراء"))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: currentCat != null ? IconButton(icon: Icon(Icons.arrow_back, color: Colors.amber), onPressed: () => setState(() => currentCat = null)) : Icon(Icons.home, color: Colors.amber),
        title: Text(currentCat ?? "متجر المصاعد ذكي"),
        actions: [
          IconButton(icon: Icon(Icons.shopping_cart, color: Colors.white), onPressed: _userData),
          IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: () => SystemNavigator.pop()),
        ],
      ),
      body: currentCat == null ? _gridCats() : _listProds(),
    );
  }

  Widget _gridCats() => GridView.builder(padding: EdgeInsets.all(15), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: cats.length, itemBuilder: (c, i) => InkWell(onTap: () => setState(() => currentCat = cats[i]), child: Card(color: Color(0xFF1E1E1E), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.settings, color: Colors.amber, size: 40), Text(cats[i], style: TextStyle(color: Colors.white))]))));

  Widget _listProds() => ListView(children: [ListTile(title: Text("منتج تجريبي من $currentCat", style: TextStyle(color: Colors.white)), trailing: ElevatedButton(onPressed: () => setState(() => cart.add({})), child: Text("إضافة للسلة")))]);
}

// --- الصفحات الأخرى كقوالب ---
class OrdersPage extends StatelessWidget { @override Widget build(BuildContext context) => Scaffold(backgroundColor: Color(0xFF121212), appBar: AppBar(title: Text("طلباتي"), backgroundColor: Colors.black)); }
class ReportsPage extends StatelessWidget { @override Widget build(BuildContext context) => Scaffold(backgroundColor: Color(0xFF121212), appBar: AppBar(title: Text("التقارير"), backgroundColor: Colors.black)); }

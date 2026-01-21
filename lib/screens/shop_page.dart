import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class Product {
  final String name;
  final double price;
  final String category;
  Product({required this.name, required this.price, required this.category});
}

class ShopPage extends StatefulWidget {
  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  List<Product> cart = [];
  String? selectedCategory;
  bool isReceiptUploaded = false;

  final List<Product> allProducts = [
    Product(name: "ماكينة سيكور 5.5 حصان", price: 4500, category: "قسم المكائن"),
    Product(name: "ماكينة مونتناري إيطالي", price: 6200, category: "قسم المكائن"),
    Product(name: "انفرتر ياسكاوا 4 كيلو", price: 1900, category: "قسم الكهرباء"),
    Product(name: "كنترول سمارت 4 أدوار", price: 2800, category: "الكنترول"),
    Product(name: "حبال صلب 10 ملم", price: 150, category: "الميكانيكا"),
    Product(name: "باب أتوماتيك تيسن", price: 3200, category: "الأبواب"),
    Product(name: "كبينة ذهبية ملكي", price: 15000, category: "الكبائن"),
    Product(name: "أزرار استدعاء ذهبية", price: 85, category: "الاكسسوارات"),
  ];

  void _showCheckout() {
    if (cart.isEmpty) { _msg("السلة فارغة! اختر بضاعة أولاً."); return; }
    _askInstall();
  }

  void _askInstall() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text("خيار التنفيذ"),
      content: Text("هل الشراء للقطعة فقط أم مع التركيب؟"),
      actions: [
        ElevatedButton(onPressed: () { Navigator.pop(ctx); _askUser(); }, child: Text("قطعة فقط")),
        ElevatedButton(onPressed: () { Navigator.pop(ctx); _askUser(); }, child: Text("مع التركيب")),
      ],
    ));
  }

  void _askUser() {
    final n = TextEditingController();
    final p = TextEditingController();
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
      title: Text("بيانات العميل"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: n, decoration: InputDecoration(hintText: "الاسم الكامل")),
        TextField(controller: p, keyboardType: TextInputType.phone, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)], decoration: InputDecoration(hintText: "الجوال (05XXXXXXXX)")),
      ]),
      actions: [
        TextButton(onPressed: () {
          if (n.text.isEmpty) { _msg("الاسم إجباري"); return; }
          if (p.text.length == 10 && p.text.startsWith("05")) { Navigator.pop(ctx); _askLoc(); }
          else { _msg("خطأ: الرقم 10 أرقام ويبدأ بـ 05"); }
        }, child: Text("حسناً"))
      ],
    ));
  }

  void _askLoc() {
    showModalBottomSheet(context: context, builder: (ctx) => Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: Icon(Icons.my_location), title: Text("موقعي الحالي (طلب إذن)"), onTap: () { Navigator.pop(ctx); _msg("تم تحديد موقعك"); _showPay(); }),
      ListTile(leading: Icon(Icons.chat), title: Text("إرسال عبر واتساب"), onTap: () { launchUrl(Uri.parse("https://wa.me/966590000000")); _showPay(); }),
      ListTile(leading: Icon(Icons.map), title: Text("لصق رابط جوجل ماب"), onTap: () => _inputBox("الصق الرابط")),
      ListTile(leading: Icon(Icons.description), title: Text("وصف الموقع يدوياً"), onTap: () => _inputBox("اكتب الوصف")),
    ]));
  }

  void _inputBox(String h) {
    final c = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      content: TextField(controller: c, decoration: InputDecoration(hintText: h)),
      actions: [ElevatedButton(onPressed: () { Navigator.pop(ctx); _showPay(); }, child: Text("تأكيد"))],
    ));
  }

  void _showPay() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text("طرق الدفع المعتمدة"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _pCard("Apple Pay", Colors.black, Icons.apple),
        _pCard("STC Pay", Color(0xFF4F008C), Icons.account_balance_wallet),
        _pCard("تحويل بنكي", Colors.blueGrey, Icons.account_balance),
        Text("\nIBAN: SA9380000001234567890", style: TextStyle(color: Colors.amber, fontSize: 10)),
      ]),
      actions: [ElevatedButton(onPressed: () => _upRec(), child: Text("رفع الإيصال (إجباري)"))],
    ));
  }

  Widget _pCard(String t, Color c, IconData i) => InkWell(onTap: () => HapticFeedback.vibrate(), child: Card(color: c, child: ListTile(leading: Icon(i, color: Colors.white), title: Text(t, style: TextStyle(color: Colors.white)))));

  void _upRec() {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
      title: Text("إثبات الحوالة"),
      content: Text("يجب اختيار صورة الإيصال لإتمام العملية"),
      actions: [ElevatedButton(onPressed: () { setState(() { isReceiptUploaded = true; cart.clear(); }); Navigator.pop(ctx); _msg("تم بنجاح! راجع طلباتي"); }, child: Text("اختيار صورة"))],
    ));
  }

  void _msg(String m) => showDialog(context: context, builder: (c) => AlertDialog(content: Text(m), actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text("حسناً"))]));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Text(selectedCategory ?? "متجر SMART"),
        actions: [
          Stack(alignment: Alignment.center, children: [
            IconButton(icon: Icon(Icons.shopping_cart), onPressed: _showCheckout),
            if(cart.isNotEmpty) Positioned(top: 5, right: 5, child: CircleAvatar(radius: 8, backgroundColor: Colors.red, child: Text("${cart.length}", style: TextStyle(fontSize: 10))))
          ]),
          IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: selectedCategory == null ? _grid() : _list(),
      floatingActionButton: selectedCategory != null ? FloatingActionButton(onPressed: () => setState(() => selectedCategory = null), child: Icon(Icons.home)) : null,
    );
  }

  Widget _grid() {
    final cats = [{'n': 'قسم المكائن', 'i': Icons.settings}, {'n': 'قسم الكهرباء', 'i': Icons.flash_on}, {'n': 'الميكانيكا', 'i': Icons.build}, {'n': 'الأبواب', 'i': Icons.sensor_door}, {'n': 'الكبائن', 'i': Icons.view_quilt}, {'n': 'الكنترول', 'i': Icons.developer_board}, {'n': 'الاكسسوارات', 'i': Icons.stars}];
    return GridView.builder(padding: EdgeInsets.all(10), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2), itemCount: cats.length, itemBuilder: (ctx, i) => Card(color: Color(0xFF222222), child: InkWell(onTap: () => setState(() => selectedCategory = cats[i]['n'] as String), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(cats[i]['i'] as IconData, color: Colors.amber, size: 40), Text(cats[i]['n'] as String, style: TextStyle(color: Colors.white))]))));
  }

  Widget _list() {
    final ps = allProducts.where((p) => p.category == selectedCategory).toList();
    return ListView.builder(itemCount: ps.length, itemBuilder: (ctx, i) => ListTile(title: Text(ps[i].name, style: TextStyle(color: Colors.white)), subtitle: Text("${ps[i].price} ريال", style: TextStyle(color: Colors.amber)), trailing: ElevatedButton(onPressed: () { setState(() => cart.add(ps[i])); HapticFeedback.mediumImpact(); }, child: Text("إضافة"))));
  }
}

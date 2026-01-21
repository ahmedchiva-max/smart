import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopPage extends StatefulWidget {
  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  List<Map<String, dynamic>> cart = [];
  String? selectedCategory;
  bool isReceiptUploaded = false;

  final List<Map<String, dynamic>> products = [
    {'n': 'ماكينة سيكور 5.5 حصان', 'p': 4500, 'c': 'قسم المكائن'},
    {'n': 'انفرتر ياسكاوا 4 كيلو', 'p': 1900, 'c': 'قسم الكهرباء'},
    {'n': 'كنترول سمارت 4 أدوار', 'p': 2800, 'c': 'الكنترول'},
    {'n': 'باب أتوماتيك تيسن', 'p': 3200, 'c': 'الأبواب'},
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
          else { _msg("خطأ: الرقم يجب أن يبدأ بـ 05 ويتكون من 10 أرقام"); }
        }, child: Text("حسناً"))
      ],
    ));
  }

  void _askLoc() {
    showModalBottomSheet(context: context, builder: (ctx) => Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: Icon(Icons.my_location), title: Text("موقعي الحالي"), onTap: () { Navigator.pop(ctx); _showPay(); }),
      ListTile(leading: Icon(Icons.chat), title: Text("واتساب"), onTap: () { launchUrl(Uri.parse("https://wa.me/966590000000")); _showPay(); }),
      ListTile(leading: Icon(Icons.map), title: Text("جوجل ماب"), onTap: () => _inputBox("الصق الرابط")),
      ListTile(leading: Icon(Icons.edit), title: Text("وصف يدوي"), onTap: () => _inputBox("اكتب الوصف")),
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
      title: Text("اختر طريقة الدفع"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _payItem("Apple Pay", Colors.black, Icons.apple),
        _payItem("STC Pay", Color(0xFF4F008C), Icons.account_balance_wallet),
        _payItem("تحويل بنكي", Colors.blueGrey, Icons.account_balance),
        Text("\nIBAN: SA9380000001234567890", style: TextStyle(color: Colors.amber, fontSize: 10)),
      ]),
    ));
  }

  Widget _payItem(String t, Color c, IconData i) {
    return GestureDetector(
      onTap: () { HapticFeedback.heavyImpact(); Navigator.pop(context); _upRec(); },
      child: Card(color: c, child: ListTile(leading: Icon(i, color: Colors.white), title: Text(t, style: TextStyle(color: Colors.white)))),
    );
  }

  void _upRec() {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
      title: Text("إثبات الحوالة (إجباري)"),
      content: Text("يرجى رفع صورة الإيصال لإتمام البيع"),
      actions: [ElevatedButton(onPressed: () { setState(() { isReceiptUploaded = true; cart.clear(); }); Navigator.pop(ctx); _msg("تم الطلب! راجع قسم طلباتي"); }, child: Text("رفع الصورة"))],
    ));
  }

  void _msg(String m) => showDialog(context: context, builder: (c) => AlertDialog(content: Text(m), actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text("حسناً"))]));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(selectedCategory ?? "المتجر"),
        actions: [
          Stack(alignment: Alignment.center, children: [
            IconButton(icon: Icon(Icons.shopping_cart), onPressed: _showCheckout),
            if(cart.isNotEmpty) Positioned(top: 5, right: 5, child: CircleAvatar(radius: 8, backgroundColor: Colors.red, child: Text("${cart.length}", style: TextStyle(fontSize: 10))))
          ]),
        ],
      ),
      body: selectedCategory == null ? _grid() : _list(),
    );
  }

  Widget _grid() {
    final cats = [{'n': 'قسم المكائن', 'i': Icons.settings}, {'n': 'قسم الكهرباء', 'i': Icons.flash_on}, {'n': 'الكنترول', 'i': Icons.developer_board}];
    return GridView.builder(padding: EdgeInsets.all(10), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2), itemCount: cats.length, itemBuilder: (ctx, i) => Card(color: Color(0xFF222222), child: InkWell(onTap: () => setState(() => selectedCategory = cats[i]['n'] as String), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(cats[i]['i'] as IconData, color: Colors.amber, size: 40), Text(cats[i]['n'] as String, style: TextStyle(color: Colors.white))]))));
  }

  Widget _list() {
    final ps = products.where((p) => p['c'] == selectedCategory).toList();
    return ListView.builder(itemCount: ps.length, itemBuilder: (ctx, i) => ListTile(title: Text(ps[i]['n'], style: TextStyle(color: Colors.white)), trailing: ElevatedButton(onPressed: () => setState(() => cart.add(ps[i])), child: Text("إضافة"))));
  }
}

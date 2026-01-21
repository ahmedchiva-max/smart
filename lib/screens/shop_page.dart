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
  String? orderType; // قطعة فقط أم تركيب

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

  void _showCheckoutFlow() {
    if (cart.isEmpty) { _showPopup("السلة فارغة! أضف بضاعة أولاً."); return; }
    _askInstall();
  }

  void _askInstall() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text("خيار التنفيذ"),
      content: Text("هل ترغب في شراء القطعة فقط أم مع التركيب؟"),
      actions: [
        ElevatedButton(onPressed: () { orderType = "قطعة فقط"; Navigator.pop(ctx); _askUserInfo(); }, child: Text("قطعة فقط")),
        ElevatedButton(onPressed: () { orderType = "مع التركيب"; Navigator.pop(ctx); _askUserInfo(); }, child: Text("مع التركيب")),
      ],
    ));
  }

  void _askUserInfo() {
    final nCtrl = TextEditingController();
    final pCtrl = TextEditingController();
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
      title: Text("بيانات العميل (إجباري)"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nCtrl, decoration: InputDecoration(hintText: "الاسم الكامل")),
        TextField(
          controller: pCtrl, 
          keyboardType: TextInputType.phone, 
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)], 
          decoration: InputDecoration(hintText: "رقم الجوال (05XXXXXXXX)")),
      ]),
      actions: [
        TextButton(onPressed: () {
          if (nCtrl.text.isEmpty) { _showPopup("الاسم إجباري"); return; }
          if (pCtrl.text.length == 10 && pCtrl.text.startsWith("05")) { Navigator.pop(ctx); _showLocation(); }
          else { _showPopup("الرقم يجب أن يكون 10 أرقام ويبدأ بـ 05"); }
        }, child: Text("حسناً"))
      ],
    ));
  }

  void _showLocation() {
    showModalBottomSheet(context: context, builder: (ctx) => Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: Icon(Icons.my_location), title: Text("استخدام موقعي الحالي"), onTap: () { Navigator.pop(ctx); _showPopup("تم طلب الإذن وتحديد الموقع بنجاح"); _showPayment(); }),
      ListTile(leading: Icon(Icons.chat), title: Text("إرسال عبر الواتساب"), onTap: () { launchUrl(Uri.parse("https://wa.me/966590000000")); _showPayment(); }),
      ListTile(leading: Icon(Icons.map), title: Text("لصق رابط جوجل ماب"), onTap: () => _openInput("الصق رابط جوجل ماب هنا")),
      ListTile(leading: Icon(Icons.edit), title: Text("وصف الموقع يدوياً"), onTap: () => _openInput("اكتب وصف الموقع بالتفصيل")),
    ]));
  }

  void _openInput(String hint) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      content: TextField(controller: ctrl, decoration: InputDecoration(hintText: hint)),
      actions: [ElevatedButton(onPressed: () { Navigator.pop(ctx); _showPayment(); }, child: Text("تأكيد"))],
    ));
  }

  void _showPayment() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text("طريقة الدفع"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _payTile("Apple Pay", Colors.black, Icons.apple),
        _payTile("STC Pay", Color(0xFF4F008C), Icons.payment),
        _payTile("تحويل بنكي", Colors.blueGrey, Icons.account_balance, iban: "SA10000000000000000000"),
      ]),
      actions: [
        ElevatedButton(onPressed: () => _showUploadReceipt(), child: Text("رفع الإيصال (إجباري)")),
      ],
    ));
  }

  Widget _payTile(String t, Color c, IconData i, {String? iban}) => InkWell(
    onTap: () => HapticFeedback.heavyImpact(),
    child: Card(color: c, child: ListTile(
      leading: Icon(i, color: Colors.white),
      title: Text(t, style: TextStyle(color: Colors.white)),
      subtitle: iban != null ? Text("IBAN: $iban", style: TextStyle(color: Colors.white, fontSize: 10)) : null,
    )),
  );

  void _showUploadReceipt() {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
      title: Text("رفع إيصال الحوالة"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.cloud_upload, size: 50, color: Colors.amber),
        Text("يجب رفع صورة الحوالة لإتمام البيع"),
        SizedBox(height: 10),
        ElevatedButton(onPressed: () { 
          setState(() => isReceiptUploaded = true); 
          Navigator.pop(ctx);
          _finish();
        }, child: Text("اختيار صورة الإيصال")),
      ]),
    ));
  }

  void _finish() {
    if (!isReceiptUploaded) return;
    _showPopup("تم استلام الطلب! رمز التحقق OTP الخاص بك هو 7741. تتبع طلبك من قسم 'طلباتي'.");
    setState(() { cart.clear(); isReceiptUploaded = false; });
  }

  void _showPopup(String m) {
    showDialog(context: context, builder: (ctx) => AlertDialog(content: Text(m), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text("حسناً"))]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Text(selectedCategory ?? "متجر SMART", style: TextStyle(color: Colors.amber)),
        actions: [
          Stack(alignment: Alignment.center, children: [
            IconButton(icon: Icon(Icons.shopping_cart), onPressed: _showCheckoutFlow),
            if(cart.isNotEmpty) Positioned(top: 8, right: 8, child: CircleAvatar(radius: 8, backgroundColor: Colors.red, child: Text("${cart.length}", style: TextStyle(fontSize: 10, color: Colors.white)))),
          ]),
          IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: selectedCategory == null ? _buildCats() : _buildProds(),
      floatingActionButton: selectedCategory != null ? FloatingActionButton(onPressed: () => setState(() => selectedCategory = null), child: Icon(Icons.home), backgroundColor: Colors.amber) : null,
    );
  }

  Widget _buildCats() {
    final categories = [
      {'n': 'قسم المكائن', 'i': Icons.settings},
      {'n': 'قسم الكهرباء', 'i': Icons.flash_on},
      {'n': 'الميكانيكا', 'i': Icons.build},
      {'n': 'الأبواب', 'i': Icons.sensor_door},
      {'n': 'الكبائن', 'i': Icons.view_quilt},
      {'n': 'الكنترول', 'i': Icons.developer_board},
      {'n': 'الاكسسوارات', 'i': Icons.stars},
    ];
    return GridView.builder(
      padding: EdgeInsets.all(15),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: categories.length,
      itemBuilder: (ctx, i) => Card(
        color: Color(0xFF333333),
        child: InkWell(
          onTap: () => setState(() => selectedCategory = categories[i]['n'] as String),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(categories[i]['i'] as IconData, color: Colors.amber, size: 40),
            Text(categories[i]['n'] as String, style: TextStyle(color: Colors.white)),
          ]),
        ),
      ),
    );
  }

  Widget _buildProds() {
    final prods = allProducts.where((p) => p.category == selectedCategory).toList();
    return ListView.builder(
      itemCount: prods.length,
      itemBuilder: (ctx, i) => ListTile(
        title: Text(prods[i].name, style: TextStyle(color: Colors.white)),
        subtitle: Text("${prods[i].price} ريال", style: TextStyle(color: Colors.amber)),
        trailing: ElevatedButton(onPressed: () { setState(() => cart.add(prods[i])); HapticFeedback.lightImpact(); }, child: Text("إضافة للسلة")),
      ),
    );
  }
}

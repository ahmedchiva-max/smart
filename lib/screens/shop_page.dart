import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart'; // للربط مع الواتساب

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
  
  // البضاعة التفصيلية لكل قسم
  final List<Product> allProducts = [
    Product(name: "ماكينة سيكور 5.5 حصان", price: 4500, category: "قسم المكائن"),
    Product(name: "ماكينة مونتناري إيطالي", price: 6200, category: "قسم المكائن"),
    Product(name: "انفرتر ياسكاوا 4 كيلو", price: 1900, category: "قسم الكهرباء"),
    Product(name: "كنترول سمارت 4 أدوار", price: 2800, category: "الكنترول"),
    Product(name: "حبال صلب 10 ملم", price: 150, category: "الميكانيكا"),
    Product(name: "باب أتوماتيك تيسن", price: 3200, category: "الأبواب"),
    Product(name: "كبينة ذهبية مودرن", price: 12000, category: "الكبائن"),
    Product(name: "أزرار استدعاء ذهبية", price: 85, category: "الاكسسوارات"),
  ];

  final List<Map<String, dynamic>> categories = [
    {'name': 'قسم المكائن', 'icon': Icons.settings},
    {'name': 'قسم الكهرباء', 'icon': Icons.flash_on},
    {'name': 'الميكانيكا', 'icon': Icons.build},
    {'name': 'الأبواب', 'icon': Icons.sensor_door},
    {'name': 'الكبائن', 'icon': Icons.view_quilt},
    {'name': 'الكنترول', 'icon': Icons.developer_board},
    {'name': 'الاكسسوارات', 'icon': Icons.stars},
  ];

  // دالة بدء عملية الشراء
  void _startCheckout() {
    if (cart.isEmpty) { _showPopup("السلة فارغة! أضف بضاعة أولاً."); return; }
    _showInstallOption();
  }

  // 1. خيار التركيب
  void _showInstallOption() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text("خيار التنفيذ"),
      content: Text("هل تريد شراء القطع فقط أم مع التركيب؟"),
      actions: [
        ElevatedButton(onPressed: () { Navigator.pop(ctx); _askNameAndPhone(); }, child: Text("قطعة فقط")),
        ElevatedButton(onPressed: () { Navigator.pop(ctx); _askNameAndPhone(); }, child: Text("مع التركيب")),
      ],
    ));
  }

  // 2. الاسم ورقم الجوال (تحقق 10 أرقام و 05)
  void _askNameAndPhone() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
      title: Text("بيانات العميل"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: InputDecoration(hintText: "الاسم الكامل (إجباري)")),
        TextField(
          controller: phoneCtrl,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
          decoration: InputDecoration(hintText: "رقم الجوال (05XXXXXXXX)"),
        ),
      ]),
      actions: [
        TextButton(onPressed: () {
          if (nameCtrl.text.isEmpty) { _showPopup("الاسم حقل إجباري"); return; }
          if (phoneCtrl.text.length == 10 && phoneCtrl.text.startsWith("05")) {
            Navigator.pop(ctx); _showLocationOptions();
          } else {
            _showPopup("خطأ: رقم الجوال يجب أن يكون 10 أرقام ويبدأ بـ 05");
          }
        }, child: Text("حسناً"))
      ],
    ));
  }

  // 3. خيارات الموقع التفصيلية
  void _showLocationOptions() {
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text("تحديد الموقع", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ListTile(leading: Icon(Icons.my_location), title: Text("استخدام موقعي الحالي"), onTap: () => _askPermissionAndContinue()),
        ListTile(leading: Icon(Icons.chat), title: Text("إرسال عبر الواتساب"), onTap: () => _launchWhatsApp()),
        ListTile(leading: Icon(Icons.map), title: Text("لصق رابط جوجل ماب"), onTap: () => _openTextField("الصق الرابط هنا")),
        ListTile(leading: Icon(Icons.edit_note), title: Text("وصف الموقع يدوياً"), onTap: () => _openTextField("اكتب وصف العنوان بالتفصيل")),
        SizedBox(height: 20),
      ]),
    ));
  }

  void _askPermissionAndContinue() {
    _showPopup("تم طلب الإذن.. تم تحديد موقعك الحالي بنجاح.");
    _showPaymentFlow();
  }

  void _launchWhatsApp() async {
    var url = "https://wa.me/96659XXXXXXX?text=موقعي للطلب هو: ";
    await launchUrl(Uri.parse(url));
    _showPaymentFlow();
  }

  void _openTextField(String hint) {
    Navigator.pop(context);
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      content: TextField(controller: ctrl, maxLines: 3, decoration: InputDecoration(hintText: hint)),
      actions: [ElevatedButton(onPressed: () { Navigator.pop(ctx); _showPaymentFlow(); }, child: Text("تأكيد"))],
    ));
  }

  // 4. الدفع الواقعي ورفع الإيصال
  void _showPaymentFlow() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text("طريقة الدفع"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _payTile("Apple Pay", Colors.black, Icons.apple),
        _payTile("STC Pay", Color(0xFF4F008C), Icons.payment),
        _payTile("تحويل بنكي (IBAN الشركة)", Colors.blueGrey, Icons.account_balance),
      ]),
      actions: [ElevatedButton(onPressed: () => _uploadReceipt(), child: Text("رفع صورة الحوالة (إجباري)"))],
    ));
  }

  Widget _payTile(String t, Color c, IconData i) => InkWell(
    onTap: () { HapticFeedback.vibrate(); },
    child: Card(color: c, child: ListTile(leading: Icon(i, color: Colors.white), title: Text(t, style: TextStyle(color: Colors.white)))),
  );

  void _uploadReceipt() {
    _showPopup("تم رفع الإيصال بنجاح. الطلب الآن في قسم التقارير.");
    setState(() => cart.clear());
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
        title: Text(selectedCategory ?? "المتجر"),
        actions: [
          Stack(alignment: Alignment.center, children: [
            IconButton(icon: Icon(Icons.shopping_cart), onPressed: _startCheckout),
            if(cart.isNotEmpty) Positioned(top: 5, right: 5, child: CircleAvatar(radius: 8, backgroundColor: Colors.red, child: Text("${cart.length}", style: TextStyle(fontSize: 10))))
          ]),
          IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: selectedCategory == null ? _buildCats() : _buildProds(),
      floatingActionButton: selectedCategory != null ? FloatingActionButton(onPressed: () => setState(() => selectedCategory = null), child: Icon(Icons.home)) : null,
    );
  }

  Widget _buildCats() {
    return GridView.builder(
      padding: EdgeInsets.all(15),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: categories.length,
      itemBuilder: (ctx, i) => Card(
        color: Color(0xFF333333),
        child: InkWell(
          onTap: () => setState(() => selectedCategory = categories[i]['name']),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(categories[i]['icon'], color: Colors.amber, size: 40),
            Text(categories[i]['name'], style: TextStyle(color: Colors.white)),
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
        trailing: ElevatedButton(onPressed: () { setState(() => cart.add(prods[i])); HapticFeedback.lightImpact(); }, child: Text("إضافة")),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  
  // قاعدة بيانات البضاعة لكل قسم
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

  // دالة إتمام الشراء
  void _startCheckout() {
    if (cart.isEmpty) { _showPopup("السلة فارغة! أضف بضاعة أولاً."); return; }
    _showInstallDialog();
  }

  // 1. خيار التركيب
  void _showInstallDialog() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: Color(0xFF222222),
      title: Text("خيار التنفيذ", style: TextStyle(color: Colors.white)),
      content: Text("هل ترغب في شراء القطع فقط أم مع التركيب؟", style: TextStyle(color: Colors.grey)),
      actions: [
        ElevatedButton(onPressed: () { Navigator.pop(ctx); _askDetails(); }, child: Text("قطعة فقط")),
        ElevatedButton(onPressed: () { Navigator.pop(ctx); _askDetails(); }, child: Text("شراء مع تركيب")),
      ],
    ));
  }

  // 2. الاسم ورقم الجوال (تحقق إجباري)
  void _askDetails() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
      backgroundColor: Color(0xFF222222),
      title: Text("بيانات العميل", style: TextStyle(color: Colors.amber)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "الاسم الكامل", hintStyle: TextStyle(color: Colors.grey))),
        SizedBox(height: 10),
        TextField(
          controller: phoneCtrl,
          style: TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
          decoration: InputDecoration(hintText: "رقم الجوال (05XXXXXXXX)", hintStyle: TextStyle(color: Colors.grey)),
        ),
      ]),
      actions: [
        TextButton(onPressed: () {
          if (nameCtrl.text.isEmpty) { _showPopup("الاسم حقل إجباري"); return; }
          String p = phoneCtrl.text;
          if (p.length == 10 && p.startsWith("05")) {
            Navigator.pop(ctx); _askLocation();
          } else {
            _showPopup("خطأ: يجب إدخال 10 أرقام تبدأ بـ 05");
          }
        }, child: Text("حسناً", style: TextStyle(color: Colors.amber)))
      ],
    ));
  }

  // 3. الموقع
  void _askLocation() {
    showModalBottomSheet(context: context, backgroundColor: Color(0xFF1A1A1A), builder: (ctx) => Container(
      padding: EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text("تحديد موقع التسليم", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
        _locationTile("موقعي الحالي", Icons.my_location),
        _locationTile("إرسال عبر الواتساب", Icons.chat),
        _locationTile("لصق رابط جوجل ماب", Icons.map),
        _locationTile("وصف الموقع يدوياً", Icons.edit_location),
      ]),
    ));
  }

  Widget _locationTile(String t, IconData i) => ListTile(
    leading: Icon(i, color: Colors.white),
    title: Text(t, style: TextStyle(color: Colors.white)),
    onTap: () { Navigator.pop(context); _showPayment(); },
  );

  // 4. طرق الدفع (أيقونات واقعية وشعور الضغطة)
  void _showPayment() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: Color(0xFF222222),
      title: Text("طريقة الدفع", style: TextStyle(color: Colors.white)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _payCard("Apple Pay", Colors.black, Icons.apple, ""),
        _payCard("STC Pay", Color(0xFF4F008C), Icons.account_balance_wallet, ""),
        _payCard("تحويل بنكي", Colors.blueGrey, Icons.account_balance, "SA12345678901234567890"),
      ]),
      actions: [ElevatedButton(onPressed: () => _uploadReceipt(), child: Text("التالي"))],
    ));
  }

  Widget _payCard(String t, Color c, IconData i, String iban) {
    return InkWell(
      onTap: () { HapticFeedback.mediumImpact(); }, // شعور الضغطة
      child: Card(
        color: c,
        child: ListTile(
          leading: Icon(i, color: Colors.white, size: 30),
          title: Text(t, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: iban.isNotEmpty ? Text("IBAN: $iban", style: TextStyle(color: Colors.amber, fontSize: 9)) : null,
        ),
      ),
    );
  }

  // 5. رفع الإيصال (إجباري)
  void _uploadReceipt() {
    Navigator.pop(context);
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
      title: Text("رفع إيصال التحويل"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.upload_file, size: 50, color: Colors.amber),
        Text("يجب رفع صورة الحوالة لإتمام البيع"),
        SizedBox(height: 10),
        ElevatedButton(onPressed: () { _finish(); Navigator.pop(ctx); }, child: Text("اختيار صورة الإيصال")),
      ]),
    ));
  }

  void _finish() {
    setState(() => cart.clear());
    _showPopup("تم استلام طلبك! يمكنك التتبع من قسم طلباتي باستخدام الـ OTP المرسل لجوالك.");
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
          IconButton(icon: Icon(Icons.shopping_cart), onPressed: _startCheckout),
          IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: selectedCategory == null ? _buildCats() : _buildProds(),
      floatingActionButton: selectedCategory != null ? FloatingActionButton(onPressed: () => setState(() => selectedCategory = null), child: Icon(Icons.home), backgroundColor: Colors.amber) : null,
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
          child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
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

import 'package:flutter/material.dart';

// نموذج للمنتج
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
  
  // بيانات البضاعة
  final List<Product> allProducts = [
    Product(name: "ماكينة سيكور 5.5 حصان", price: 4500, category: "قسم المكائن"),
    Product(name: "ماكينة مونتناري إيطالي", price: 6200, category: "قسم المكائن"),
    Product(name: "كنترول سمارت 4 أدوار", price: 2800, category: "الكنترول"),
    Product(name: "حبال صلب 10 ملم", price: 150, category: "الميكانيكا"),
    Product(name: "باب أتوماتيك تيسن", price: 3200, category: "الأبواب"),
    Product(name: "أزرار استدعاء ذهبية", price: 85, category: "الاكسسوارات"),
    Product(name: "انفرتر ياسكاوا 4 كيلو", price: 1900, category: "قسم الكهرباء"),
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

  void _showCheckoutFlow() {
    if (cart.isEmpty) {
      _showPopup("السلة فارغة! أضف بضاعة أولاً.");
      return;
    }
    _askInstallOption();
  }

  // 1. خيار التركيب
  void _askInstallOption() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text("خيار التنفيذ"),
      content: Text("هل تريد شراء القطع فقط أم مع التركيب؟"),
      actions: [
        ElevatedButton(onPressed: () { Navigator.pop(ctx); _askUserDetails(); }, child: Text("قطعة فقط")),
        ElevatedButton(onPressed: () { Navigator.pop(ctx); _askUserDetails(); }, child: Text("مع التركيب")),
      ],
    ));
  }

  // 2. الاسم ورقم الجوال
  void _askUserDetails() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
      title: Text("بيانات العميل"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: InputDecoration(hintText: "الاسم الكامل")),
        TextField(controller: phoneCtrl, decoration: InputDecoration(hintText: "رقم الجوال (05XXXXXXXX)"), keyboardType: TextInputType.phone),
      ]),
      actions: [
        TextButton(onPressed: () {
          if (nameCtrl.text.isEmpty) { _showPopup("يرجى كتابة الاسم"); return; }
          if (phoneCtrl.text.length == 10 && phoneCtrl.text.startsWith("05")) {
            Navigator.pop(ctx); _askLocation();
          } else {
            _showPopup("خطأ: رقم الجوال يجب أن يكون 10 أرقام ويبدأ بـ 05");
          }
        }, child: Text("حسناً"))
      ],
    ));
  }

  // 3. الموقع
  void _askLocation() {
    showModalBottomSheet(context: context, builder: (ctx) => Container(
      padding: EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text("تحديد موقع التسليم", style: TextStyle(fontWeight: FontWeight.bold)),
        ListTile(leading: Icon(Icons.my_location), title: Text("موقعي الحالي"), onTap: () => _showPaymentMethods()),
        ListTile(leading: Icon(Icons.chat), title: Text("إرسال عبر الواتساب"), onTap: () => _showPaymentMethods()),
        ListTile(leading: Icon(Icons.map), title: Text("لصق رابط جوجل ماب"), onTap: () => _showPaymentMethods()),
      ]),
    ));
  }

  // 4. طرق الدفع السعودية
  void _showPaymentMethods() {
    Navigator.pop(context);
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text("خطوة الدفع"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _payTile("Apple Pay", Colors.black, Icons.apple),
        _payTile("STC Pay", Color(0xFF4F008C), Icons.payment),
        _payTile("تحويل بنكي", Colors.blueGrey, Icons.account_balance),
        Text("\nالآيبان: SA12345678901234567890", style: TextStyle(fontSize: 10, color: Colors.amber)),
      ]),
      actions: [ElevatedButton(onPressed: () => _showUploadReceipt(), child: Text("التالي"))],
    ));
  }

  Widget _payTile(String t, Color c, IconData i) => Card(color: c, child: ListTile(leading: Icon(i, color: Colors.white), title: Text(t, style: TextStyle(color: Colors.white))));

  // 5. رفع الإيصال
  void _showUploadReceipt() {
    Navigator.pop(context);
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text("إثبات الدفع"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.cloud_upload, size: 50, color: Colors.amber),
        Text("يرجى رفع صورة التحويل لإتمام العملية"),
        ElevatedButton(onPressed: () => _finishOrder(), child: Text("اختيار صورة الإيصال")),
      ]),
    ));
  }

  void _finishOrder() {
    Navigator.pop(context);
    setState(() => cart.clear());
    _showPopup("شكراً لك! تم استلام طلبك وبانتظار مراجعة الإيصال. يمكنك التتبع من قسم طلباتي.");
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
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text(selectedCategory ?? "أقسام المتجر", style: TextStyle(color: Colors.amber)),
        actions: [
          Stack(children: [
            IconButton(icon: Icon(Icons.shopping_cart), onPressed: _showCheckoutFlow),
            if(cart.isNotEmpty) Positioned(right: 8, top: 8, child: CircleAvatar(radius: 8, backgroundColor: Colors.red, child: Text(cart.length.toString(), style: TextStyle(fontSize: 10)))),
          ]),
          IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: selectedCategory == null ? _buildCategories() : _buildProducts(),
      floatingActionButton: selectedCategory != null ? FloatingActionButton(onPressed: () => setState(() => selectedCategory = null), child: Icon(Icons.home), backgroundColor: Colors.amber) : null,
    );
  }

  Widget _buildCategories() {
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

  Widget _buildProducts() {
    final filtered = allProducts.where((p) => p.category == selectedCategory).toList();
    return filtered.isEmpty 
      ? Center(child: Text("قريباً سيتم توفير بضاعة هذا القسم", style: TextStyle(color: Colors.grey)))
      : ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (ctx, i) => ListTile(
            title: Text(filtered[i].name, style: TextStyle(color: Colors.white)),
            subtitle: Text("${filtered[i].price} ريال", style: TextStyle(color: Colors.amber)),
            trailing: ElevatedButton(onPressed: () { setState(() => cart.add(filtered[i])); }, child: Text("إضافة للسلة")),
          ),
        );
  }
}

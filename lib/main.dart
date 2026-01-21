import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
    primarySwatch: Colors.amber,
    brightness: Brightness.dark,
    fontFamily: 'Arial',
    visualDensity: VisualDensity.adaptivePlatformDensity,
  ),
  home: SmartElevatorApp(),
));

class SmartElevatorApp extends StatefulWidget { @override _SmartElevatorAppState createState() => _SmartElevatorAppState(); }
class _SmartElevatorAppState extends State<SmartElevatorApp> {
  int _currentIndex = 3;
  final List<Widget> _pages = [Center(child: Text("الرئيسية")), OrdersPage(), ReportsPage(), ShopPage(), Center(child: Text("حسابي"))];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.black,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), activeIcon: Icon(Icons.local_shipping), label: "طلباتي"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: "التقارير"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: "المتجر"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "حسابي"),
        ],
      ),
    );
  }
}

// --- قسم المتجر ---
class ShopPage extends StatefulWidget { @override _ShopPageState createState() => _ShopPageState(); }
class _ShopPageState extends State<ShopPage> {
  List<Map<String, dynamic>> cart = [];
  String? currentCategory;
  final categories = ["قسم المكائن", "قسم الكهرباء", "الميكانيكا", "الأبواب", "الكبائن", "الكنترول", "الاكسسوارات"];
  
  final Map<String, List<Map<String, dynamic>>> products = {
    "قسم المكائن": [{"n": "ماكينة سيكور 5.5 حصان", "p": 4500.0}, {"n": "ماكينة مونتناري ايطالي", "p": 6800.0}],
    "قسم الكهرباء": [{"n": "انفرتر ياسكاوا 4 كيلو", "p": 1950.0}, {"n": "كنترول سمارت بورد", "p": 3200.0}],
    "الميكانيكا": [{"n": "حبال صلب 10 ملم - كوري", "p": 180.0}],
    "الأبواب": [{"n": "باب أتوماتيك تيسن 90 سم", "p": 3400.0}],
    "الكبائن": [{"n": "كبينة ستانلس ذهبي", "p": 12500.0}],
    "الكنترول": [{"n": "لوحة تشغيل ميكرو برو", "p": 4500.0}],
    "الاكسسوارات": [{"n": "أزرار لمس نانو", "p": 120.0}],
  };

  void _showWarning(String msg) {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Row(children: [Icon(Icons.warning, color: Colors.amber), Text(" تنبيه")]),
      content: Text(msg),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text("حسناً"))],
    ));
  }

  void _processOrder() {
    if (cart.isEmpty) { _showWarning("السلة فارغة، يرجى اختيار المنتجات أولاً."); return; }
    _customerDataForm();
  }

  void _customerDataForm() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    showDialog(context: context, barrierDismissible: false, builder: (c) => AlertDialog(
      title: Text("بيانات العميل والموقع"),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: InputDecoration(hintText: "الاسم الثلاثي")),
          SizedBox(height: 10),
          TextField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
            decoration: InputDecoration(hintText: "رقم الجوال (05XXXXXXXX)"),
          ),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: Text("إلغاء X", style: TextStyle(color: Colors.red))),
        ElevatedButton(onPressed: () {
          if (nameCtrl.text.trim().length < 6) { _showWarning("يرجى إدخال الاسم الثلاثي بشكل صحيح."); return; }
          if (phoneCtrl.text.length != 10 || !phoneCtrl.text.startsWith("05")) { _showWarning("رقم الجوال يجب أن يبدأ بـ 05 ويتكون من 10 أرقام."); return; }
          Navigator.pop(c); _serviceTypeChoice();
        }, child: Text("التالي")),
      ],
    ));
  }

  void _serviceTypeChoice() {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("نوع الخدمة"),
      content: Text("هل ترغب في شراء القطع فقط أم الشراء مع التركيب والتشغيل؟"),
      actions: [
        ElevatedButton(onPressed: () { Navigator.pop(c); _locationSelection(); }, child: Text("قطعة فقط")),
        ElevatedButton(onPressed: () { Navigator.pop(c); _locationSelection(); }, child: Text("شراء مع التركيب")),
      ],
    ));
  }

  void _locationSelection() {
    showModalBottomSheet(context: context, shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (c) => Container(
      padding: EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text("تحديد موقع التسليم", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
        Divider(),
        ListTile(leading: Icon(Icons.my_location, color: Colors.blue), title: Text("استخدام موقعي الحالي (GPS)"), onTap: () { Navigator.pop(c); _paymentGateway(); }),
        ListTile(leading: Icon(Icons.chat, color: Colors.green), title: Text("إرسال عبر واتساب للمؤسسة"), onTap: () { launchUrl(Uri.parse("https://wa.me/966500000000")); Navigator.pop(c); _paymentGateway(); }),
        ListTile(leading: Icon(Icons.edit, color: Colors.orange), title: Text("وصف الموقع يدوياً"), onTap: () { Navigator.pop(c); _manualInput("وصف الموقع يدوياً"); }),
        ListTile(leading: Icon(Icons.map, color: Colors.red), title: Text("لصق رابط موقع جوجل ماب"), onTap: () { Navigator.pop(c); _manualInput("رابط جوجل ماب"); }),
      ]),
    ));
  }

  void _manualInput(String title) {
    final inputCtrl = TextEditingController();
    showDialog(context: context, barrierDismissible: false, builder: (c) => AlertDialog(
      title: Text(title),
      content: TextField(controller: inputCtrl, maxLines: 3, decoration: InputDecoration(hintText: "أدخل التفاصيل هنا...")),
      actions: [
        ElevatedButton(onPressed: () {
          if (inputCtrl.text.trim().isEmpty) { _showWarning("هذا الحقل إجباري للمتابعة."); return; }
          Navigator.pop(c); _paymentGateway();
        }, child: Text("تأكيد ومتابعة")),
      ],
    ));
  }

  void _paymentGateway() {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("طريقة الدفع الآمنة"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _buildPayBtn("Apple Pay", Colors.black, Icons.apple, c),
        _buildPayBtn("STC Pay", Color(0xFF4F008C), Icons.account_balance_wallet, c),
        _buildPayBtn("تحويل بنكي", Colors.blueGrey, Icons.account_balance, c),
        Padding(padding: const EdgeInsets.only(top: 10), child: Text("IBAN: SA12345678901234567890", style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold))),
      ]),
    ));
  }

  Widget _buildPayBtn(String label, Color color, IconData icon, BuildContext ctx) => InkWell(
    onTap: () { HapticFeedback.vibrate(); Navigator.pop(ctx); _mandatoryReceiptUpload(); },
    child: Card(color: color, child: ListTile(leading: Icon(icon, color: Colors.white), title: Text(label, style: TextStyle(color: Colors.white)))),
  );

  void _mandatoryReceiptUpload() {
    showDialog(context: context, barrierDismissible: false, builder: (c) => AlertDialog(
      title: Text("رفع إيصال السداد (إجباري)"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.cloud_upload_outlined, size: 60, color: Colors.amber),
        SizedBox(height: 10),
        Text("لن يتم اعتماد الطلب بدون صورة التحويل أو الإيصال."),
      ]),
      actions: [ElevatedButton(onPressed: () { setState(() => cart.clear()); Navigator.pop(c); _showWarning("تم بنجاح! سيتم مراجعة إيصالك وتفعيل الطلب."); }, child: Text("رفع الصورة وإتمام الشراء"))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: currentCategory != null ? IconButton(icon: Icon(Icons.arrow_back), onPressed: () => setState(() => currentCategory = null)) : Icon(Icons.home, color: Colors.amber),
        title: Text(currentCategory ?? "متجر المصاعد المتكامل"),
        actions: [
          Stack(alignment: Alignment.center, children: [
            IconButton(icon: Icon(Icons.shopping_cart), onPressed: _processOrder),
            if (cart.isNotEmpty) Positioned(top: 8, right: 8, child: CircleAvatar(radius: 7, backgroundColor: Colors.red, child: Text("${cart.length}", style: TextStyle(fontSize: 9)))),
          ]),
          IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: () => SystemNavigator.pop()),
        ],
      ),
      body: currentCategory == null ? _buildGrid() : _buildProductList(),
    );
  }

  Widget _buildGrid() => GridView.builder(padding: EdgeInsets.all(15), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12), itemCount: categories.length, itemBuilder: (c, i) => InkWell(onTap: () => setState(() => currentCategory = categories[i]), child: Card(color: Color(0xFF1E1E1E), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.settings_input_component, color: Colors.amber, size: 40), SizedBox(height: 10), Text(categories[i], textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))]))));

  Widget _buildProductList() {
    final prods = products[currentCategory] ?? [];
    return ListView.builder(itemCount: prods.length, itemBuilder: (c, i) => ListTile(title: Text(prods[i]['n'].toString()), subtitle: Text("${prods[i]['p']} ريال", style: TextStyle(color: Colors.amber)), trailing: ElevatedButton(onPressed: () { setState(() => cart.add(prods[i])); HapticFeedback.lightImpact(); }, child: Text("إضافة"))));
  }
}

// --- صفحة طلباتي (التتبع الاحترافي) ---
class OrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(backgroundColor: Colors.black, title: Text("تتبع الطلبات")),
      body: ListView(padding: EdgeInsets.all(15), children: [
        _buildTrackCard("ORD-7712", "وصلت - جاهز للاستلام", 1.0, true, "5591"),
        _buildTrackCard("ORD-6620", "في الطريق مع المندوب", 0.7, false, "---"),
        _buildTrackCard("ORD-5541", "قيد التجهيز بالمخزن", 0.3, false, "---"),
      ]),
    );
  }

  Widget _buildTrackCard(String id, String status, double progress, bool isReady, String otp) => Card(
    color: Color(0xFF1E1E1E), margin: EdgeInsets.only(bottom: 15), child: Padding(padding: EdgeInsets.all(15), child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(id, style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)), Text(status, style: TextStyle(fontSize: 12))]),
      SizedBox(height: 10),
      LinearProgressIndicator(value: progress, color: Colors.amber, backgroundColor: Colors.white12),
      SizedBox(height: 15),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text("كود الاستلام: $otp", style: TextStyle(color: Colors.grey)),
        if (isReady) ElevatedButton.icon(onPressed: () {}, icon: Icon(Icons.edit), label: Text("توقيع واستلام"))
        else Icon(Icons.local_shipping, color: Colors.amber, size: 30),
      ])
    ])),
  );
}

// --- صفحة التقارير والفواتير ---
class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 2, child: Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(backgroundColor: Colors.black, title: Text("السجلات والتقارير"), bottom: TabBar(tabs: [Tab(text: "فواتير جديدة"), Tab(text: "الأرشيف المنتهي")], indicatorColor: Colors.amber)),
      body: TabBarView(children: [_buildInvoiceList(), _buildInvoiceList()]),
    ));
  }

  Widget _buildInvoiceList() => ListView.builder(itemCount: 4, itemBuilder: (c, i) => Card(
    color: Color(0xFF1E1E1E), child: ListTile(
      leading: Icon(Icons.picture_as_pdf, color: Colors.red),
      title: Text("فاتورة ضريبية #INV-100$i"),
      subtitle: Text("القيمة: 5400 ريال (شامل VAT 15%)", style: TextStyle(color: Colors.amber, fontSize: 11)),
      trailing: IconButton(icon: Icon(Icons.download_for_offline), onPressed: () {}),
    ),
  ));
}

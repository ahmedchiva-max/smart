import 'package:flutter/material.dart';

class ShopPage extends StatefulWidget {
  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  // الأقسام السبعة المطلوبة
  final List<Map<String, dynamic>> categories = [
    {'name': 'قسم المكائن', 'icon': Icons.settings, 'color': Colors.amber},
    {'name': 'قسم الكهرباء', 'icon': Icons.flash_on, 'color': Colors.yellow},
    {'name': 'الميكانيكا', 'icon': Icons.build, 'color': Colors.grey},
    {'name': 'الأبواب', 'icon': Icons.sensor_door, 'color': Colors.brown},
    {'name': 'الكبائن', 'icon': Icons.view_quilt, 'color': Colors.blueGrey},
    {'name': 'الكنترول', 'icon': Icons.developer_board, 'color': Colors.green},
    {'name': 'الاكسسوارات', 'icon': Icons.stars, 'color': Colors.orange},
  ];

  // دالة الشراء والتحقق
  void _startOrder(String itemName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF222222),
        title: Text("خيار الشراء", style: TextStyle(color: Colors.white)),
        content: Text("هل ترغب في شراء القطعة فقط أم مع التركيب؟", style: TextStyle(color: Colors.grey)),
        actions: [
          ElevatedButton(onPressed: () => _askPhone(itemName, "قطعة فقط"), child: Text("قطعة فقط")),
          ElevatedButton(onPressed: () => _askPhone(itemName, "شراء مع تركيب"), child: Text("مع تركيب")),
        ],
      ),
    );
  }

  void _askPhone(String item, String type) {
    Navigator.pop(context);
    TextEditingController phoneCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("رقم الجوال"),
        content: TextField(
          controller: phoneCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: "05XXXXXXXX"),
        ),
        actions: [
          TextButton(onPressed: () {
            String p = phoneCtrl.text;
            if (p.length == 10 && p.startsWith("05")) {
              Navigator.pop(context);
              _askLocation(item, type, p);
            } else {
              _showPopup("خطأ: يجب إدخال 10 أرقام تبدأ بـ 05");
            }
          }, child: Text("حسناً"))
        ],
      ),
    );
  }

  void _askLocation(String item, String type, String phone) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1A1A1A),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: Text("تحديد الموقع", style: TextStyle(color: Colors.amber))),
          ListTile(leading: Icon(Icons.my_location), title: Text("موقعي الحالي"), onTap: () => _showPayment()),
          ListTile(leading: Icon(Icons.chat), title: Text("إرسال عبر الواتساب"), onTap: () => _showPayment()),
          ListTile(leading: Icon(Icons.map), title: Text("لصق رابط جوجل ماب"), onTap: () => _showPayment()),
        ],
      ),
    );
  }

  void _showPayment() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("طريقة الدفع"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text("Apple Pay"), leading: Icon(Icons.apple)),
            ListTile(title: Text("STC Pay"), leading: Icon(Icons.payment)),
            ListTile(title: Text("تحويل بنكي"), subtitle: Text("SA12345678901234567890"), leading: Icon(Icons.account_balance)),
          ],
        ),
        actions: [ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("رفع الإيصال وإتمام الطلب"))],
      ),
    );
  }

  void _showPopup(String msg) {
    showDialog(context: context, builder: (context) => AlertDialog(content: Text(msg), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("حسناً"))]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Text("أقسام المتجر"),
        actions: [IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: () => Navigator.pop(context))],
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: categories.length,
        itemBuilder: (context, index) => Card(
          color: Color(0xFF333333),
          child: InkWell(
            onTap: () => _startOrder(categories[index]['name']),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(categories[index]['icon'], size: 50, color: categories[index]['color']),
                Text(categories[index]['name'], style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

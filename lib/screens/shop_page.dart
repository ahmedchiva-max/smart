import 'package:flutter/material.dart';

class ShopPage extends StatefulWidget {
  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  // الأقسام السبعة + قسم باقات التحديث
  final List<Map<String, dynamic>> categories = [
    {'name': 'قسم المكائن', 'icon': Icons.settings, 'color': Colors.amber},
    {'name': 'باقات التحديث (AR)', 'icon': Icons.view_in_ar, 'color': Colors.cyan}, // اقتراح 4
    {'name': 'قسم الكهرباء', 'icon': Icons.flash_on, 'color': Colors.yellow},
    {'name': 'الميكانيكا', 'icon': Icons.build, 'color': Colors.grey},
    {'name': 'الأبواب', 'icon': Icons.sensor_door, 'color': Colors.brown},
    {'name': 'الكبائن', 'icon': Icons.view_quilt, 'color': Colors.blueGrey},
    {'name': 'الكنترول', 'icon': Icons.developer_board, 'color': Colors.green},
    {'name': 'الاكسسوارات', 'icon': Icons.stars, 'color': Colors.orange},
  ];

  // دالة الدفع بأيقونات واقعية (اقتراح 3)
  void _showRealisticPayment() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("اختر طريقة الدفع الآمنة", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            // Apple Pay - تصميم واقعي
            _paymentTile("Apple Pay", Colors.black, Icons.apple, "دفع سريع بلمسة واحدة"),
            // STC Pay - تصميم واقعي
            _paymentTile("STC Pay", Color(0xFF4F008C), Icons.account_balance_wallet, "المحفظة الرقمية المفضلة"),
            // التحويل البنكي
            _paymentTile("تحويل بنكي", Colors.blueGrey, Icons.account_balance, "آيبان: SA123456..."),
          ],
        ),
      ),
    );
  }

  Widget _paymentTile(String title, Color color, IconData icon, String sub) {
    return Card(
      color: color,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 30),
        title: Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(sub, style: TextStyle(color: Colors.white70, fontSize: 12)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 15),
        onTap: () => _showSuccess(),
      ),
    );
  }

  void _showSuccess() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Text("تمت العملية! تم تحديث ملف مصعدك الرقمي وإضافة نقاط الولاء لمحفظتك.", textAlign: TextAlign.center), // اقتراح 2 و 5
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("متجر SMART المطور", style: TextStyle(color: Colors.amber)),
        actions: [
          // أيقونة المحفظة ونقاط الولاء (اقتراح 5)
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Row(
              children: [
                Icon(Icons.stars, color: Colors.amber, size: 20),
                SizedBox(width: 5),
                Text("150 نقطة", style: TextStyle(color: Colors.white)),
              ],
            ),
          )
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.1),
        itemCount: categories.length,
        itemBuilder: (context, index) => Card(
          color: Color(0xFF2D2D2D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: InkWell(
            onTap: () => _showRealisticPayment(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(categories[index]['icon'], size: 45, color: categories[index]['color']),
                SizedBox(height: 8),
                Text(categories[index]['name'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                if(categories[index]['name'].contains("AR")) 
                  Text("معاينة حية", style: TextStyle(color: Colors.cyan, fontSize: 10)), // اقتراح 4
              ],
            ),
          ),
        ),
      ),
    );
  }
}

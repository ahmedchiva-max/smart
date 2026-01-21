import 'package:flutter/material.dart';

class ShopPage extends StatefulWidget {
  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final List<Map<String, dynamic>> categories = [
    {'name': 'قسم المكائن', 'icon': Icons.settings, 'color': Colors.amber},
    {'name': 'قسم الكهرباء', 'icon': Icons.flash_on, 'color': Colors.yellow},
    {'name': 'الميكانيكا', 'icon': Icons.build, 'color': Colors.grey},
    {'name': 'الأبواب', 'icon': Icons.sensor_door, 'color': Colors.brown},
    {'name': 'الكبائن', 'icon': Icons.view_quilt, 'color': Colors.blueGrey},
    {'name': 'الكنترول', 'icon': Icons.developer_board, 'color': Colors.green},
    {'name': 'الاكسسوارات', 'icon': Icons.stars, 'color': Colors.orange},
  ];

  void _showPurchaseFlow(String itemName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF222222),
        title: Text("خيار الشراء - $itemName", style: TextStyle(color: Colors.white)),
        content: Text("هل ترغب في شراء القطعة فقط أم مع التركيب؟", style: TextStyle(color: Colors.grey)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () => _getPhoneNumber(context, itemName, "قطعة فقط"),
            child: Text("قطعة فقط"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => _getPhoneNumber(context, itemName, "شراء مع تركيب"),
            child: Text("شراء مع تركيب"),
          ),
        ],
      ),
    );
  }

  void _getPhoneNumber(BuildContext context, String item, String type) {
    Navigator.pop(context);
    TextEditingController phoneController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF222222),
        title: Text("رقم الجوال", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "05XXXXXXXX",
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              String phone = phoneController.text;
              if (phone.length == 10 && phone.startsWith("05") && RegExp(r'^[0-9]+$').hasMatch(phone)) {
                Navigator.pop(context);
                _getLocationAndPayment(item, type, phone);
              } else {
                _showWarning(context, "خطأ: يجب إدخال 10 أرقام تبدأ بـ 05");
              }
            },
            child: Text("حسناً", style: TextStyle(color: Colors.amber)),
          )
        ],
      ),
    );
  }

  void _showWarning(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("تحذير"),
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("حسناً"))],
      ),
    );
  }

  void _getLocationAndPayment(String item, String type, String phone) {
    // هنا يتم الانتقال لصفحة الموقع والدفع (بشكل مبسط للعرض)
    print("المنتج: $item, النوع: $type, الجوال: $phone");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text("متجر SMART", style: TextStyle(color: Colors.amber)),
        actions: [IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: () => Navigator.pop(context))],
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.1),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Card(
            color: Color(0xFF333333),
            child: InkWell(
              onTap: () => _showPurchaseFlow(categories[index]['name']),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(categories[index]['icon'], size: 50, color: categories[index]['color']),
                  SizedBox(height: 10),
                  Text(categories[index]['name'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

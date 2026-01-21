import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(brightness: Brightness.dark, primaryColor: Colors.amber, fontFamily: 'Arial'),
  home: UberElevatorsHome(),
));

class UberElevatorsHome extends StatefulWidget { @override _UberElevatorsHomeState createState() => _UberElevatorsHomeState(); }
class _UberElevatorsHomeState extends State<UberElevatorsHome> {
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("UBER ELEVATORS", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [IconButton(icon: Icon(Icons.notifications_none), onPressed: (){})],
      ),
      body: _idx == 0 ? _buildMainHome(context) : Center(child: Text("صفحة قيد التطوير")),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx, onTap: (i) => setState(() => _idx = i),
        backgroundColor: Colors.black, selectedItemColor: Colors.amber, unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "طلباتي"),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: "التقارير"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "المتجر"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "حسابي"),
        ],
      ),
    );
  }

  Widget _buildMainHome(BuildContext context) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: EdgeInsets.all(15), child: Text("مصاعدي المسجلة", style: TextStyle(fontWeight: FontWeight.bold))),
        Row(children: [
          _buildElevatorCard("مصعد المنزل", "حي النرجس"),
          _buildElevatorCard("مصعد المكتب", "برج رافال"),
        ]),
        
        // زر إبلاغ عن عطل (أحمر كما في الصورة)
        Container(
          width: double.infinity, margin: EdgeInsets.all(15), height: 60,
          decoration: BoxDecoration(color: Colors.red.withOpacity(0.8), borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: Icon(Icons.bolt, color: Colors.white),
            title: Text("إبلاغ عن عطل (فوري)", style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Icon(Icons.arrow_forward_ios, size: 15),
            onTap: () => _openServiceFlow(context, "بلاغ عطل"),
          ),
        ),

        // شبكة الخدمات (المطابقة للصور)
        GridView.count(
          shrinkWrap: true, physics: NeverScrollableScrollPhysics(), crossAxisCount: 3, padding: EdgeInsets.all(10),
          children: [
            _buildServiceIcon(Icons.add_box, "تركيب جديد", Colors.green, context),
            _buildServiceIcon(Icons.update, "تحديث", Colors.amber, context),
            _buildServiceIcon(Icons.build, "صيانة", Colors.blue, context),
            _buildServiceIcon(Icons.store, "المتجر", Colors.yellow, context),
            _buildServiceIcon(Icons.photo_library, "الأعمال", Colors.purple, context),
            _buildServiceIcon(Icons.headset_mic, "تواصل", Colors.teal, context),
          ],
        ),
      ]),
    );
  }

  Widget _buildElevatorCard(String name, String loc) => Container(
    width: 150, margin: EdgeInsets.only(left: 15), padding: EdgeInsets.all(10),
    decoration: BoxDecoration(color: Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.elevator, color: Colors.amber, size: 20),
      SizedBox(height: 5), Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      Text(loc, style: TextStyle(fontSize: 10, color: Colors.grey)),
    ]),
  );

  Widget _buildServiceIcon(IconData icon, String label, Color color, BuildContext ctx) => InkWell(
    onTap: () => _openServiceFlow(ctx, label),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(padding: EdgeInsets.all(15), child: Icon(icon, color: color, size: 30)),
      Text(label, style: TextStyle(fontSize: 11)),
    ]),
  );

  // --- نظام الطلبات المتكامل ---
  void _openServiceFlow(BuildContext context, String title) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (c) => Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(color: Color(0xFF121212), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(children: [
        _modalAppBar(context, "طلب $title"),
        Expanded(child: _buildFormSteps(context, title)),
      ]),
    ));
  }

  Widget _modalAppBar(BuildContext context, String title) => Container(
    padding: EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      IconButton(icon: Icon(Icons.arrow_back_ios, size: 18), onPressed: () => Navigator.pop(context)),
      Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: () => Navigator.pop(context)),
    ]),
  );

  Widget _buildFormSteps(BuildContext context, String title) => ListView(padding: EdgeInsets.all(20), children: [
    Text("بيانات التواصل والموقع", style: TextStyle(color: Colors.amber)),
    TextField(decoration: InputDecoration(hintText: "اسم العميل")),
    TextField(decoration: InputDecoration(hintText: "الجوال (05XXXXXXXX)"), keyboardType: TextInputType.phone),
    SizedBox(height: 20),
    Text("موقع المصعد", style: TextStyle(color: Colors.amber)),
    _locBtn("مشاركة الموقع الحالي (GPS)", Icons.gps_fixed),
    _locBtn("واتساب المؤسسة", Icons.chat),
    _locBtn("رابط جوجل ماب", Icons.map),
    _locBtn("وصف يدوي", Icons.edit),
    SizedBox(height: 20),
    ElevatedButton(onPressed: (){}, child: Text("تأكيد وطلب الفني الأقرب"), style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black)),
  ]);

  Widget _locBtn(String t, IconData i) => ListTile(leading: Icon(i, size: 20), title: Text(t, style: TextStyle(fontSize: 13)), onTap: (){});
}

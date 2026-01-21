import 'package:flutter/material.dart';

class SmartHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("SMART ELEVATORS", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildRegisteredElevators(),
            _buildEmergencyButton(),
            _buildServicesGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisteredElevators() {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("مصاعدي المسجلة", style: TextStyle(color: Colors.white, fontSize: 16)),
          SizedBox(height: 10),
          Row(
            children: [
              _elevatorCard("مصعد المنزل", "حي النرجس"),
              SizedBox(width: 10),
              _elevatorCard("مصعد المكتب", "برج رافال"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _elevatorCard(String name, String loc) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: Color(0xFF333333), borderRadius: BorderRadius.circular(10)),
      child: Column(children: [Text(name, style: TextStyle(color: Colors.white)), Text(loc, style: TextStyle(color: Colors.grey, fontSize: 10))]),
    );
  }

  Widget _buildEmergencyButton() {
    return Container(
      margin: EdgeInsets.all(15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.red[900], borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("إبلاغ عن عطل (فوري)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Icon(Icons.bolt, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildServicesGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      children: [
        _serviceItem(Icons.add_box, "تركيب جديد", Colors.green),
        _serviceItem(Icons.update, "تحديث", Colors.amber),
        _serviceItem(Icons.build, "صيانة", Colors.blue),
        _serviceItem(Icons.store, "المتجر", Colors.yellow),
        _serviceItem(Icons.collections, "الأعمال", Colors.purple),
        _serviceItem(Icons.support_agent, "تواصل", Colors.teal),
      ],
    );
  }

  Widget _serviceItem(IconData icon, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Icon(icon, color: color, size: 30), Text(label, style: TextStyle(color: Colors.white, fontSize: 11))],
    );
  }
}

import 'package:flutter/material.dart';

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("??? ???????? ?????", style: TextStyle(color: Colors.amber)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          tabs: [Tab(text: "???????? ???????"), Tab(text: "??????? (????????)")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildReportList(false), _buildReportList(true)],
      ),
    );
  }

  Widget _buildReportList(bool isArchive) {
    return ListView(
      padding: EdgeInsets.all(10),
      children: [
        if (!isArchive) _summaryCard(), // ???? ???? ?????? ???
        _reportTile(
          name: "???? ?? ?????",
          item: "?????? ????? + ?????",
          price: "5750 ????",
          time: "06:45:12 PM",
          date: "2026/01/21",
          method: "Apple Pay",
          isNew: !isArchive
        ),
        _reportTile(
          name: "????? ?????",
          item: "?????? ????? 4 ?????",
          price: "3220 ????",
          time: "02:30:00 PM",
          date: "2026/01/20",
          method: "????? ????",
          isNew: !isArchive
        ),
      ],
    );
  }

  Widget _summaryCard() {
    return Card(
      color: Colors.amber,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(children: [Text("?????? ????????", style: TextStyle(fontWeight: FontWeight.bold)), Text("8,970 ????", style: TextStyle(fontSize: 20))]),
            Column(children: [Text("??????? (15%)", style: TextStyle(fontWeight: FontWeight.bold)), Text("1,345 ????", style: TextStyle(fontSize: 20))]),
          ],
        ),
      ),
    );
  }

  Widget _reportTile({required String name, required String item, required String price, required String time, required String date, required String method, required bool isNew}) {
    return Card(
      color: Color(0xFF1E1E1E),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        leading: Icon(isNew ? Icons.fiber_new : Icons.archive, color: isNew ? Colors.green : Colors.grey),
        title: Text(name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text("$date | $time", style: TextStyle(color: Colors.grey, fontSize: 12)),
        children: [
          Padding(
            padding: EdgeInsets.all(15),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("??????: $item", style: TextStyle(color: Colors.amber)),
              Text("?????? ?????????: $price", style: TextStyle(color: Colors.white)),
              Text("????? ?????: $method", style: TextStyle(color: Colors.white70)),
              SizedBox(height: 10),
              ElevatedButton.icon(onPressed: () {}, icon: Icon(Icons.picture_as_pdf), label: Text("????? ???????? ???????? PDF"))
            ]),
          )
        ],
      ),
    );
  }
}

import 'package:abtms/controllers/controllers.dart';
import 'package:flutter/material.dart';

class PatientHistoryPage extends StatefulWidget {
  const PatientHistoryPage({super.key});

  @override
  State<PatientHistoryPage> createState() => _PatientHistoryPageState();
}

class _PatientHistoryPageState extends State<PatientHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController(initialPage: 0);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageController.jumpToPage(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: "History"),
      body: Column(
        children: [
          Container(
            height: 40,
            width: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                width: 2,
                color: const Color(0xFF3E4D99),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: TabBar(
                indicatorWeight: 0,
                splashBorderRadius: BorderRadius.circular(30),
                overlayColor: const MaterialStatePropertyAll(Colors.black),
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: const Color(0xFF3E4D99),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF3E4D99),
                tabs: const [
                  Tab(text: 'Chart'),
                  Tab(text: 'History'),
                ],
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                _tabController.animateTo(index);
              },
              children: const [
                Center(child: Text('No data available')),
                Center(child: Text('No data available')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

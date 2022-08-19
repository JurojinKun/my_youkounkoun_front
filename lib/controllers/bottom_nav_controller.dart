import 'package:flutter/material.dart';
import 'package:my_boilerplate/views/auth/home.dart';
import 'package:my_boilerplate/views/auth/profile.dart';

class BottomNavController extends StatefulWidget {
  const BottomNavController({Key? key}) : super(key: key);

  @override
  BottomNavControllerState createState() => BottomNavControllerState();
}

class BottomNavControllerState extends State<BottomNavController>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [Home(), Profile()]),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomNavigationBar(
                elevation: 6,
                selectedItemColor: Colors.blue,
                unselectedItemColor: Colors.black45,
                currentIndex: _tabController.index,
                onTap: (index) {
                  setState(() {
                    _tabController.index = index;
                  });
                },
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: "Home"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person), label: "Profile")
                ]),
          )
        ],
      ),
    );
  }
}

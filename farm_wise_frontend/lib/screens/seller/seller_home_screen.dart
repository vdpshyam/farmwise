import 'package:flutter/material.dart';

import 'seller_dashboard_page.dart';
import 'seller_listed_items_page.dart';
import 'seller_orders_page.dart';
import 'seller_settings.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  List<Widget> pages = const [
    SellerDashboardPage(),
  SellerListedItemsPage(),
    SellerOrdersPage(),
    SellerSettingsPage(),
  ];

  List<String> pagelabel = [
    "FarmWise Dashboard",
    "Listed Items",
    "Orders",
    "Settings",
  ];

  int selectedPageIndex = 0;
  String selectedPageLabel = "FarmWise Dashboard";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: const Color.fromARGB(163, 76, 175, 79),
        backgroundColor: selectedPageIndex == 0
            ? const Color.fromARGB(255, 27, 156, 115)
            : null,
        foregroundColor: selectedPageIndex == 0 ? Colors.white : null,
        title: Text(
          selectedPageLabel,
        ),
      ),
      // extendBodyBehindAppBar: true,
      body: pages[selectedPageIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedPageIndex,
          onTap: (value) {
            setState(() {
              selectedPageIndex = value;
              selectedPageLabel = pagelabel[value];
            });
          },
          selectedItemColor: const Color.fromARGB(255, 27, 156, 115),
          unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
          showSelectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.dashboard_outlined,
              ),
              activeIcon: Icon(
                Icons.dashboard_rounded,
              ),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.sell_outlined,
              ),
              activeIcon: Icon(Icons.sell_rounded),
              label: "Items",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.card_travel,
              ),
              // activeIcon: Icon(
              //   Icons.,
              // ),
              label: "Orders",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.settings_outlined,
              ),
              activeIcon: Icon(
                Icons.settings_rounded,
              ),
              label: "Settings",
            )
          ]),
    );
  }
}

import 'package:flutter/material.dart';

import 'buyer_favorites_page.dart';
import 'buyer_dashboard_page.dart';
import 'buyer_orders_page.dart';
import 'buyer_search_page.dart';
import 'buyer_settings_page.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  List<Widget> pages = const [
    BuyerDashboardPage(),
    BuyerSearchPage(),
    BuyerOrdersPage(),
    BuyerFavoritesPage(),
    BuyerSettingsPage(),
  ];

  List<String> pagelabel = [
    "FarmWise Dashboard",
    "Search",
    "Orders",
    "Favorites",
    "Settings",
  ];

  int selectedPageIndex = 0;
  String selectedPageLabel = "FarmWise Dashboard";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.green,
        backgroundColor: selectedPageIndex == 0
            ? const Color.fromARGB(255, 27, 156, 115)
            : null,
        foregroundColor: selectedPageIndex == 0
            ? Colors.white
            : null,
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
              Icons.search_rounded,
            ),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.card_travel,
            ),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite_border_outlined,
            ),
            activeIcon: Icon(
              Icons.favorite,
            ),
            label: "Favorites",
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
        ],
      ),
    );
  }
}

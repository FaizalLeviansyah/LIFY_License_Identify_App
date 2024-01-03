import 'package:flutter/material.dart';
import 'package:ocr_license_plate/views/plates/plates_history_view.dart';
import 'package:ocr_license_plate/views/plates/plates_list_view.dart';
import 'package:ocr_license_plate/views/scan/scan_view.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../enums/menu_item.dart';
import '../utilities/dialogs/logout_diaolog.dart';

class LayoutView extends StatefulWidget {
  const LayoutView({super.key});

  @override
  State<LayoutView> createState() => _LayoutViewState();
}

class _LayoutViewState extends State<LayoutView> {
  var _currentIndex = 0;
  final List<Widget Function(BuildContext)> _pageRoutes = [
    (context) => const ScanView(),
    (context) => const PlateListView(),
    (context) => const PlateHistoryView(),
    (context) => const PlateListView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LIFY - License Identify App'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  await showLogOutDialog(
                    context,
                    "Are you sure want to log out?",
                  );
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Logout'),
                ),
              ];
            },
          )
        ],
      ),
      bottomNavigationBar: SalomonBottomBar(
        unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
        currentIndex: _currentIndex,
        onTap: (i) => setState(() {
          _currentIndex = i;
        }),
        items: [
          /// Home
          SalomonBottomBarItem(
            icon: const Icon(Icons.camera_alt_outlined),
            title: const Text("Scan"),
            selectedColor: Colors.yellow,
          ),

          /// Likes
          SalomonBottomBarItem(
            icon: const Icon(Icons.list),
            title: const Text("List"),
            selectedColor: Colors.pink,
          ),

          /// Search
          SalomonBottomBarItem(
            icon: const Icon(Icons.history),
            title: const Text("History"),
            selectedColor: Colors.orange,
          ),

          SalomonBottomBarItem(
            icon: const Icon(Icons.group),
            title: const Text("About Us"),
            selectedColor: Colors.green,
          ),
        ],
      ),
      body: _pageRoutes[_currentIndex](context),
    );
  }
}

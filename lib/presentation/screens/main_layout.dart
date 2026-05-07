import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action for the center button (e.g., Add new trip)
        },
        backgroundColor: Theme.of(context).primaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(context, 0, Icons.home_rounded, 'Home'),
              _buildNavItem(context, 1, Icons.map_outlined, 'Map'),
              const SizedBox(width: 40), // Space for FAB
              _buildNavItem(context, 2, Icons.favorite_border_rounded, 'Favorites'),
              _buildNavItem(context, 3, Icons.person_outline_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    final isSelected = navigationShell.currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => navigationShell.goBranch(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

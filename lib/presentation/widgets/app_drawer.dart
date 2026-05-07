import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_travel_companion/logic/blocs/theme/theme_bloc.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.watch<ThemeBloc>();
    final matchedLocation = GoRouterState.of(context).matchedLocation;

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(25, 60, 25, 35),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(bottomRight: Radius.circular(40)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=aarav'),
                  ),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aarav Mehta',
                        style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'aarav.mehta@gmail.com',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(context, Icons.home_outlined, 'Home', '/', matchedLocation == '/'),
                _buildDrawerItem(context, Icons.map_outlined, 'Map', '/map', matchedLocation == '/map'),
                _buildDrawerItem(context, Icons.favorite_outline, 'Favorites', '/favorites', matchedLocation == '/favorites'),
                _buildDrawerItem(context, Icons.file_download_outlined, 'Downloaded', '/downloaded', false),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Divider(height: 1, thickness: 0.5),
                ),
                _buildDrawerItem(context, Icons.settings_outlined, 'Settings', '/settings', false),
                _buildDrawerItem(context, Icons.help_outline_rounded, 'Help & Support', '/help', false),
                _buildDrawerItem(context, Icons.info_outline_rounded, 'About Us', '/about', false),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 30),
            child: Row(
              children: [
                const Icon(Icons.dark_mode_outlined, color: Colors.black87),
                const SizedBox(width: 15),
                const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                const Spacer(),
                Switch(
                  value: themeBloc.state == ThemeMode.dark,
                  onChanged: (_) => themeBloc.toggleTheme(),
                  activeColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    String path,
    bool isSelected,
  ) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).primaryColor : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      onTap: () {
        context.pop(); // Close drawer
        if (path == '/' || path == '/map' || path == '/favorites') {
          context.go(path);
        }
      },
    );
  }
}

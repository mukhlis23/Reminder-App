import 'package:flutter/material.dart';
import '../widgets/profile_menu_item.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Profile Menu',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.person,
                    size: 42,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Rizzking Aditya',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              children: [
                ProfileMenuItem(
                  icon: Icons.person,
                  title: 'Profile',
                  onTap: () {},
                ),
                ProfileMenuItem(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  onTap: () {},
                ),
                ProfileMenuItem(
                  icon: Icons.help_outline,
                  title: 'Help',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

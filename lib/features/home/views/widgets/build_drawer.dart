import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/helper/extensions.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/providers/auth_state_manager.dart';
import 'package:hodorak/core/utils/routes.dart';

Widget buildDrawer(BuildContext context, AuthState authState, WidgetRef ref) {
  return Drawer(
    child: Column(
      children: [
        // Drawer Header with User Info
        Container(
          width: double.infinity,
          height: MediaQuery.heightOf(context) * 0.31,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xff8C9F5F),
                Color(0xff8C9F5F).withValues(alpha: 0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: Color(0xff8C9F5F).withValues(alpha: 0.1),
                      child: Text(
                        authState.name?.isNotEmpty == true
                            ? authState.name![0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff8C9F5F),
                        ),
                      ),
                    ),
                  ),
                  verticalSpace(16),
                  // User Name
                  Text(
                    authState.name ?? 'User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  verticalSpace(4),
                  // User Role
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      authState.isAdmin ? 'Administrator' : 'Employee',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Drawer Menu Items
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildDrawerItem(
                icon: Icons.person,
                title: 'Profile',
                onTap: () {
                  context.pop();
                  context.pushNamed(Routes.profile);
                  // Navigate to profile screen
                },
              ),

              _buildDrawerItem(
                icon: Icons.calendar_today,
                title: 'Calendar',
                onTap: () {
                  context.pop();
                  context.pushNamed(Routes.calendarScreen);
                },
              ),
              _buildDrawerItem(
                icon: Icons.settings,
                title: 'Settings',
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to settings screen
                },
              ),
              Divider(),
              _buildDrawerItem(
                icon: Icons.info,
                title: 'User ID: ${authState.uid ?? 'N/A'}',
                onTap: () {},
                isInfo: true,
              ),
              _buildDrawerItem(
                icon: Icons.email,
                title: 'Email: ${authState.name ?? 'N/A'}',
                onTap: () {},
                isInfo: true,
              ),
            ],
          ),
        ),

        // Logout Button
        Container(
          padding: EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Logout'),
                      content: Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await ref
                                .read(authStateManagerProvider.notifier)
                                .logout();
                            if (context.mounted) {
                              context.pushReplacementNamed(Routes.loginScreen);
                            }
                          },
                          child: Text('Logout'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.logout, color: Colors.white),
              label: Text(
                'Logout',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildDrawerItem({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  bool isInfo = false,
}) {
  return ListTile(
    leading: Icon(
      icon,
      color: isInfo ? Colors.grey[600] : Color(0xff8C9F5F),
      size: isInfo ? 20 : 24,
    ),
    title: Text(
      title,
      style: TextStyle(
        color: isInfo ? Colors.grey[600] : Colors.black87,
        fontSize: isInfo ? 12 : 16,
        fontWeight: isInfo ? FontWeight.normal : FontWeight.w500,
      ),
    ),
    onTap: onTap,
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
  );
}

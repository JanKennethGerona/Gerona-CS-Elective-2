import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/ui_style.dart';

/// Navigation item definition.
class _NavItem {
  final String label;
  final IconData materialIcon;
  final IconData cupertinoIcon;

  const _NavItem({
    required this.label,
    required this.materialIcon,
    required this.cupertinoIcon,
  });
}

/// The shared sidebar / drawer navigation list.
///
/// Re-used inside the [Drawer] on mobile/tablet and the permanent
/// sidebar [Column] on desktop so navigation logic is never duplicated.
class SidebarContent extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const SidebarContent({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  static const List<_NavItem> _items = [
    _NavItem(
      label: 'Dashboard',
      materialIcon: Icons.dashboard,
      cupertinoIcon: CupertinoIcons.square_grid_2x2,
    ),
    _NavItem(
      label: 'Settings',
      materialIcon: Icons.settings,
      cupertinoIcon: CupertinoIcons.gear,
    ),
    _NavItem(
      label: 'About',
      materialIcon: Icons.info_outline,
      cupertinoIcon: CupertinoIcons.info,
    ),
    _NavItem(
      label: 'Logout',
      materialIcon: Icons.logout,
      cupertinoIcon: CupertinoIcons.square_arrow_right,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final style = resolveUiStyle();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(color: Color(0xFF37474F)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, size: 32, color: Colors.white),
              ),
              SizedBox(height: 12),
              Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        for (int i = 0; i < _items.length; i++)
          ListTile(
            leading: Icon(
              style == UiStyle.cupertino
                  ? _items[i].cupertinoIcon
                  : _items[i].materialIcon,
            ),
            title: Text(_items[i].label),
            selected: i == selectedIndex,
            selectedTileColor: Colors.blueGrey.withValues(alpha: 0.12),
            onTap: () => onItemTapped(i),
          ),
      ],
    );
  }
}

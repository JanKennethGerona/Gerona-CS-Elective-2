import 'package:flutter/material.dart';
import '../widgets/sidebar_content.dart';
import '../widgets/stat_grid.dart';
import '../widgets/list_rows.dart';
import '../widgets/detail_panel.dart';
import '../widgets/adaptive_button.dart';

/// The single dashboard screen that demonstrates both responsive and
/// adaptive behaviour.
///
/// **Responsive** — uses [LayoutBuilder] to switch between mobile,
/// tablet, and desktop layouts based on available width.
///
/// **Adaptive** — the sidebar, buttons, and switches render in either
/// Material or Cupertino style depending on the platform (see
/// [resolveUiStyle]).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedNavIndex = 0;

  void _onNavItemTapped(int index) {
    setState(() => _selectedNavIndex = index);
    // Close the drawer if it's open (mobile / tablet).
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // Main body content (shared across all three layouts)
  // ──────────────────────────────────────────────────────────────────
  Widget _mainContent(int gridColumns) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dashboard Overview',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF263238),
                ),
              ),
              AdaptiveButton(
                label: 'Refresh',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Refreshed!')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stat cards grid
          StatGrid(columnCount: gridColumns),
          const SizedBox(height: 24),

          // Placeholder list rows
          const ListRows(),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // Layout builders
  // ──────────────────────────────────────────────────────────────────

  /// **Mobile** (< 600 px): Scaffold with hamburger Drawer, 2-column grid.
  Widget _mobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF37474F),
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: SidebarContent(
          selectedIndex: _selectedNavIndex,
          onItemTapped: _onNavItemTapped,
        ),
      ),
      body: _mainContent(2),
    );
  }

  /// **Tablet** (600–1023 px): Same as mobile but with 4-column grid.
  Widget _tabletLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF37474F),
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: SidebarContent(
          selectedIndex: _selectedNavIndex,
          onItemTapped: _onNavItemTapped,
        ),
      ),
      body: _mainContent(4),
    );
  }

  /// **Desktop** (≥ 1024 px): Permanent sidebar + main content + detail panel.
  Widget _desktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Permanent sidebar
          SizedBox(
            width: 240,
            child: Material(
              color: Colors.white,
              elevation: 2,
              child: SidebarContent(
                selectedIndex: _selectedNavIndex,
                onItemTapped: _onNavItemTapped,
              ),
            ),
          ),

          // Main content area
          Expanded(child: _mainContent(4)),

          // Right-hand detail panel (desktop only)
          const DetailPanel(),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= 1024) return _desktopLayout();
        if (width >= 600) return _tabletLayout();
        return _mobileLayout();
      },
    );
  }
}

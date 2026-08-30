import 'package:flutter/material.dart';
import 'adaptive_button.dart';
import 'adaptive_switch.dart';

/// Right-hand detail / info panel shown only on the desktop layout.
///
/// Demonstrates [AdaptiveButton] and [AdaptiveSwitch] inside a
/// realistic panel context.
class DetailPanel extends StatefulWidget {
  const DetailPanel({super.key});

  @override
  State<DetailPanel> createState() => _DetailPanelState();
}

class _DetailPanelState extends State<DetailPanel> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF263238),
            ),
          ),
          const Divider(),
          const SizedBox(height: 12),

          // Placeholder info
          const Text(
            'Quick Info',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF546E7A),
            ),
          ),
          const SizedBox(height: 8),
          _infoRow('Status', 'Active'),
          _infoRow('Role', 'Admin'),
          _infoRow('Last Login', 'Today'),

          const SizedBox(height: 24),

          // Adaptive switches
          const Text(
            'Preferences',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF546E7A),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Notifications'),
              AdaptiveSwitch(
                value: _notificationsEnabled,
                onChanged: (v) => setState(() => _notificationsEnabled = v),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Dark Mode'),
              AdaptiveSwitch(
                value: _darkModeEnabled,
                onChanged: (v) => setState(() => _darkModeEnabled = v),
              ),
            ],
          ),

          const Spacer(),

          // Adaptive button
          SizedBox(
            width: double.infinity,
            child: AdaptiveButton(
              label: 'View Profile',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile tapped!')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.blueGrey)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

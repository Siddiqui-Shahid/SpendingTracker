import 'package:flutter/material.dart';

/// Describes a bottom-navigation destination in the Stitch shell.
class StitchNavDestination {
  const StitchNavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.body,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget body;
}

/// M3 shell with bottom navigation bar.
class StitchNavigationShell extends StatelessWidget {
  const StitchNavigationShell({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<StitchNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    assert(destinations.isNotEmpty, 'At least one destination is required');

    final safeIndex = selectedIndex.clamp(0, destinations.length - 1);

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: destinations.map((d) => d.body).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: [
          for (final destination in destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
            ),
        ],
      ),
    );
  }
}

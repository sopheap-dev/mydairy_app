import 'package:mydairy/app/config/l10n/l10n.dart';
import 'package:mydairy/app/core/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldBottomNav extends StatelessWidget {
  const ScaffoldBottomNav({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  List<NavigationDestination> _destination(BuildContext context) {
    final l10n = context.l10n;

    return [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: l10n.home,
      ),
      NavigationDestination(
        icon: const Icon(Icons.analytics_outlined),
        selectedIcon: const Icon(Icons.analytics),
        label: 'Analytics',
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        label: l10n.setting,
      ),
    ];
  }

  void _handleNavigate(int index) {
    navigationShell.goBranch(index, initialLocation: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                color: context.colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              );
            }
            return TextStyle(
              color: context.colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(
                color: context.colorScheme.primary,
                size: 26,
              );
            }
            return IconThemeData(
              color: context.colorScheme.onSurfaceVariant,
              size: 24,
            );
          }),
        ),
        child: NavigationBar(
          height: 70,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _handleNavigate,
          destinations: _destination(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      ),
    );
  }
}

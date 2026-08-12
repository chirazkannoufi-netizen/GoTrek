import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/explore/explore_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/home/home_screen.dart';
import '../features/profile/profile_screen.dart';
import '../state/favorites_controller.dart';
import '../state/navigation_controller.dart';

/// The signed-in shell.
///
/// Each tab keeps its own scroll position and state because the four screens
/// live in an [IndexedStack]. The original pushed a new route for every tab
/// tap, which grew the navigator stack without bound and reset each screen.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const List<Widget> _tabs = <Widget>[
    HomeScreen(),
    FavoritesScreen(),
    ExploreScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppTab tab = ref.watch(navigationProvider);
    final int savedCount = ref.watch(favoritesCountProvider);

    return PopScope(
      canPop: tab == AppTab.home,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          ref.read(navigationProvider.notifier).select(AppTab.home);
        }
      },
      child: Scaffold(
        body: IndexedStack(index: tab.index, children: _tabs),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab.index,
          onDestinationSelected:
              ref.read(navigationProvider.notifier).selectIndex,
          destinations: <Widget>[
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Badge.count(
                count: savedCount,
                isLabelVisible: savedCount > 0,
                child: const Icon(Icons.favorite_border),
              ),
              selectedIcon: Badge.count(
                count: savedCount,
                isLabelVisible: savedCount > 0,
                child: const Icon(Icons.favorite),
              ),
              label: 'Saved',
            ),
            const NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Explore',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

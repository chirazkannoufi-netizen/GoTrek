import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tabs of the main shell, in the order they appear in the navigation bar.
enum AppTab { home, saved, explore, profile }

/// Which tab the shell is showing.
///
/// Held in a provider rather than in the shell's own State so that any screen
/// can move the user to another tab — the home search field jumps to Explore,
/// and the empty favourites state sends you back to Home.
class NavigationController extends Notifier<AppTab> {
  @override
  AppTab build() => AppTab.home;

  void select(AppTab tab) => state = tab;

  void selectIndex(int index) => state = AppTab.values[index];
}

final NotifierProvider<NavigationController, AppTab> navigationProvider =
    NotifierProvider<NavigationController, AppTab>(NavigationController.new);

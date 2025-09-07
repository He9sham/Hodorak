import 'package:flutter_riverpod/flutter_riverpod.dart';

// Navigation state for managing tab/page selection
class NavigationState {
  final int currentIndex;

  const NavigationState({this.currentIndex = 0});

  NavigationState copyWith({int? currentIndex}) {
    return NavigationState(currentIndex: currentIndex ?? this.currentIndex);
  }
}

// Navigation provider
class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(const NavigationState());

  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }
}

// Provider instance
final navigationProvider = StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier();
});
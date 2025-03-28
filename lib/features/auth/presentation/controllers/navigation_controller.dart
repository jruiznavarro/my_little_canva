import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_controller.g.dart';

@riverpod
class NavigationController extends _$NavigationController {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
} 
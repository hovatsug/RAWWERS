import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/client.dart';
import '../../data/repositories/flags_repository.dart';

final flagsRepositoryProvider = Provider<FlagsRepository>((ref) {
  return FlagsRepository(ref.watch(apiDioProvider));
});

class FlagsController extends StateNotifier<Map<String, bool>> with WidgetsBindingObserver {
  FlagsController(this._ref) : super(const {}) {
    WidgetsBinding.instance.addObserver(this);
    refresh();
  }

  final Ref _ref;

  bool enabled(String name, {bool fallback = true}) => state[name] ?? fallback;

  Future<void> refresh() async {
    try {
      state = await _ref.read(flagsRepositoryProvider).fetchFlags();
    } on DioException {
      state = const {};
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

final flagsControllerProvider = StateNotifierProvider<FlagsController, Map<String, bool>>((ref) {
  return FlagsController(ref);
});

final flagEnabledProvider = Provider.family<bool, String>((ref, name) {
  final flags = ref.watch(flagsControllerProvider);
  return flags[name] ?? true;
});

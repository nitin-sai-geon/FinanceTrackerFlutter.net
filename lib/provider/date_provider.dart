import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedPeriod {
  final int month;
  final int year;
  const SelectedPeriod(this.month, this.year);
}

final selectedPeriodProvider =
    NotifierProvider<SelectedPeriodNotifier, SelectedPeriod>(
      SelectedPeriodNotifier.new,
    );

class SelectedPeriodNotifier extends Notifier<SelectedPeriod> {
  @override
  SelectedPeriod build() {
    final now = DateTime.now();
    return SelectedPeriod(now.month, now.year);
  }

  void setMonth(int month) => state = SelectedPeriod(month, state.year);
  void setYear(int year) => state = SelectedPeriod(state.month, year);
}

final currentDateProvider = NotifierProvider<CurrentDateNotifier, DateTime>(
  CurrentDateNotifier.new,
);

class CurrentDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final timer = Timer.periodic(const Duration(minutes: 1), (_) {
      state = DateTime.now();
    });
    ref.onDispose(() => timer.cancel());
    return DateTime.now();
  }

  void refresh() => state = DateTime.now();
}

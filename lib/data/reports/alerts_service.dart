// Named constructor parameters cannot be private, hence the initializer list.
// ignore_for_file: prefer_initializing_formals

import '../../domain/alerts_calc.dart';
import '../../domain/dates.dart';
import '../repositories/days_repository.dart';
import '../repositories/expenses_repository.dart';
import '../repositories/fixed_costs_repository.dart';
import '../repositories/periods_repository.dart';
import '../repositories/settings_repository.dart';

/// Computes the alerts that currently apply. Nothing is stored.
class AlertsService {
  AlertsService({
    required DaysRepository days,
    required ExpensesRepository expenses,
    required PeriodsRepository periods,
    required SettingsRepository settings,
    required FixedCostsRepository fixedCosts,
    required DateTime Function() clock,
  }) : _days = days,
       _expenses = expenses,
       _periods = periods,
       _settings = settings,
       _fixedCosts = fixedCosts,
       _clock = clock;

  final DaysRepository _days;
  final ExpensesRepository _expenses;
  final PeriodsRepository _periods;
  final SettingsRepository _settings;
  final FixedCostsRepository _fixedCosts;
  final DateTime Function() _clock;

  /// Alerts as of [today] (defaults to the clock). Generates the fixed costs
  /// that are due first.
  Future<List<Alert>> current([DateTime? today]) async {
    final day = dateOnly(today ?? _clock());
    await _fixedCosts.generateDue(day);
    final snapshots = await _days.snapshots(DateRange(DateTime.utc(2000), day));
    return computeAlerts(
      AlertInputs(
        today: day,
        days: snapshots,
        expenses: await _expenses.snapshots(),
        closedMonths: await _periods.watchClosed().first,
        lastBackup: await _settings.lastBackupAt(),
      ),
    );
  }
}

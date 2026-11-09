import 'package:flutter/widgets.dart' show ValueKey;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/providers.dart';
import 'features/alerts/alerts_screen.dart';
import 'features/backup/backup_screen.dart';
import 'features/calendar/calendar_screen.dart';
import 'features/day_close/day_close_screen.dart';
import 'features/expenses/expense_form_screen.dart';
import 'features/expenses/expenses_list_screen.dart';
import 'features/fixed_costs/fixed_costs_screen.dart';
import 'features/history/history_screen.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_flow.dart';
import 'features/payroll/payroll_screen.dart';
import 'features/reports/reports_screen.dart';
import 'features/settings/catalog_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/suppliers/suppliers_screen.dart';
import 'features/withdrawals/withdrawals_screen.dart';

/// Sends everyone to `/onboarding` until the first run is finished (and away
/// from it afterwards).
Future<String?> onboardingRedirect(Ref ref, GoRouterState state) async {
  final done = await ref.read(settingsRepositoryProvider).onboardingDone();
  final onOnboarding = state.matchedLocation == '/onboarding';
  if (!done && !onOnboarding) return '/onboarding';
  if (done && onOnboarding) return '/';
  return null;
}

GoRouter buildRouter(Ref ref, {String initialLocation = '/'}) => GoRouter(
  initialLocation: initialLocation,
  redirect: (context, state) => onboardingRedirect(ref, state),
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingFlow(),
    ),
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/calendar',
      builder: (context, state) => const CalendarScreen(),
    ),
    GoRoute(
      path: '/day/:ymd',
      builder: (context, state) {
        final ymd = state.pathParameters['ymd']!;
        // Keyed by date so going to the next day starts from a fresh form.
        return DayCloseScreen(key: ValueKey(ymd), ymd: ymd);
      },
    ),
    GoRoute(
      path: '/expenses',
      builder: (context, state) => const ExpensesListScreen(),
      routes: [
        // Before ':id', so "new" is not read as an id.
        GoRoute(
          path: 'new',
          builder: (context, state) => const ExpenseFormScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ExpenseFormScreen(key: ValueKey(id), id: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/suppliers',
      builder: (context, state) => const SuppliersScreen(),
    ),
    GoRoute(
      path: '/fixed-costs',
      builder: (context, state) => const FixedCostsScreen(),
    ),
    GoRoute(
      path: '/payroll/:month',
      builder: (context, state) =>
          PayrollScreen(month: state.pathParameters['month']!),
    ),
    GoRoute(
      path: '/withdrawals',
      builder: (context, state) => const WithdrawalsScreen(),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsScreen(),
    ),
    GoRoute(path: '/alerts', builder: (context, state) => const AlertsScreen()),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
      routes: [
        GoRoute(
          path: 'catalogs/:kind',
          builder: (context, state) =>
              CatalogScreen(kind: state.pathParameters['kind']!),
        ),
      ],
    ),
    GoRoute(path: '/backup', builder: (context, state) => const BackupScreen()),
  ],
);

/// The app router. It reads (not watches) the repositories, so a restore does
/// not reset the navigation.
final routerProvider = Provider<GoRouter>((ref) {
  final router = buildRouter(ref);
  ref.onDispose(router.dispose);
  return router;
});

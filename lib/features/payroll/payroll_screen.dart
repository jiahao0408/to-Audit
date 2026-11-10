// Re-export for backward compatibility with the router.
export 'payroll_month_screen.dart' show PayrollMonthScreen;

import 'payroll_month_screen.dart';

/// Alias kept so the existing router import still compiles.
class PayrollScreen extends PayrollMonthScreen {
  const PayrollScreen({super.key, required super.month});
}

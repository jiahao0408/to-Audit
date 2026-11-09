import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/cash_calc.dart';
import '../../domain/money.dart';
import '../../l10n/app_localizations.dart';

/// One field per banknote and coin, with a running total. Reports the whole
/// map of counts (denomination in cents -> pieces) on every change.
class DenominationCounter extends StatefulWidget {
  const DenominationCounter({
    super.key,
    required this.initialCounts,
    required this.locale,
    required this.onChanged,
  });

  final Map<int, int> initialCounts;
  final String locale;
  final ValueChanged<Map<int, int>> onChanged;

  @override
  State<DenominationCounter> createState() => _DenominationCounterState();
}

class _DenominationCounterState extends State<DenominationCounter> {
  late final Map<int, int> _counts = Map.of(widget.initialCounts);

  void _set(int denomination, String text) {
    setState(() => _counts[denomination] = int.tryParse(text) ?? 0);
    widget.onChanged(Map.of(_counts));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final total = countDenominations(_counts);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final denomination in euroDenominations)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(Money(denomination).format(widget.locale)),
                ),
                SizedBox(
                  width: 96,
                  child: TextFormField(
                    key: ValueKey('denom-$denomination'),
                    initialValue: (_counts[denomination] ?? 0) > 0
                        ? '${_counts[denomination]}'
                        : null,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5),
                    ],
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(hintText: '0'),
                    onChanged: (text) => _set(denomination, text),
                  ),
                ),
                SizedBox(
                  width: 104,
                  child: Text(
                    Money(denomination * (_counts[denomination] ?? 0))
                        .format(widget.locale),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        const Divider(),
        Row(
          children: [
            Expanded(
              child: Text(
                l.dayCountedCashValue,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              total.format(widget.locale),
              key: const ValueKey('denom-total'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ],
    );
  }
}

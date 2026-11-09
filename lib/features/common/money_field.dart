import 'package:flutter/material.dart';

import '../../domain/money.dart';
import '../../l10n/app_localizations.dart';

/// Text form field for a euro amount. Accepts `12,5` and `12.50`; anything
/// [Money.parse] rejects (negatives, letters, thousands separators) is a
/// validation error and reports `null` through [onChanged].
class MoneyField extends StatelessWidget {
  const MoneyField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.required = true,
    this.onChanged,
    this.textInputAction,
  });

  final String label;
  final TextEditingController? controller;

  /// Used only when no [controller] is given.
  final Money? initialValue;

  /// An empty field is invalid when true and valid when false.
  final bool required;
  final ValueChanged<Money?>? onChanged;
  final TextInputAction? textInputAction;

  /// Plain text for [value], such as `12,05`, to preload a field.
  static String text(Money value) {
    final cents = value.cents.abs();
    final sign = value.isNegative ? '-' : '';
    return '$sign${cents ~/ 100},${(cents % 100).toString().padLeft(2, '0')}';
  }

  static Money? _tryParse(String? text) {
    try {
      return Money.parse(text ?? '');
    } on FormatException {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      initialValue: controller == null && initialValue != null
          ? text(initialValue!)
          : null,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: textInputAction,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if ((value ?? '').trim().isEmpty) {
          return required ? l.fieldRequired : null;
        }
        return _tryParse(value) == null ? l.amountInvalid : null;
      },
      onChanged: onChanged == null
          ? null
          : (value) => onChanged!(_tryParse(value)),
    );
  }
}

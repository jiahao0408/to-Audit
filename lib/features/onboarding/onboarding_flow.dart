import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/money.dart';
import '../../l10n/app_localizations.dart';
import '../common/money_field.dart';
import '../lock/app_lock_controller.dart';
import '../lock/lock_screen.dart' show hasPinProvider;

enum _Step { language, restaurant, pin, biometrics, float }

/// First run (spec 6.1): language, restaurant, PIN (twice, with the warning
/// about forgetting it), biometrics when the phone has them, opening float.
///
/// Only the language is stored while going through the steps. Everything else
/// is written together on the last one, with the PIN and `onboarding_done`
/// last, so an interrupted first run leaves no PIN behind and starts over.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _restaurantForm = GlobalKey<FormState>();
  final _pinForm = GlobalKey<FormState>();
  final _floatForm = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _nif = TextEditingController();
  final _address = TextEditingController();
  final _pin = TextEditingController();
  final _pinRepeat = TextEditingController();
  final _float = TextEditingController();

  int _index = 0;
  bool _biometricsAvailable = false;
  bool _biometricsOn = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    ref.read(biometricProvider).isAvailable().then((available) {
      if (mounted) setState(() => _biometricsAvailable = available);
    });
  }

  @override
  void dispose() {
    for (final c in [_name, _nif, _address, _pin, _pinRepeat, _float]) {
      c.dispose();
    }
    super.dispose();
  }

  List<_Step> get _steps => [
    _Step.language,
    _Step.restaurant,
    _Step.pin,
    if (_biometricsAvailable) _Step.biometrics,
    _Step.float,
  ];

  _Step get _step => _steps[_index.clamp(0, _steps.length - 1)];

  bool get _isLast => _index >= _steps.length - 1;

  void _next() {
    final valid = switch (_step) {
      _Step.restaurant => _restaurantForm.currentState!.validate(),
      _Step.pin => _pinForm.currentState!.validate(),
      _ => true,
    };
    if (!valid) return;
    setState(() => _index++);
  }

  void _back() => setState(() {
    _error = null;
    _index--;
  });

  Future<void> _chooseLanguage(String code) =>
      ref.read(settingsRepositoryProvider).setLocale(code);

  Future<void> _toggleBiometrics(bool enable) async {
    if (!enable) {
      setState(() => _biometricsOn = false);
      return;
    }
    final l = AppLocalizations.of(context)!;
    final ok = await ref
        .read(biometricProvider)
        .authenticate(l.biometricReason);
    if (!mounted) return;
    setState(() {
      _biometricsOn = ok;
      _error = ok ? null : l.onbBiometricsFailed;
    });
  }

  Future<void> _finish() async {
    if (!_floatForm.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final l = AppLocalizations.of(context)!;
    try {
      final settings = ref.read(settingsRepositoryProvider);
      await settings.setLocale(ref.read(localeProvider).value ?? 'es');
      await settings.setRestaurant(
        RestaurantInfo(
          name: _name.text.trim(),
          nif: _nif.text.trim(),
          address: _address.text.trim(),
        ),
      );
      await settings.setInitialFloat(Money.parse(_float.text));
      await settings.setBiometricsEnabled(_biometricsOn);
      await ref.read(pinManagerProvider).setPin(_pin.text);
      await settings.setOnboardingDone();
      ref.invalidate(hasPinProvider);
      ref.read(appLockProvider.notifier).unlock();
      if (mounted) context.go('/');
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = l.onbSaveError;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.appTitle), automaticallyImplyLeading: false),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.onbStep(_index + 1, _steps.length),
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  _content(l),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (_index > 0)
                        OutlinedButton(
                          onPressed: _saving ? null : _back,
                          child: Text(l.actionBack),
                        ),
                      const Spacer(),
                      FilledButton(
                        key: const ValueKey('onboarding-next'),
                        onPressed: _saving ? null : (_isLast ? _finish : _next),
                        child: Text(_isLast ? l.onbFinish : l.actionContinue),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(AppLocalizations l) => switch (_step) {
    _Step.language => _languageStep(l),
    _Step.restaurant => _restaurantStep(l),
    _Step.pin => _pinStep(l),
    _Step.biometrics => _biometricsStep(l),
    _Step.float => _floatStep(l),
  };

  Widget _title(String text) =>
      Text(text, style: Theme.of(context).textTheme.headlineSmall);

  Widget _languageStep(AppLocalizations l) {
    final current = ref.watch(localeProvider).value ?? 'es';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title(l.onbLanguageTitle),
        const SizedBox(height: 16),
        RadioGroup<String>(
          groupValue: current,
          onChanged: (code) {
            if (code != null) _chooseLanguage(code);
          },
          child: Column(
            children: [
              RadioListTile<String>(
                key: const ValueKey('language-es'),
                value: 'es',
                title: Text(l.languageEs),
              ),
              RadioListTile<String>(
                key: const ValueKey('language-zh'),
                value: 'zh',
                title: Text(l.languageZh),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _restaurantStep(AppLocalizations l) => Form(
    key: _restaurantForm,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title(l.onbRestaurantTitle),
        const SizedBox(height: 16),
        TextFormField(
          key: const ValueKey('restaurant-name'),
          controller: _name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(labelText: l.restaurantName),
          validator: (v) => (v ?? '').trim().isEmpty ? l.fieldRequired : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: const ValueKey('restaurant-nif'),
          controller: _nif,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(labelText: l.restaurantNif),
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: const ValueKey('restaurant-address'),
          controller: _address,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l.restaurantAddress),
        ),
      ],
    ),
  );

  Widget _pinStep(AppLocalizations l) => Form(
    key: _pinForm,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title(l.onbPinTitle),
        const SizedBox(height: 16),
        _pinField(
          const ValueKey('pin-create'),
          _pin,
          l.onbPinCreateLabel,
          (v) => RegExp(r'^\d{6}$').hasMatch(v ?? '') ? null : l.onbPinInvalid,
        ),
        const SizedBox(height: 12),
        _pinField(
          const ValueKey('pin-repeat'),
          _pinRepeat,
          l.onbPinConfirmLabel,
          (v) => v == _pin.text ? null : l.onbPinMismatch,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: 12),
                Expanded(child: Text(l.onbPinWarning)),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _pinField(
    Key key,
    TextEditingController controller,
    String label,
    String? Function(String?) validator,
  ) => TextFormField(
    key: key,
    controller: controller,
    obscureText: true,
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(6),
    ],
    decoration: InputDecoration(labelText: label),
    validator: validator,
  );

  Widget _biometricsStep(AppLocalizations l) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _title(l.onbBiometricsTitle),
      const SizedBox(height: 16),
      Text(l.onbBiometricsBody),
      const SizedBox(height: 16),
      SwitchListTile(
        key: const ValueKey('biometrics-switch'),
        value: _biometricsOn,
        onChanged: _toggleBiometrics,
        title: Text(l.onbBiometricsEnable),
      ),
    ],
  );

  Widget _floatStep(AppLocalizations l) => Form(
    key: _floatForm,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title(l.onbFloatTitle),
        const SizedBox(height: 8),
        Text(l.onbFloatBody),
        const SizedBox(height: 16),
        MoneyField(
          key: const ValueKey('initial-float'),
          controller: _float,
          label: l.onbFloatLabel,
        ),
      ],
    ),
  );
}

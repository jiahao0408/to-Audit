import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('es'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'to Audit'**
  String get appTitle;

  /// No description provided for @actionCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get actionCancel;

  /// No description provided for @actionAccept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get actionAccept;

  /// No description provided for @actionContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get actionContinue;

  /// No description provided for @actionBack.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get actionBack;

  /// No description provided for @actionRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get actionRetry;

  /// No description provided for @screenHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get screenHome;

  /// No description provided for @screenCalendar.
  ///
  /// In es, this message translates to:
  /// **'Calendario'**
  String get screenCalendar;

  /// No description provided for @screenDay.
  ///
  /// In es, this message translates to:
  /// **'Día'**
  String get screenDay;

  /// No description provided for @screenExpenses.
  ///
  /// In es, this message translates to:
  /// **'Gastos'**
  String get screenExpenses;

  /// No description provided for @screenExpenseNew.
  ///
  /// In es, this message translates to:
  /// **'Nuevo gasto'**
  String get screenExpenseNew;

  /// No description provided for @screenExpenseDetail.
  ///
  /// In es, this message translates to:
  /// **'Gasto'**
  String get screenExpenseDetail;

  /// No description provided for @screenSuppliers.
  ///
  /// In es, this message translates to:
  /// **'Proveedores'**
  String get screenSuppliers;

  /// No description provided for @screenFixedCosts.
  ///
  /// In es, this message translates to:
  /// **'Gastos fijos'**
  String get screenFixedCosts;

  /// No description provided for @screenPayroll.
  ///
  /// In es, this message translates to:
  /// **'Nóminas'**
  String get screenPayroll;

  /// No description provided for @screenWithdrawals.
  ///
  /// In es, this message translates to:
  /// **'Retiradas de caja'**
  String get screenWithdrawals;

  /// No description provided for @screenReports.
  ///
  /// In es, this message translates to:
  /// **'Informes'**
  String get screenReports;

  /// No description provided for @screenAlerts.
  ///
  /// In es, this message translates to:
  /// **'Alertas'**
  String get screenAlerts;

  /// No description provided for @screenHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial de cambios'**
  String get screenHistory;

  /// No description provided for @screenSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get screenSettings;

  /// No description provided for @screenCatalogs.
  ///
  /// In es, this message translates to:
  /// **'Catálogos'**
  String get screenCatalogs;

  /// No description provided for @screenBackup.
  ///
  /// In es, this message translates to:
  /// **'Copia de seguridad'**
  String get screenBackup;

  /// No description provided for @fieldRequired.
  ///
  /// In es, this message translates to:
  /// **'Obligatorio'**
  String get fieldRequired;

  /// No description provided for @amountInvalid.
  ///
  /// In es, this message translates to:
  /// **'Importe no válido'**
  String get amountInvalid;

  /// No description provided for @reasonLabel.
  ///
  /// In es, this message translates to:
  /// **'Motivo'**
  String get reasonLabel;

  /// No description provided for @reasonRequired.
  ///
  /// In es, this message translates to:
  /// **'Escribe un motivo'**
  String get reasonRequired;

  /// No description provided for @lockTitle.
  ///
  /// In es, this message translates to:
  /// **'Introduce tu PIN'**
  String get lockTitle;

  /// No description provided for @pinDelete.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get pinDelete;

  /// No description provided for @pinWrong.
  ///
  /// In es, this message translates to:
  /// **'PIN incorrecto. Intentos antes del bloqueo: {attempts}'**
  String pinWrong(int attempts);

  /// No description provided for @pinLockedSeconds.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos. Espera {seconds} s.'**
  String pinLockedSeconds(int seconds);

  /// No description provided for @pinLockedMinutes.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos. Espera {minutes} min.'**
  String pinLockedMinutes(int minutes);

  /// No description provided for @pinUseBiometrics.
  ///
  /// In es, this message translates to:
  /// **'Usar huella o rostro'**
  String get pinUseBiometrics;

  /// No description provided for @pinCheckError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo comprobar el PIN'**
  String get pinCheckError;

  /// No description provided for @biometricReason.
  ///
  /// In es, this message translates to:
  /// **'Desbloquea to Audit'**
  String get biometricReason;

  /// No description provided for @authPinTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirma con tu PIN'**
  String get authPinTitle;

  /// No description provided for @onbStep.
  ///
  /// In es, this message translates to:
  /// **'Paso {current} de {total}'**
  String onbStep(int current, int total);

  /// No description provided for @onbLanguageTitle.
  ///
  /// In es, this message translates to:
  /// **'Elige el idioma'**
  String get onbLanguageTitle;

  /// No description provided for @languageEs.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get languageEs;

  /// No description provided for @languageZh.
  ///
  /// In es, this message translates to:
  /// **'中文'**
  String get languageZh;

  /// No description provided for @onbRestaurantTitle.
  ///
  /// In es, this message translates to:
  /// **'Datos del restaurante'**
  String get onbRestaurantTitle;

  /// No description provided for @restaurantName.
  ///
  /// In es, this message translates to:
  /// **'Nombre del restaurante'**
  String get restaurantName;

  /// No description provided for @restaurantNif.
  ///
  /// In es, this message translates to:
  /// **'NIF'**
  String get restaurantNif;

  /// No description provided for @restaurantAddress.
  ///
  /// In es, this message translates to:
  /// **'Dirección'**
  String get restaurantAddress;

  /// No description provided for @onbPinTitle.
  ///
  /// In es, this message translates to:
  /// **'Crea tu PIN'**
  String get onbPinTitle;

  /// No description provided for @onbPinCreateLabel.
  ///
  /// In es, this message translates to:
  /// **'PIN de 6 dígitos'**
  String get onbPinCreateLabel;

  /// No description provided for @onbPinConfirmLabel.
  ///
  /// In es, this message translates to:
  /// **'Repite el PIN'**
  String get onbPinConfirmLabel;

  /// No description provided for @onbPinInvalid.
  ///
  /// In es, this message translates to:
  /// **'El PIN debe tener exactamente 6 dígitos'**
  String get onbPinInvalid;

  /// No description provided for @onbPinMismatch.
  ///
  /// In es, this message translates to:
  /// **'Los PIN no coinciden'**
  String get onbPinMismatch;

  /// No description provided for @onbPinWarning.
  ///
  /// In es, this message translates to:
  /// **'Si olvidas el PIN y no tienes biometría activada, la única forma de volver a entrar es reinstalar la app y restaurar una copia de seguridad. Haz copias con regularidad.'**
  String get onbPinWarning;

  /// No description provided for @onbBiometricsTitle.
  ///
  /// In es, this message translates to:
  /// **'Huella o rostro'**
  String get onbBiometricsTitle;

  /// No description provided for @onbBiometricsBody.
  ///
  /// In es, this message translates to:
  /// **'Puedes desbloquear la app con la biometría de tu móvil. El PIN seguirá siendo el respaldo.'**
  String get onbBiometricsBody;

  /// No description provided for @onbBiometricsEnable.
  ///
  /// In es, this message translates to:
  /// **'Activar biometría'**
  String get onbBiometricsEnable;

  /// No description provided for @onbBiometricsFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo activar la biometría'**
  String get onbBiometricsFailed;

  /// No description provided for @onbFloatTitle.
  ///
  /// In es, this message translates to:
  /// **'Fondo de caja inicial'**
  String get onbFloatTitle;

  /// No description provided for @onbFloatBody.
  ///
  /// In es, this message translates to:
  /// **'Dinero que hay en caja al empezar el primer día.'**
  String get onbFloatBody;

  /// No description provided for @onbFloatLabel.
  ///
  /// In es, this message translates to:
  /// **'Fondo de caja (€)'**
  String get onbFloatLabel;

  /// No description provided for @onbFinish.
  ///
  /// In es, this message translates to:
  /// **'Empezar'**
  String get onbFinish;

  /// No description provided for @onbSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar. Inténtalo de nuevo.'**
  String get onbSaveError;

  /// No description provided for @keyMissingTitle.
  ///
  /// In es, this message translates to:
  /// **'No se puede abrir la base de datos'**
  String get keyMissingTitle;

  /// No description provided for @keyMissingBody.
  ///
  /// In es, this message translates to:
  /// **'La clave de cifrado de este dispositivo no está disponible. Tus datos no se han modificado. Restaura una copia de seguridad para continuar.'**
  String get keyMissingBody;

  /// No description provided for @restoreBackupButton.
  ///
  /// In es, this message translates to:
  /// **'Restaurar copia'**
  String get restoreBackupButton;

  /// No description provided for @startupErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar la app'**
  String get startupErrorTitle;

  /// No description provided for @startupErrorBody.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir la base de datos. Cierra la app y vuelve a abrirla. Si el problema continúa, restaura una copia de seguridad.'**
  String get startupErrorBody;

  /// No description provided for @homeMonthSales.
  ///
  /// In es, this message translates to:
  /// **'Ventas del mes'**
  String get homeMonthSales;

  /// No description provided for @homeProfit.
  ///
  /// In es, this message translates to:
  /// **'Beneficio acumulado'**
  String get homeProfit;

  /// No description provided for @homeProfitUntil.
  ///
  /// In es, this message translates to:
  /// **'Hasta el último día cerrado ({date})'**
  String homeProfitUntil(String date);

  /// No description provided for @homeProfitNone.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay días cerrados'**
  String get homeProfitNone;

  /// No description provided for @homeRegisterNext.
  ///
  /// In es, this message translates to:
  /// **'Registrar siguiente día pendiente'**
  String get homeRegisterNext;

  /// No description provided for @homeAllUpToDate.
  ///
  /// In es, this message translates to:
  /// **'Todos los días están al día'**
  String get homeAllUpToDate;

  /// No description provided for @homeAlertsCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin alertas} one{1 alerta} other{{count} alertas}}'**
  String homeAlertsCount(int count);

  /// No description provided for @homeBackupBannerNever.
  ///
  /// In es, this message translates to:
  /// **'Aún no has hecho ninguna copia de seguridad'**
  String get homeBackupBannerNever;

  /// No description provided for @homeBackupBannerDays.
  ///
  /// In es, this message translates to:
  /// **'{days, plural, one{Tu última copia de seguridad fue hace 1 día} other{Tu última copia de seguridad fue hace {days} días}}'**
  String homeBackupBannerDays(int days);

  /// No description provided for @homeBackupAction.
  ///
  /// In es, this message translates to:
  /// **'Hacer copia'**
  String get homeBackupAction;

  /// No description provided for @homeBackupDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Copia de seguridad pendiente'**
  String get homeBackupDialogTitle;

  /// No description provided for @homeBackupDialogBody.
  ///
  /// In es, this message translates to:
  /// **'Hace mucho tiempo que no haces una copia de seguridad. Si pierdes o cambias de móvil, perderás tus datos.'**
  String get homeBackupDialogBody;

  /// No description provided for @homeBackupDialogLater.
  ///
  /// In es, this message translates to:
  /// **'Más tarde'**
  String get homeBackupDialogLater;

  /// No description provided for @homeBackupDialogNow.
  ///
  /// In es, this message translates to:
  /// **'Hacer copia ahora'**
  String get homeBackupDialogNow;

  /// No description provided for @homeLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los datos'**
  String get homeLoadError;

  /// No description provided for @calendarPrevMonth.
  ///
  /// In es, this message translates to:
  /// **'Mes anterior'**
  String get calendarPrevMonth;

  /// No description provided for @calendarNextMonth.
  ///
  /// In es, this message translates to:
  /// **'Mes siguiente'**
  String get calendarNextMonth;

  /// No description provided for @dayStateUnregistered.
  ///
  /// In es, this message translates to:
  /// **'Sin registrar'**
  String get dayStateUnregistered;

  /// No description provided for @dayStateOpen.
  ///
  /// In es, this message translates to:
  /// **'Abierto'**
  String get dayStateOpen;

  /// No description provided for @dayStateBalanced.
  ///
  /// In es, this message translates to:
  /// **'Cuadrado'**
  String get dayStateBalanced;

  /// No description provided for @dayStateDiscrepancy.
  ///
  /// In es, this message translates to:
  /// **'Descuadre'**
  String get dayStateDiscrepancy;

  /// No description provided for @dayStateNoActivity.
  ///
  /// In es, this message translates to:
  /// **'Sin actividad'**
  String get dayStateNoActivity;

  /// No description provided for @dayStateFuture.
  ///
  /// In es, this message translates to:
  /// **'Futuro'**
  String get dayStateFuture;

  /// No description provided for @dayCellLabel.
  ///
  /// In es, this message translates to:
  /// **'{date}: {state}'**
  String dayCellLabel(String date, String state);

  /// No description provided for @markNoActivity.
  ///
  /// In es, this message translates to:
  /// **'Marcar sin actividad'**
  String get markNoActivity;

  /// No description provided for @markNoActivityDone.
  ///
  /// In es, this message translates to:
  /// **'Día marcado sin actividad'**
  String get markNoActivityDone;

  /// No description provided for @markNoActivityError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo marcar el día'**
  String get markNoActivityError;

  /// No description provided for @catalog_cash.
  ///
  /// In es, this message translates to:
  /// **'Efectivo'**
  String get catalog_cash;

  /// No description provided for @catalog_card.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta CaixaBank'**
  String get catalog_card;

  /// No description provided for @catalog_bizum.
  ///
  /// In es, this message translates to:
  /// **'Bizum'**
  String get catalog_bizum;

  /// No description provided for @catalog_vouchers.
  ///
  /// In es, this message translates to:
  /// **'Vales'**
  String get catalog_vouchers;

  /// No description provided for @catalog_glovo.
  ///
  /// In es, this message translates to:
  /// **'Glovo'**
  String get catalog_glovo;

  /// No description provided for @catalog_justeat.
  ///
  /// In es, this message translates to:
  /// **'Just Eat'**
  String get catalog_justeat;

  /// No description provided for @catalog_ubereats.
  ///
  /// In es, this message translates to:
  /// **'Uber Eats'**
  String get catalog_ubereats;

  /// No description provided for @catalog_meat.
  ///
  /// In es, this message translates to:
  /// **'Carne'**
  String get catalog_meat;

  /// No description provided for @catalog_fish.
  ///
  /// In es, this message translates to:
  /// **'Pescado'**
  String get catalog_fish;

  /// No description provided for @catalog_vegetables.
  ///
  /// In es, this message translates to:
  /// **'Verdura'**
  String get catalog_vegetables;

  /// No description provided for @catalog_drinks.
  ///
  /// In es, this message translates to:
  /// **'Bebidas'**
  String get catalog_drinks;

  /// No description provided for @catalog_groceries.
  ///
  /// In es, this message translates to:
  /// **'Alimentación'**
  String get catalog_groceries;

  /// No description provided for @catalog_cleaning.
  ///
  /// In es, this message translates to:
  /// **'Limpieza'**
  String get catalog_cleaning;

  /// No description provided for @catalog_utilities.
  ///
  /// In es, this message translates to:
  /// **'Suministros'**
  String get catalog_utilities;

  /// No description provided for @catalog_rent.
  ///
  /// In es, this message translates to:
  /// **'Alquiler'**
  String get catalog_rent;

  /// No description provided for @catalog_insurance.
  ///
  /// In es, this message translates to:
  /// **'Seguros'**
  String get catalog_insurance;

  /// No description provided for @catalog_selfemployed.
  ///
  /// In es, this message translates to:
  /// **'Autónomos'**
  String get catalog_selfemployed;

  /// No description provided for @catalog_advisor.
  ///
  /// In es, this message translates to:
  /// **'Gestoría'**
  String get catalog_advisor;

  /// No description provided for @catalog_other.
  ///
  /// In es, this message translates to:
  /// **'Otros'**
  String get catalog_other;

  /// No description provided for @catalog_bank_deposit.
  ///
  /// In es, this message translates to:
  /// **'Ingreso en banco'**
  String get catalog_bank_deposit;

  /// No description provided for @catalog_owner.
  ///
  /// In es, this message translates to:
  /// **'Retirada del dueño'**
  String get catalog_owner;

  /// No description provided for @catalog_cash_payment.
  ///
  /// In es, this message translates to:
  /// **'Pago en mano'**
  String get catalog_cash_payment;

  /// No description provided for @catalog_change.
  ///
  /// In es, this message translates to:
  /// **'Cambio'**
  String get catalog_change;

  /// No description provided for @export_sheetSummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen'**
  String get export_sheetSummary;

  /// No description provided for @export_sheetDays.
  ///
  /// In es, this message translates to:
  /// **'Días'**
  String get export_sheetDays;

  /// No description provided for @export_sheetSales.
  ///
  /// In es, this message translates to:
  /// **'Ventas'**
  String get export_sheetSales;

  /// No description provided for @export_sheetExpenses.
  ///
  /// In es, this message translates to:
  /// **'Gastos'**
  String get export_sheetExpenses;

  /// No description provided for @export_sheetPayroll.
  ///
  /// In es, this message translates to:
  /// **'Nóminas'**
  String get export_sheetPayroll;

  /// No description provided for @export_sheetWithdrawals.
  ///
  /// In es, this message translates to:
  /// **'Retiradas'**
  String get export_sheetWithdrawals;

  /// No description provided for @export_colConcept.
  ///
  /// In es, this message translates to:
  /// **'Concepto'**
  String get export_colConcept;

  /// No description provided for @export_colAmount.
  ///
  /// In es, this message translates to:
  /// **'Importe'**
  String get export_colAmount;

  /// No description provided for @export_colDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get export_colDate;

  /// No description provided for @export_colStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get export_colStatus;

  /// No description provided for @export_colSales.
  ///
  /// In es, this message translates to:
  /// **'Ventas'**
  String get export_colSales;

  /// No description provided for @export_colCovers.
  ///
  /// In es, this message translates to:
  /// **'Comensales'**
  String get export_colCovers;

  /// No description provided for @export_colExpenses.
  ///
  /// In es, this message translates to:
  /// **'Gastos'**
  String get export_colExpenses;

  /// No description provided for @export_colCashDiff.
  ///
  /// In es, this message translates to:
  /// **'Descuadre efectivo'**
  String get export_colCashDiff;

  /// No description provided for @export_colCardDiff.
  ///
  /// In es, this message translates to:
  /// **'Descuadre tarjeta'**
  String get export_colCardDiff;

  /// No description provided for @export_colPaymentMethod.
  ///
  /// In es, this message translates to:
  /// **'Forma de pago'**
  String get export_colPaymentMethod;

  /// No description provided for @export_colSupplier.
  ///
  /// In es, this message translates to:
  /// **'Proveedor'**
  String get export_colSupplier;

  /// No description provided for @export_colInvoice.
  ///
  /// In es, this message translates to:
  /// **'Nº factura'**
  String get export_colInvoice;

  /// No description provided for @export_colCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get export_colCategory;

  /// No description provided for @export_colBase.
  ///
  /// In es, this message translates to:
  /// **'Base imponible'**
  String get export_colBase;

  /// No description provided for @export_colVatPct.
  ///
  /// In es, this message translates to:
  /// **'IVA %'**
  String get export_colVatPct;

  /// No description provided for @export_colVat.
  ///
  /// In es, this message translates to:
  /// **'IVA'**
  String get export_colVat;

  /// No description provided for @export_colTotal.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get export_colTotal;

  /// No description provided for @export_colPayment.
  ///
  /// In es, this message translates to:
  /// **'Pago'**
  String get export_colPayment;

  /// No description provided for @export_colReceipts.
  ///
  /// In es, this message translates to:
  /// **'Justificantes'**
  String get export_colReceipts;

  /// No description provided for @export_colEmployee.
  ///
  /// In es, this message translates to:
  /// **'Empleado'**
  String get export_colEmployee;

  /// No description provided for @export_colRole.
  ///
  /// In es, this message translates to:
  /// **'Puesto'**
  String get export_colRole;

  /// No description provided for @export_colMonth.
  ///
  /// In es, this message translates to:
  /// **'Mes'**
  String get export_colMonth;

  /// No description provided for @export_colGross.
  ///
  /// In es, this message translates to:
  /// **'Bruto'**
  String get export_colGross;

  /// No description provided for @export_colNet.
  ///
  /// In es, this message translates to:
  /// **'Neto'**
  String get export_colNet;

  /// No description provided for @export_colEmployerSs.
  ///
  /// In es, this message translates to:
  /// **'SS empresa'**
  String get export_colEmployerSs;

  /// No description provided for @export_colWithdrawalType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de retirada'**
  String get export_colWithdrawalType;

  /// No description provided for @export_reportTitle.
  ///
  /// In es, this message translates to:
  /// **'Informe de gestión'**
  String get export_reportTitle;

  /// No description provided for @export_restaurantNif.
  ///
  /// In es, this message translates to:
  /// **'NIF'**
  String get export_restaurantNif;

  /// No description provided for @export_period.
  ///
  /// In es, this message translates to:
  /// **'Período'**
  String get export_period;

  /// No description provided for @export_generatedOn.
  ///
  /// In es, this message translates to:
  /// **'Generado el'**
  String get export_generatedOn;

  /// No description provided for @export_totalSales.
  ///
  /// In es, this message translates to:
  /// **'Ventas totales'**
  String get export_totalSales;

  /// No description provided for @export_totalPurchases.
  ///
  /// In es, this message translates to:
  /// **'Compras'**
  String get export_totalPurchases;

  /// No description provided for @export_totalFixedCosts.
  ///
  /// In es, this message translates to:
  /// **'Gastos fijos'**
  String get export_totalFixedCosts;

  /// No description provided for @export_totalOtherExpenses.
  ///
  /// In es, this message translates to:
  /// **'Otros gastos'**
  String get export_totalOtherExpenses;

  /// No description provided for @export_totalExpenses.
  ///
  /// In es, this message translates to:
  /// **'Gastos totales'**
  String get export_totalExpenses;

  /// No description provided for @export_totalPayroll.
  ///
  /// In es, this message translates to:
  /// **'Personal'**
  String get export_totalPayroll;

  /// No description provided for @export_totalWithdrawals.
  ///
  /// In es, this message translates to:
  /// **'Retiradas de caja'**
  String get export_totalWithdrawals;

  /// No description provided for @export_totalCashDiscrepancy.
  ///
  /// In es, this message translates to:
  /// **'Descuadre de efectivo'**
  String get export_totalCashDiscrepancy;

  /// No description provided for @export_totalCardDiscrepancy.
  ///
  /// In es, this message translates to:
  /// **'Descuadre de tarjeta'**
  String get export_totalCardDiscrepancy;

  /// No description provided for @export_pendingFixed.
  ///
  /// In es, this message translates to:
  /// **'Fijos pendientes de confirmar'**
  String get export_pendingFixed;

  /// No description provided for @export_vatPaid.
  ///
  /// In es, this message translates to:
  /// **'IVA soportado'**
  String get export_vatPaid;

  /// No description provided for @export_averageTicket.
  ///
  /// In es, this message translates to:
  /// **'Ticket medio'**
  String get export_averageTicket;

  /// No description provided for @export_profit.
  ///
  /// In es, this message translates to:
  /// **'Beneficio'**
  String get export_profit;

  /// No description provided for @export_dailyDetail.
  ///
  /// In es, this message translates to:
  /// **'Detalle diario'**
  String get export_dailyDetail;

  /// No description provided for @export_statusOpen.
  ///
  /// In es, this message translates to:
  /// **'Abierto'**
  String get export_statusOpen;

  /// No description provided for @export_statusClosed.
  ///
  /// In es, this message translates to:
  /// **'Cerrado'**
  String get export_statusClosed;

  /// No description provided for @export_statusNoActivity.
  ///
  /// In es, this message translates to:
  /// **'Sin actividad'**
  String get export_statusNoActivity;

  /// No description provided for @export_paymentPaid.
  ///
  /// In es, this message translates to:
  /// **'Pagado'**
  String get export_paymentPaid;

  /// No description provided for @export_paymentPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get export_paymentPending;

  /// No description provided for @actionSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get actionSave;

  /// No description provided for @dayClosedBanner.
  ///
  /// In es, this message translates to:
  /// **'Día cerrado'**
  String get dayClosedBanner;

  /// No description provided for @dayNoActivityBanner.
  ///
  /// In es, this message translates to:
  /// **'Día marcado sin actividad'**
  String get dayNoActivityBanner;

  /// No description provided for @dayReopen.
  ///
  /// In es, this message translates to:
  /// **'Reabrir'**
  String get dayReopen;

  /// No description provided for @dayReopenAuthReason.
  ///
  /// In es, this message translates to:
  /// **'Confirma para reabrir el día'**
  String get dayReopenAuthReason;

  /// No description provided for @dayReopenReasonTitle.
  ///
  /// In es, this message translates to:
  /// **'Motivo para reabrir el día'**
  String get dayReopenReasonTitle;

  /// No description provided for @dayReopened.
  ///
  /// In es, this message translates to:
  /// **'Día reabierto'**
  String get dayReopened;

  /// No description provided for @daySectionSales.
  ///
  /// In es, this message translates to:
  /// **'Ventas'**
  String get daySectionSales;

  /// No description provided for @dayShiftLunch.
  ///
  /// In es, this message translates to:
  /// **'Comida'**
  String get dayShiftLunch;

  /// No description provided for @dayShiftDinner.
  ///
  /// In es, this message translates to:
  /// **'Cena'**
  String get dayShiftDinner;

  /// No description provided for @dayCoversLunch.
  ///
  /// In es, this message translates to:
  /// **'Comensales comida'**
  String get dayCoversLunch;

  /// No description provided for @dayCoversDinner.
  ///
  /// In es, this message translates to:
  /// **'Comensales cena'**
  String get dayCoversDinner;

  /// No description provided for @dayTotalSales.
  ///
  /// In es, this message translates to:
  /// **'Ventas totales'**
  String get dayTotalSales;

  /// No description provided for @daySectionTips.
  ///
  /// In es, this message translates to:
  /// **'Propinas'**
  String get daySectionTips;

  /// No description provided for @dayTipsCash.
  ///
  /// In es, this message translates to:
  /// **'Propinas en efectivo (€)'**
  String get dayTipsCash;

  /// No description provided for @dayTipsCard.
  ///
  /// In es, this message translates to:
  /// **'Propinas con tarjeta (€)'**
  String get dayTipsCard;

  /// No description provided for @daySectionCashOut.
  ///
  /// In es, this message translates to:
  /// **'Efectivo que sale'**
  String get daySectionCashOut;

  /// No description provided for @dayWithdrawals.
  ///
  /// In es, this message translates to:
  /// **'Retiradas'**
  String get dayWithdrawals;

  /// No description provided for @dayCashExpenses.
  ///
  /// In es, this message translates to:
  /// **'Gastos en efectivo'**
  String get dayCashExpenses;

  /// No description provided for @dayAddWithdrawal.
  ///
  /// In es, this message translates to:
  /// **'Añadir retirada'**
  String get dayAddWithdrawal;

  /// No description provided for @dayAddCashExpense.
  ///
  /// In es, this message translates to:
  /// **'Añadir gasto en efectivo'**
  String get dayAddCashExpense;

  /// No description provided for @dayNoneYet.
  ///
  /// In es, this message translates to:
  /// **'Ninguno'**
  String get dayNoneYet;

  /// No description provided for @dayVoid.
  ///
  /// In es, this message translates to:
  /// **'Anular'**
  String get dayVoid;

  /// No description provided for @dayVoidReasonTitle.
  ///
  /// In es, this message translates to:
  /// **'Motivo de la anulación'**
  String get dayVoidReasonTitle;

  /// No description provided for @dayVoided.
  ///
  /// In es, this message translates to:
  /// **'Anulado'**
  String get dayVoided;

  /// No description provided for @daySectionCount.
  ///
  /// In es, this message translates to:
  /// **'Recuento'**
  String get daySectionCount;

  /// No description provided for @dayOpeningFloat.
  ///
  /// In es, this message translates to:
  /// **'Fondo inicial (€)'**
  String get dayOpeningFloat;

  /// No description provided for @dayOpeningFloatHint.
  ///
  /// In es, this message translates to:
  /// **'Viene del cierre del día anterior. Cámbialo solo si es necesario.'**
  String get dayOpeningFloatHint;

  /// No description provided for @dayCountTotal.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get dayCountTotal;

  /// No description provided for @dayCountDenominations.
  ///
  /// In es, this message translates to:
  /// **'Billetes y monedas'**
  String get dayCountDenominations;

  /// No description provided for @dayCountedCash.
  ///
  /// In es, this message translates to:
  /// **'Efectivo contado (€)'**
  String get dayCountedCash;

  /// No description provided for @dayCountedCashValue.
  ///
  /// In es, this message translates to:
  /// **'Efectivo contado'**
  String get dayCountedCashValue;

  /// No description provided for @dayTerminalTotal.
  ///
  /// In es, this message translates to:
  /// **'Total del datáfono (€)'**
  String get dayTerminalTotal;

  /// No description provided for @daySectionResult.
  ///
  /// In es, this message translates to:
  /// **'Resultado'**
  String get daySectionResult;

  /// No description provided for @dayExpected.
  ///
  /// In es, this message translates to:
  /// **'Efectivo esperado'**
  String get dayExpected;

  /// No description provided for @dayCashDiff.
  ///
  /// In es, this message translates to:
  /// **'Descuadre de efectivo'**
  String get dayCashDiff;

  /// No description provided for @dayCardDiff.
  ///
  /// In es, this message translates to:
  /// **'Descuadre de tarjeta'**
  String get dayCardDiff;

  /// No description provided for @dayOver.
  ///
  /// In es, this message translates to:
  /// **'Sobra'**
  String get dayOver;

  /// No description provided for @dayShort.
  ///
  /// In es, this message translates to:
  /// **'Falta'**
  String get dayShort;

  /// No description provided for @dayDiffPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente de datos'**
  String get dayDiffPending;

  /// No description provided for @dayComment.
  ///
  /// In es, this message translates to:
  /// **'Comentario'**
  String get dayComment;

  /// No description provided for @dayCommentRequired.
  ///
  /// In es, this message translates to:
  /// **'Comentario (obligatorio por el descuadre)'**
  String get dayCommentRequired;

  /// No description provided for @dayCloseButton.
  ///
  /// In es, this message translates to:
  /// **'Cerrar día'**
  String get dayCloseButton;

  /// No description provided for @dayClosedNoPending.
  ///
  /// In es, this message translates to:
  /// **'Día cerrado. No quedan días pendientes'**
  String get dayClosedNoPending;

  /// No description provided for @dayFormInvalid.
  ///
  /// In es, this message translates to:
  /// **'Revisa los importes marcados'**
  String get dayFormInvalid;

  /// No description provided for @dayErrCommentRequired.
  ///
  /// In es, this message translates to:
  /// **'Escribe un comentario para cerrar un día con descuadre'**
  String get dayErrCommentRequired;

  /// No description provided for @dayErrCountedMissing.
  ///
  /// In es, this message translates to:
  /// **'Indica el efectivo contado'**
  String get dayErrCountedMissing;

  /// No description provided for @dayErrTerminalMissing.
  ///
  /// In es, this message translates to:
  /// **'Indica el total del datáfono'**
  String get dayErrTerminalMissing;

  /// No description provided for @dayErrLocked.
  ///
  /// In es, this message translates to:
  /// **'Este día o su mes están cerrados. Reábrelos para hacer cambios'**
  String get dayErrLocked;

  /// No description provided for @dayErrNotOpen.
  ///
  /// In es, this message translates to:
  /// **'El día no está abierto'**
  String get dayErrNotOpen;

  /// No description provided for @dayErrSave.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar. Inténtalo de nuevo.'**
  String get dayErrSave;

  /// No description provided for @dayLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir el día'**
  String get dayLoadError;

  /// No description provided for @dayInvalidDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha no válida'**
  String get dayInvalidDate;

  /// No description provided for @sheetWithdrawalTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva retirada'**
  String get sheetWithdrawalTitle;

  /// No description provided for @sheetCashExpenseTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo gasto en efectivo'**
  String get sheetCashExpenseTitle;

  /// No description provided for @fieldAmount.
  ///
  /// In es, this message translates to:
  /// **'Importe (€)'**
  String get fieldAmount;

  /// No description provided for @fieldTotalAmount.
  ///
  /// In es, this message translates to:
  /// **'Importe total (€)'**
  String get fieldTotalAmount;

  /// No description provided for @fieldType.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get fieldType;

  /// No description provided for @fieldNote.
  ///
  /// In es, this message translates to:
  /// **'Nota (opcional)'**
  String get fieldNote;

  /// No description provided for @fieldCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get fieldCategory;

  /// No description provided for @fieldSupplierOptional.
  ///
  /// In es, this message translates to:
  /// **'Proveedor (opcional)'**
  String get fieldSupplierOptional;

  /// No description provided for @fieldVat.
  ///
  /// In es, this message translates to:
  /// **'IVA'**
  String get fieldVat;

  /// No description provided for @fieldInvoiceOptional.
  ///
  /// In es, this message translates to:
  /// **'Nº factura (opcional)'**
  String get fieldInvoiceOptional;

  /// No description provided for @noSupplier.
  ///
  /// In es, this message translates to:
  /// **'Sin proveedor'**
  String get noSupplier;

  /// No description provided for @amountMustBePositive.
  ///
  /// In es, this message translates to:
  /// **'El importe debe ser mayor que cero'**
  String get amountMustBePositive;

  /// No description provided for @expTabPending.
  ///
  /// In es, this message translates to:
  /// **'Pendientes'**
  String get expTabPending;

  /// No description provided for @expTabAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get expTabAll;

  /// No description provided for @expIncomplete.
  ///
  /// In es, this message translates to:
  /// **'Incompleto'**
  String get expIncomplete;

  /// No description provided for @expVoidedChip.
  ///
  /// In es, this message translates to:
  /// **'Anulado'**
  String get expVoidedChip;

  /// No description provided for @expEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay gastos'**
  String get expEmpty;

  /// No description provided for @expDueOn.
  ///
  /// In es, this message translates to:
  /// **'Vence {date}'**
  String expDueOn(String date);

  /// No description provided for @expTotalsTitle.
  ///
  /// In es, this message translates to:
  /// **'Totales por proveedor y categoría'**
  String get expTotalsTitle;

  /// No description provided for @expTotalsBySupplier.
  ///
  /// In es, this message translates to:
  /// **'Por proveedor'**
  String get expTotalsBySupplier;

  /// No description provided for @expTotalsByCategory.
  ///
  /// In es, this message translates to:
  /// **'Por categoría'**
  String get expTotalsByCategory;

  /// No description provided for @expFieldDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get expFieldDate;

  /// No description provided for @expFieldSupplier.
  ///
  /// In es, this message translates to:
  /// **'Proveedor'**
  String get expFieldSupplier;

  /// No description provided for @expSupplierPick.
  ///
  /// In es, this message translates to:
  /// **'Elegir proveedor'**
  String get expSupplierPick;

  /// No description provided for @expSupplierSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar proveedor'**
  String get expSupplierSearch;

  /// No description provided for @expSupplierNew.
  ///
  /// In es, this message translates to:
  /// **'Nuevo proveedor'**
  String get expSupplierNew;

  /// No description provided for @expSupplierClear.
  ///
  /// In es, this message translates to:
  /// **'Quitar proveedor'**
  String get expSupplierClear;

  /// No description provided for @expFieldBase.
  ///
  /// In es, this message translates to:
  /// **'Base imponible (€)'**
  String get expFieldBase;

  /// No description provided for @expFieldTotal.
  ///
  /// In es, this message translates to:
  /// **'Total (€)'**
  String get expFieldTotal;

  /// No description provided for @expFieldPayment.
  ///
  /// In es, this message translates to:
  /// **'Forma de pago'**
  String get expFieldPayment;

  /// No description provided for @expFieldDue.
  ///
  /// In es, this message translates to:
  /// **'Vencimiento'**
  String get expFieldDue;

  /// No description provided for @expDueNone.
  ///
  /// In es, this message translates to:
  /// **'Sin vencimiento'**
  String get expDueNone;

  /// No description provided for @expStatusPaid.
  ///
  /// In es, this message translates to:
  /// **'Pagado'**
  String get expStatusPaid;

  /// No description provided for @expStatusPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get expStatusPending;

  /// No description provided for @expSummaryBase.
  ///
  /// In es, this message translates to:
  /// **'Base'**
  String get expSummaryBase;

  /// No description provided for @expSummaryVat.
  ///
  /// In es, this message translates to:
  /// **'IVA'**
  String get expSummaryVat;

  /// No description provided for @expSummaryTotal.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get expSummaryTotal;

  /// No description provided for @expReceipts.
  ///
  /// In es, this message translates to:
  /// **'Justificantes'**
  String get expReceipts;

  /// No description provided for @expReceiptCamera.
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get expReceiptCamera;

  /// No description provided for @expReceiptGallery.
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get expReceiptGallery;

  /// No description provided for @expReceiptPdf.
  ///
  /// In es, this message translates to:
  /// **'PDF'**
  String get expReceiptPdf;

  /// No description provided for @expReceiptNone.
  ///
  /// In es, this message translates to:
  /// **'Sin justificantes'**
  String get expReceiptNone;

  /// No description provided for @expReceiptError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo añadir el justificante'**
  String get expReceiptError;

  /// No description provided for @expVoidButton.
  ///
  /// In es, this message translates to:
  /// **'Anular gasto'**
  String get expVoidButton;

  /// No description provided for @expVoidReasonTitle.
  ///
  /// In es, this message translates to:
  /// **'Motivo de la anulación'**
  String get expVoidReasonTitle;

  /// No description provided for @expLockedBanner.
  ///
  /// In es, this message translates to:
  /// **'Este gasto está en un período cerrado y no se puede modificar'**
  String get expLockedBanner;

  /// No description provided for @expVoidedBanner.
  ///
  /// In es, this message translates to:
  /// **'Gasto anulado: {reason}'**
  String expVoidedBanner(String reason);

  /// No description provided for @expErrSave.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el gasto'**
  String get expErrSave;

  /// No description provided for @expErrLocked.
  ///
  /// In es, this message translates to:
  /// **'El período está cerrado. Reábrelo para hacer cambios'**
  String get expErrLocked;

  /// No description provided for @expNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró el gasto'**
  String get expNotFound;

  /// No description provided for @suppFieldName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get suppFieldName;

  /// No description provided for @suppFieldNif.
  ///
  /// In es, this message translates to:
  /// **'NIF'**
  String get suppFieldNif;

  /// No description provided for @suppFieldPhone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get suppFieldPhone;

  /// No description provided for @suppFieldCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría por defecto'**
  String get suppFieldCategory;

  /// No description provided for @suppNone.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay proveedores'**
  String get suppNone;

  /// No description provided for @suppNewTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo proveedor'**
  String get suppNewTitle;

  /// No description provided for @suppEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar proveedor'**
  String get suppEditTitle;

  /// No description provided for @suppErrSave.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el proveedor'**
  String get suppErrSave;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

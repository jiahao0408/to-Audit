// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'to Audit';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionAccept => 'Aceptar';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionBack => 'Atrás';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get screenHome => 'Inicio';

  @override
  String get screenCalendar => 'Calendario';

  @override
  String get screenDay => 'Día';

  @override
  String get screenExpenses => 'Gastos';

  @override
  String get screenExpenseNew => 'Nuevo gasto';

  @override
  String get screenExpenseDetail => 'Gasto';

  @override
  String get screenSuppliers => 'Proveedores';

  @override
  String get screenFixedCosts => 'Gastos fijos';

  @override
  String get screenPayroll => 'Nóminas';

  @override
  String get screenWithdrawals => 'Retiradas de caja';

  @override
  String get screenReports => 'Informes';

  @override
  String get screenAlerts => 'Alertas';

  @override
  String get screenHistory => 'Historial de cambios';

  @override
  String get screenSettings => 'Ajustes';

  @override
  String get screenCatalogs => 'Catálogos';

  @override
  String get screenBackup => 'Copia de seguridad';

  @override
  String get fieldRequired => 'Obligatorio';

  @override
  String get amountInvalid => 'Importe no válido';

  @override
  String get reasonLabel => 'Motivo';

  @override
  String get reasonRequired => 'Escribe un motivo';

  @override
  String get lockTitle => 'Introduce tu PIN';

  @override
  String get pinDelete => 'Borrar';

  @override
  String pinWrong(int attempts) {
    return 'PIN incorrecto. Intentos antes del bloqueo: $attempts';
  }

  @override
  String pinLockedSeconds(int seconds) {
    return 'Demasiados intentos. Espera $seconds s.';
  }

  @override
  String pinLockedMinutes(int minutes) {
    return 'Demasiados intentos. Espera $minutes min.';
  }

  @override
  String get pinUseBiometrics => 'Usar huella o rostro';

  @override
  String get pinCheckError => 'No se pudo comprobar el PIN';

  @override
  String get biometricReason => 'Desbloquea to Audit';

  @override
  String get authPinTitle => 'Confirma con tu PIN';

  @override
  String onbStep(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get onbLanguageTitle => 'Elige el idioma';

  @override
  String get languageEs => 'Español';

  @override
  String get languageZh => '中文';

  @override
  String get onbRestaurantTitle => 'Datos del restaurante';

  @override
  String get restaurantName => 'Nombre del restaurante';

  @override
  String get restaurantNif => 'NIF';

  @override
  String get restaurantAddress => 'Dirección';

  @override
  String get onbPinTitle => 'Crea tu PIN';

  @override
  String get onbPinCreateLabel => 'PIN de 6 dígitos';

  @override
  String get onbPinConfirmLabel => 'Repite el PIN';

  @override
  String get onbPinInvalid => 'El PIN debe tener exactamente 6 dígitos';

  @override
  String get onbPinMismatch => 'Los PIN no coinciden';

  @override
  String get onbPinWarning =>
      'Si olvidas el PIN y no tienes biometría activada, la única forma de volver a entrar es reinstalar la app y restaurar una copia de seguridad. Haz copias con regularidad.';

  @override
  String get onbBiometricsTitle => 'Huella o rostro';

  @override
  String get onbBiometricsBody =>
      'Puedes desbloquear la app con la biometría de tu móvil. El PIN seguirá siendo el respaldo.';

  @override
  String get onbBiometricsEnable => 'Activar biometría';

  @override
  String get onbBiometricsFailed => 'No se pudo activar la biometría';

  @override
  String get onbFloatTitle => 'Fondo de caja inicial';

  @override
  String get onbFloatBody => 'Dinero que hay en caja al empezar el primer día.';

  @override
  String get onbFloatLabel => 'Fondo de caja (€)';

  @override
  String get onbFinish => 'Empezar';

  @override
  String get onbSaveError => 'No se pudo guardar. Inténtalo de nuevo.';

  @override
  String get keyMissingTitle => 'No se puede abrir la base de datos';

  @override
  String get keyMissingBody =>
      'La clave de cifrado de este dispositivo no está disponible. Tus datos no se han modificado. Restaura una copia de seguridad para continuar.';

  @override
  String get restoreBackupButton => 'Restaurar copia';

  @override
  String get startupErrorTitle => 'Error al iniciar la app';

  @override
  String get startupErrorBody =>
      'No se pudo abrir la base de datos. Cierra la app y vuelve a abrirla. Si el problema continúa, restaura una copia de seguridad.';

  @override
  String get homeMonthSales => 'Ventas del mes';

  @override
  String get homeProfit => 'Beneficio acumulado';

  @override
  String homeProfitUntil(String date) {
    return 'Hasta el último día cerrado ($date)';
  }

  @override
  String get homeProfitNone => 'Aún no hay días cerrados';

  @override
  String get homeRegisterNext => 'Registrar siguiente día pendiente';

  @override
  String get homeAllUpToDate => 'Todos los días están al día';

  @override
  String homeAlertsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alertas',
      one: '1 alerta',
      zero: 'Sin alertas',
    );
    return '$_temp0';
  }

  @override
  String get homeBackupBannerNever =>
      'Aún no has hecho ninguna copia de seguridad';

  @override
  String homeBackupBannerDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Tu última copia de seguridad fue hace $days días',
      one: 'Tu última copia de seguridad fue hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String get homeBackupAction => 'Hacer copia';

  @override
  String get homeBackupDialogTitle => 'Copia de seguridad pendiente';

  @override
  String get homeBackupDialogBody =>
      'Hace mucho tiempo que no haces una copia de seguridad. Si pierdes o cambias de móvil, perderás tus datos.';

  @override
  String get homeBackupDialogLater => 'Más tarde';

  @override
  String get homeBackupDialogNow => 'Hacer copia ahora';

  @override
  String get homeLoadError => 'No se pudieron cargar los datos';

  @override
  String get calendarPrevMonth => 'Mes anterior';

  @override
  String get calendarNextMonth => 'Mes siguiente';

  @override
  String get dayStateUnregistered => 'Sin registrar';

  @override
  String get dayStateOpen => 'Abierto';

  @override
  String get dayStateBalanced => 'Cuadrado';

  @override
  String get dayStateDiscrepancy => 'Descuadre';

  @override
  String get dayStateNoActivity => 'Sin actividad';

  @override
  String get dayStateFuture => 'Futuro';

  @override
  String dayCellLabel(String date, String state) {
    return '$date: $state';
  }

  @override
  String get markNoActivity => 'Marcar sin actividad';

  @override
  String get markNoActivityDone => 'Día marcado sin actividad';

  @override
  String get markNoActivityError => 'No se pudo marcar el día';

  @override
  String get catalog_cash => 'Efectivo';

  @override
  String get catalog_card => 'Tarjeta CaixaBank';

  @override
  String get catalog_bizum => 'Bizum';

  @override
  String get catalog_vouchers => 'Vales';

  @override
  String get catalog_glovo => 'Glovo';

  @override
  String get catalog_justeat => 'Just Eat';

  @override
  String get catalog_ubereats => 'Uber Eats';

  @override
  String get catalog_meat => 'Carne';

  @override
  String get catalog_fish => 'Pescado';

  @override
  String get catalog_vegetables => 'Verdura';

  @override
  String get catalog_drinks => 'Bebidas';

  @override
  String get catalog_groceries => 'Alimentación';

  @override
  String get catalog_cleaning => 'Limpieza';

  @override
  String get catalog_utilities => 'Suministros';

  @override
  String get catalog_rent => 'Alquiler';

  @override
  String get catalog_insurance => 'Seguros';

  @override
  String get catalog_selfemployed => 'Autónomos';

  @override
  String get catalog_advisor => 'Gestoría';

  @override
  String get catalog_other => 'Otros';

  @override
  String get catalog_bank_deposit => 'Ingreso en banco';

  @override
  String get catalog_owner => 'Retirada del dueño';

  @override
  String get catalog_cash_payment => 'Pago en mano';

  @override
  String get catalog_change => 'Cambio';

  @override
  String get export_sheetSummary => 'Resumen';

  @override
  String get export_sheetDays => 'Días';

  @override
  String get export_sheetSales => 'Ventas';

  @override
  String get export_sheetExpenses => 'Gastos';

  @override
  String get export_sheetPayroll => 'Nóminas';

  @override
  String get export_sheetWithdrawals => 'Retiradas';

  @override
  String get export_colConcept => 'Concepto';

  @override
  String get export_colAmount => 'Importe';

  @override
  String get export_colDate => 'Fecha';

  @override
  String get export_colStatus => 'Estado';

  @override
  String get export_colSales => 'Ventas';

  @override
  String get export_colCovers => 'Comensales';

  @override
  String get export_colExpenses => 'Gastos';

  @override
  String get export_colCashDiff => 'Descuadre efectivo';

  @override
  String get export_colCardDiff => 'Descuadre tarjeta';

  @override
  String get export_colPaymentMethod => 'Forma de pago';

  @override
  String get export_colSupplier => 'Proveedor';

  @override
  String get export_colInvoice => 'Nº factura';

  @override
  String get export_colCategory => 'Categoría';

  @override
  String get export_colBase => 'Base imponible';

  @override
  String get export_colVatPct => 'IVA %';

  @override
  String get export_colVat => 'IVA';

  @override
  String get export_colTotal => 'Total';

  @override
  String get export_colPayment => 'Pago';

  @override
  String get export_colReceipts => 'Justificantes';

  @override
  String get export_colEmployee => 'Empleado';

  @override
  String get export_colRole => 'Puesto';

  @override
  String get export_colMonth => 'Mes';

  @override
  String get export_colGross => 'Bruto';

  @override
  String get export_colNet => 'Neto';

  @override
  String get export_colEmployerSs => 'SS empresa';

  @override
  String get export_colWithdrawalType => 'Tipo de retirada';

  @override
  String get export_reportTitle => 'Informe de gestión';

  @override
  String get export_restaurantNif => 'NIF';

  @override
  String get export_period => 'Período';

  @override
  String get export_generatedOn => 'Generado el';

  @override
  String get export_totalSales => 'Ventas totales';

  @override
  String get export_totalPurchases => 'Compras';

  @override
  String get export_totalFixedCosts => 'Gastos fijos';

  @override
  String get export_totalOtherExpenses => 'Otros gastos';

  @override
  String get export_totalExpenses => 'Gastos totales';

  @override
  String get export_totalPayroll => 'Personal';

  @override
  String get export_totalWithdrawals => 'Retiradas de caja';

  @override
  String get export_totalCashDiscrepancy => 'Descuadre de efectivo';

  @override
  String get export_totalCardDiscrepancy => 'Descuadre de tarjeta';

  @override
  String get export_pendingFixed => 'Fijos pendientes de confirmar';

  @override
  String get export_vatPaid => 'IVA soportado';

  @override
  String get export_averageTicket => 'Ticket medio';

  @override
  String get export_profit => 'Beneficio';

  @override
  String get export_dailyDetail => 'Detalle diario';

  @override
  String get export_statusOpen => 'Abierto';

  @override
  String get export_statusClosed => 'Cerrado';

  @override
  String get export_statusNoActivity => 'Sin actividad';

  @override
  String get export_paymentPaid => 'Pagado';

  @override
  String get export_paymentPending => 'Pendiente';

  @override
  String get actionSave => 'Guardar';

  @override
  String get dayClosedBanner => 'Día cerrado';

  @override
  String get dayNoActivityBanner => 'Día marcado sin actividad';

  @override
  String get dayReopen => 'Reabrir';

  @override
  String get dayReopenAuthReason => 'Confirma para reabrir el día';

  @override
  String get dayReopenReasonTitle => 'Motivo para reabrir el día';

  @override
  String get dayReopened => 'Día reabierto';

  @override
  String get daySectionSales => 'Ventas';

  @override
  String get dayShiftLunch => 'Comida';

  @override
  String get dayShiftDinner => 'Cena';

  @override
  String get dayCoversLunch => 'Comensales comida';

  @override
  String get dayCoversDinner => 'Comensales cena';

  @override
  String get dayTotalSales => 'Ventas totales';

  @override
  String get daySectionTips => 'Propinas';

  @override
  String get dayTipsCash => 'Propinas en efectivo (€)';

  @override
  String get dayTipsCard => 'Propinas con tarjeta (€)';

  @override
  String get daySectionCashOut => 'Efectivo que sale';

  @override
  String get dayWithdrawals => 'Retiradas';

  @override
  String get dayCashExpenses => 'Gastos en efectivo';

  @override
  String get dayAddWithdrawal => 'Añadir retirada';

  @override
  String get dayAddCashExpense => 'Añadir gasto en efectivo';

  @override
  String get dayNoneYet => 'Ninguno';

  @override
  String get dayVoid => 'Anular';

  @override
  String get dayVoidReasonTitle => 'Motivo de la anulación';

  @override
  String get dayVoided => 'Anulado';

  @override
  String get daySectionCount => 'Recuento';

  @override
  String get dayOpeningFloat => 'Fondo inicial (€)';

  @override
  String get dayOpeningFloatHint =>
      'Viene del cierre del día anterior. Cámbialo solo si es necesario.';

  @override
  String get dayCountTotal => 'Total';

  @override
  String get dayCountDenominations => 'Billetes y monedas';

  @override
  String get dayCountedCash => 'Efectivo contado (€)';

  @override
  String get dayCountedCashValue => 'Efectivo contado';

  @override
  String get dayTerminalTotal => 'Total del datáfono (€)';

  @override
  String get daySectionResult => 'Resultado';

  @override
  String get dayExpected => 'Efectivo esperado';

  @override
  String get dayCashDiff => 'Descuadre de efectivo';

  @override
  String get dayCardDiff => 'Descuadre de tarjeta';

  @override
  String get dayOver => 'Sobra';

  @override
  String get dayShort => 'Falta';

  @override
  String get dayDiffPending => 'Pendiente de datos';

  @override
  String get dayComment => 'Comentario';

  @override
  String get dayCommentRequired => 'Comentario (obligatorio por el descuadre)';

  @override
  String get dayCloseButton => 'Cerrar día';

  @override
  String get dayClosedNoPending => 'Día cerrado. No quedan días pendientes';

  @override
  String get dayFormInvalid => 'Revisa los importes marcados';

  @override
  String get dayErrCommentRequired =>
      'Escribe un comentario para cerrar un día con descuadre';

  @override
  String get dayErrCountedMissing => 'Indica el efectivo contado';

  @override
  String get dayErrTerminalMissing => 'Indica el total del datáfono';

  @override
  String get dayErrLocked =>
      'Este día o su mes están cerrados. Reábrelos para hacer cambios';

  @override
  String get dayErrNotOpen => 'El día no está abierto';

  @override
  String get dayErrSave => 'No se pudo guardar. Inténtalo de nuevo.';

  @override
  String get dayLoadError => 'No se pudo abrir el día';

  @override
  String get dayInvalidDate => 'Fecha no válida';

  @override
  String get sheetWithdrawalTitle => 'Nueva retirada';

  @override
  String get sheetCashExpenseTitle => 'Nuevo gasto en efectivo';

  @override
  String get fieldAmount => 'Importe (€)';

  @override
  String get fieldTotalAmount => 'Importe total (€)';

  @override
  String get fieldType => 'Tipo';

  @override
  String get fieldNote => 'Nota (opcional)';

  @override
  String get fieldCategory => 'Categoría';

  @override
  String get fieldSupplierOptional => 'Proveedor (opcional)';

  @override
  String get fieldVat => 'IVA';

  @override
  String get fieldInvoiceOptional => 'Nº factura (opcional)';

  @override
  String get noSupplier => 'Sin proveedor';

  @override
  String get amountMustBePositive => 'El importe debe ser mayor que cero';
}

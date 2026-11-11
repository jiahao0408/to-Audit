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

  @override
  String get expTabPending => 'Pendientes';

  @override
  String get expTabAll => 'Todos';

  @override
  String get expIncomplete => 'Incompleto';

  @override
  String get expVoidedChip => 'Anulado';

  @override
  String get expEmpty => 'No hay gastos';

  @override
  String expDueOn(String date) {
    return 'Vence $date';
  }

  @override
  String get expTotalsTitle => 'Totales por proveedor y categoría';

  @override
  String get expTotalsBySupplier => 'Por proveedor';

  @override
  String get expTotalsByCategory => 'Por categoría';

  @override
  String get expFieldDate => 'Fecha';

  @override
  String get expFieldSupplier => 'Proveedor';

  @override
  String get expSupplierPick => 'Elegir proveedor';

  @override
  String get expSupplierSearch => 'Buscar proveedor';

  @override
  String get expSupplierNew => 'Nuevo proveedor';

  @override
  String get expSupplierClear => 'Quitar proveedor';

  @override
  String get expFieldBase => 'Base imponible (€)';

  @override
  String get expFieldTotal => 'Total (€)';

  @override
  String get expFieldPayment => 'Forma de pago';

  @override
  String get expFieldDue => 'Vencimiento';

  @override
  String get expDueNone => 'Sin vencimiento';

  @override
  String get expStatusPaid => 'Pagado';

  @override
  String get expStatusPending => 'Pendiente';

  @override
  String get expSummaryBase => 'Base';

  @override
  String get expSummaryVat => 'IVA';

  @override
  String get expSummaryTotal => 'Total';

  @override
  String get expReceipts => 'Justificantes';

  @override
  String get expReceiptCamera => 'Cámara';

  @override
  String get expReceiptGallery => 'Galería';

  @override
  String get expReceiptPdf => 'PDF';

  @override
  String get expReceiptNone => 'Sin justificantes';

  @override
  String get expReceiptError => 'No se pudo añadir el justificante';

  @override
  String get expVoidButton => 'Anular gasto';

  @override
  String get expVoidReasonTitle => 'Motivo de la anulación';

  @override
  String get expLockedBanner =>
      'Este gasto está en un período cerrado y no se puede modificar';

  @override
  String expVoidedBanner(String reason) {
    return 'Gasto anulado: $reason';
  }

  @override
  String get expErrSave => 'No se pudo guardar el gasto';

  @override
  String get expErrLocked =>
      'El período está cerrado. Reábrelo para hacer cambios';

  @override
  String get expNotFound => 'No se encontró el gasto';

  @override
  String get suppFieldName => 'Nombre';

  @override
  String get suppFieldNif => 'NIF';

  @override
  String get suppFieldPhone => 'Teléfono';

  @override
  String get suppFieldCategory => 'Categoría por defecto';

  @override
  String get suppNone => 'Aún no hay proveedores';

  @override
  String get suppNewTitle => 'Nuevo proveedor';

  @override
  String get suppEditTitle => 'Editar proveedor';

  @override
  String get suppErrSave => 'No se pudo guardar el proveedor';

  @override
  String get expLoadError => 'No se pudo cargar el gasto';

  @override
  String get fixedCostNewTitle => 'Nuevo gasto fijo';

  @override
  String get fixedCostEditTitle => 'Editar gasto fijo';

  @override
  String get fixedCostFieldConcept => 'Concepto';

  @override
  String get fixedCostFieldPeriodicity => 'Periodicidad';

  @override
  String get fixedCostFieldChargeDay => 'Día de cargo (1–31)';

  @override
  String get fixedCostFieldStartMonth => 'Mes de inicio (AAAA-MM)';

  @override
  String get fixedCostFieldPlanned => 'Importe previsto (€)';

  @override
  String get fixedCostSectionDefs => 'Definiciones';

  @override
  String get fixedCostSectionPending => 'Por confirmar';

  @override
  String get fixedCostNone => 'No hay gastos fijos definidos';

  @override
  String get fixedCostNonePending => 'Ninguno pendiente de confirmar';

  @override
  String get fixedCostConfirmTitle => 'Confirmar importe real';

  @override
  String get fixedCostActive => 'Activo';

  @override
  String get fixedCostDeactivate => 'Desactivar';

  @override
  String get fixedCostActivate => 'Activar';

  @override
  String get fixedCostErrSave => 'No se pudo guardar el gasto fijo';

  @override
  String get periodicityMonthly => 'Mensual';

  @override
  String get periodicityBimonthly => 'Bimestral';

  @override
  String get periodicityQuarterly => 'Trimestral';

  @override
  String get periodicityAnnual => 'Anual';

  @override
  String get payrollNoEmployees => 'No hay empleados activos este mes';

  @override
  String get payrollErrSave => 'No se pudo guardar la nómina';

  @override
  String get payrollTotalCost => 'Coste total del mes';

  @override
  String get payrollPercentOfSales => '% sobre ventas';

  @override
  String get payrollPaymentSave => 'Registrar nómina';

  @override
  String get payrollPaymentVoid => 'Anular nómina';

  @override
  String get payrollVoidReasonTitle => 'Motivo de anulación de nómina';

  @override
  String get payrollFieldGross => 'Bruto (€)';

  @override
  String get payrollFieldNet => 'Neto (€)';

  @override
  String get payrollFieldEmployerSs => 'SS empresa (€)';

  @override
  String get payrollEmployeeNewTitle => 'Nuevo empleado';

  @override
  String get payrollEmployeeEditTitle => 'Editar empleado';

  @override
  String get payrollFieldHiredOn => 'Fecha de alta';

  @override
  String get payrollFieldLeftOn => 'Fecha de baja (opcional)';

  @override
  String get payrollNoPayment => 'Sin nómina registrada';

  @override
  String get payrollErrEmployee => 'No se pudo guardar el empleado';

  @override
  String get withdrawalsPeriodMonth => 'Este mes';

  @override
  String get withdrawalsPeriodWeek => 'Esta semana';

  @override
  String get withdrawalsTotalsTitle => 'Totales por tipo';

  @override
  String get withdrawalsEmpty => 'No hay retiradas en este período';

  @override
  String get withdrawalsErrLoad => 'No se pudieron cargar las retiradas';

  @override
  String get reportPeriodLastMonth => 'Mes anterior';

  @override
  String get reportErrLoad => 'No se pudo cargar el informe';

  @override
  String get reportExportPdf => 'PDF';

  @override
  String get reportExportXlsx => 'Excel';

  @override
  String get reportExportCsv => 'CSV';

  @override
  String get reportExportGestor => 'Gestor ZIP';

  @override
  String get reportExportErr => 'No se pudo exportar';

  @override
  String get reportNoData => 'Sin datos para este período';

  @override
  String get alertEmpty => 'No hay alertas pendientes';

  @override
  String get alertMissingReceipt => 'Gasto sin justificante';

  @override
  String get alertInvoiceOverdue => 'Factura vencida';

  @override
  String get alertBackupOld => 'No has hecho una copia en más de 14 días';

  @override
  String get alertGoDay => 'Ver día';

  @override
  String get alertGoExpense => 'Ver gasto';

  @override
  String get alertGoBackup => 'Hacer copia';

  @override
  String get settingsRestaurant => 'Datos del restaurante';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsThreshold => 'Umbral de descuadre (€)';

  @override
  String get settingsBackupEvery => 'Recordar copia cada (días)';

  @override
  String get settingsChangePin => 'Cambiar PIN';

  @override
  String get settingsBiometrics => 'Biometría';

  @override
  String get settingsCatalogPayments => 'Formas de pago';

  @override
  String get settingsCatalogCategories => 'Categorías de gasto';

  @override
  String get settingsCatalogWithdrawals => 'Tipos de retirada';

  @override
  String get settingsMonths => 'Cierre de períodos';

  @override
  String get settingsSaved => 'Guardado';

  @override
  String get settingsErrSave => 'No se pudo guardar';

  @override
  String get settingsPinChanged => 'PIN cambiado correctamente';

  @override
  String get settingsErrPin => 'No se pudo cambiar el PIN';

  @override
  String get settingsBiometricsNotAvailable =>
      'La biometría no está disponible en este dispositivo';

  @override
  String get catalogNew => 'Nuevo';

  @override
  String get catalogFieldName => 'Nombre';

  @override
  String get catalogActive => 'Activo';

  @override
  String get catalogInactive => 'Inactivo';

  @override
  String get catalogErrSave => 'No se pudo guardar';

  @override
  String get catalogEmpty => 'Sin elementos';

  @override
  String get historyEmpty => 'No hay cambios registrados';

  @override
  String get historyErrLoad => 'No se pudo cargar el historial';

  @override
  String get historyField => 'Campo';

  @override
  String get historyOldValue => 'Antes';

  @override
  String get historyNewValue => 'Después';

  @override
  String get backupSectionCreate => 'Nueva copia';

  @override
  String get backupSectionRestore => 'Restaurar copia';

  @override
  String get backupPasswordLabel => 'Contraseña (mín. 8 caracteres)';

  @override
  String get backupPasswordConfirm => 'Repite la contraseña';

  @override
  String get backupPasswordMismatch => 'Las contraseñas no coinciden';

  @override
  String get backupPasswordTooShort => 'Mínimo 8 caracteres';

  @override
  String get backupCreateButton => 'Crear y exportar';

  @override
  String get backupPickFile => 'Elegir archivo .toaudit';

  @override
  String get backupInspecting => 'Verificando copia…';

  @override
  String get backupPreviewTitle => 'Vista previa de la copia';

  @override
  String get backupPreviewDate => 'Fecha de la copia';

  @override
  String get backupPreviewDays => 'Días';

  @override
  String get backupPreviewExpenses => 'Gastos';

  @override
  String get backupRestoreButton => 'Restaurar ahora';

  @override
  String get backupRestoring => 'Restaurando…';

  @override
  String get backupRestoredTitle => 'Copia restaurada';

  @override
  String get backupRestoredBody =>
      'Los datos se han restaurado correctamente. Cierra y vuelve a abrir la app para aplicar los cambios.';

  @override
  String get backupErrDecrypt => 'Contraseña incorrecta o archivo dañado';

  @override
  String get backupErrTooNew =>
      'Esta copia fue creada con una versión más reciente de la app';

  @override
  String get backupErrRestore => 'No se pudo restaurar la copia';

  @override
  String get backupErrCreate => 'No se pudo crear la copia';

  @override
  String get backupCancelDelete => 'Cancelar y limpiar';

  @override
  String get backupLastCopy => 'Última copia';

  @override
  String get monthsClose => 'Cerrar mes';

  @override
  String get monthsReopen => 'Reabrir mes';

  @override
  String get monthsStatusOpen => 'Abierto';

  @override
  String get monthsStatusClosed => 'Cerrado';

  @override
  String get monthsErrSave => 'No se pudo cambiar el estado del mes';

  @override
  String get monthsReopenReasonTitle => 'Motivo para reabrir el mes';

  @override
  String get monthsErrAlreadyClosed => 'Este mes ya está cerrado';

  @override
  String get monthsEmpty => 'Aún no hay meses con actividad';

  @override
  String reportGestorMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count justificantes no encontrados',
      one: '1 justificante no encontrado',
    );
    return 'Advertencia: $_temp0';
  }

  @override
  String alertDiscrepancy(String date) {
    return 'Descuadre el $date';
  }

  @override
  String alertDayOpen(String date) {
    return 'El día $date sigue abierto';
  }

  @override
  String alertDayUnregistered(String date) {
    return 'El día $date no está registrado';
  }

  @override
  String alertFloatMismatch(String date) {
    return 'Fondo inicial incorrecto el $date';
  }

  @override
  String monthsErrNotReady(String dates) {
    return 'Días pendientes: $dates';
  }

  @override
  String get periodToday => 'Hoy';

  @override
  String get periodCustom => 'Desde–hasta';

  @override
  String get reportSavePdf => 'Guardar PDF';

  @override
  String get backupPasswordWarning =>
      'Guarda esta contraseña en un lugar seguro: sin ella no se puede restaurar la copia y no hay forma de recuperarla.';

  @override
  String get backupErrNotToaudit =>
      'El archivo debe tener la extensión .toaudit';

  @override
  String get backupErrVerify =>
      'La restauración falló y se han recuperado tus datos anteriores';

  @override
  String get backupErrRestart =>
      'Reinicia la app para terminar de recuperar los datos';

  @override
  String get backupErrInspect => 'No se pudo leer la copia';

  @override
  String get backupRestoreConfirm =>
      'Se reemplazarán todos los datos actuales por los de la copia. ¿Continuar?';

  @override
  String get backupCreated => 'Copia creada';

  @override
  String get backupRestoredInApp => 'Copia restaurada';

  @override
  String get backupPasswordDialogTitle => 'Contraseña de la copia';
}

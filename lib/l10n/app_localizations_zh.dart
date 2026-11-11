// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'to Audit';

  @override
  String get actionCancel => '取消';

  @override
  String get actionAccept => '确定';

  @override
  String get actionContinue => '继续';

  @override
  String get actionBack => '返回';

  @override
  String get actionRetry => '重试';

  @override
  String get screenHome => '首页';

  @override
  String get screenCalendar => '日历';

  @override
  String get screenDay => '日结';

  @override
  String get screenExpenses => '支出';

  @override
  String get screenExpenseNew => '新增支出';

  @override
  String get screenExpenseDetail => '支出详情';

  @override
  String get screenSuppliers => '供应商';

  @override
  String get screenFixedCosts => '固定成本';

  @override
  String get screenPayroll => '工资';

  @override
  String get screenWithdrawals => '现金取款';

  @override
  String get screenReports => '报表';

  @override
  String get screenAlerts => '提醒';

  @override
  String get screenHistory => '变更记录';

  @override
  String get screenSettings => '设置';

  @override
  String get screenCatalogs => '目录';

  @override
  String get screenBackup => '备份';

  @override
  String get fieldRequired => '必填';

  @override
  String get amountInvalid => '金额无效';

  @override
  String get reasonLabel => '原因';

  @override
  String get reasonRequired => '请填写原因';

  @override
  String get lockTitle => '请输入 PIN';

  @override
  String get pinDelete => '删除';

  @override
  String pinWrong(int attempts) {
    return 'PIN 错误。锁定前还可尝试 $attempts 次';
  }

  @override
  String pinLockedSeconds(int seconds) {
    return '尝试次数过多，请等待 $seconds 秒。';
  }

  @override
  String pinLockedMinutes(int minutes) {
    return '尝试次数过多，请等待 $minutes 分钟。';
  }

  @override
  String get pinUseBiometrics => '使用指纹或面部识别';

  @override
  String get pinCheckError => '无法验证 PIN';

  @override
  String get biometricReason => '解锁 to Audit';

  @override
  String get authPinTitle => '请用 PIN 确认';

  @override
  String onbStep(int current, int total) {
    return '第 $current 步，共 $total 步';
  }

  @override
  String get onbLanguageTitle => '选择语言';

  @override
  String get languageEs => 'Español';

  @override
  String get languageZh => '中文';

  @override
  String get onbRestaurantTitle => '餐厅信息';

  @override
  String get restaurantName => '餐厅名称';

  @override
  String get restaurantNif => '税号 (NIF)';

  @override
  String get restaurantAddress => '地址';

  @override
  String get onbPinTitle => '创建 PIN';

  @override
  String get onbPinCreateLabel => '6 位 PIN';

  @override
  String get onbPinConfirmLabel => '再次输入 PIN';

  @override
  String get onbPinInvalid => 'PIN 必须是 6 位数字';

  @override
  String get onbPinMismatch => '两次输入的 PIN 不一致';

  @override
  String get onbPinWarning => '如果忘记 PIN 且没有启用生物识别，唯一的办法是重新安装应用并恢复备份。请定期备份。';

  @override
  String get onbBiometricsTitle => '指纹或面部识别';

  @override
  String get onbBiometricsBody => '你可以用手机的生物识别解锁应用，PIN 仍作为备用方式。';

  @override
  String get onbBiometricsEnable => '启用生物识别';

  @override
  String get onbBiometricsFailed => '无法启用生物识别';

  @override
  String get onbFloatTitle => '初始备用金';

  @override
  String get onbFloatBody => '第一天开始营业时收银箱里的现金。';

  @override
  String get onbFloatLabel => '备用金 (€)';

  @override
  String get onbFinish => '开始使用';

  @override
  String get onbSaveError => '保存失败，请重试。';

  @override
  String get keyMissingTitle => '无法打开数据库';

  @override
  String get keyMissingBody => '此设备上的加密密钥不可用，你的数据没有被改动。请恢复一份备份后继续。';

  @override
  String get restoreBackupButton => '恢复备份';

  @override
  String get startupErrorTitle => '应用启动出错';

  @override
  String get startupErrorBody => '无法打开数据库。请关闭应用后重新打开；如果问题仍然存在，请恢复备份。';

  @override
  String get homeMonthSales => '本月销售额';

  @override
  String get homeProfit => '累计利润';

  @override
  String homeProfitUntil(String date) {
    return '截至最近已结日 ($date)';
  }

  @override
  String get homeProfitNone => '尚无已结日';

  @override
  String get homeRegisterNext => '登记下一个待处理日';

  @override
  String get homeAllUpToDate => '所有日期均已登记';

  @override
  String homeAlertsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条提醒',
      zero: '没有提醒',
    );
    return '$_temp0';
  }

  @override
  String get homeBackupBannerNever => '你还没有做过备份';

  @override
  String homeBackupBannerDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '上次备份是 $days 天前',
    );
    return '$_temp0';
  }

  @override
  String get homeBackupAction => '立即备份';

  @override
  String get homeBackupDialogTitle => '备份提醒';

  @override
  String get homeBackupDialogBody => '你已经很久没有备份了。如果手机丢失或更换，数据将会丢失。';

  @override
  String get homeBackupDialogLater => '稍后';

  @override
  String get homeBackupDialogNow => '现在备份';

  @override
  String get homeLoadError => '无法加载数据';

  @override
  String get calendarPrevMonth => '上个月';

  @override
  String get calendarNextMonth => '下个月';

  @override
  String get dayStateUnregistered => '未登记';

  @override
  String get dayStateOpen => '进行中';

  @override
  String get dayStateBalanced => '已平账';

  @override
  String get dayStateDiscrepancy => '有差额';

  @override
  String get dayStateNoActivity => '无营业';

  @override
  String get dayStateFuture => '未到';

  @override
  String dayCellLabel(String date, String state) {
    return '$date：$state';
  }

  @override
  String get markNoActivity => '标记为无营业';

  @override
  String get markNoActivityDone => '已标记为无营业';

  @override
  String get markNoActivityError => '无法标记该日';

  @override
  String get catalog_cash => '现金';

  @override
  String get catalog_card => 'CaixaBank 银行卡';

  @override
  String get catalog_bizum => 'Bizum';

  @override
  String get catalog_vouchers => '代金券';

  @override
  String get catalog_glovo => 'Glovo';

  @override
  String get catalog_justeat => 'Just Eat';

  @override
  String get catalog_ubereats => 'Uber Eats';

  @override
  String get catalog_meat => '肉类';

  @override
  String get catalog_fish => '鱼类';

  @override
  String get catalog_vegetables => '蔬菜';

  @override
  String get catalog_drinks => '饮料';

  @override
  String get catalog_groceries => '食品杂货';

  @override
  String get catalog_cleaning => '清洁';

  @override
  String get catalog_utilities => '水电燃气';

  @override
  String get catalog_rent => '租金';

  @override
  String get catalog_insurance => '保险';

  @override
  String get catalog_selfemployed => '个体户社保';

  @override
  String get catalog_advisor => '代理记账';

  @override
  String get catalog_other => '其他';

  @override
  String get catalog_bank_deposit => '存入银行';

  @override
  String get catalog_owner => '店主取款';

  @override
  String get catalog_cash_payment => '现金支付';

  @override
  String get catalog_change => '找零';

  @override
  String get export_sheetSummary => '汇总';

  @override
  String get export_sheetDays => '每日';

  @override
  String get export_sheetSales => '销售';

  @override
  String get export_sheetExpenses => '支出';

  @override
  String get export_sheetPayroll => '工资';

  @override
  String get export_sheetWithdrawals => '取款';

  @override
  String get export_colConcept => '项目';

  @override
  String get export_colAmount => '金额';

  @override
  String get export_colDate => '日期';

  @override
  String get export_colStatus => '状态';

  @override
  String get export_colSales => '销售额';

  @override
  String get export_colCovers => '就餐人数';

  @override
  String get export_colExpenses => '支出';

  @override
  String get export_colCashDiff => '现金差额';

  @override
  String get export_colCardDiff => '刷卡差额';

  @override
  String get export_colPaymentMethod => '支付方式';

  @override
  String get export_colSupplier => '供应商';

  @override
  String get export_colInvoice => '发票号';

  @override
  String get export_colCategory => '类别';

  @override
  String get export_colBase => '税基';

  @override
  String get export_colVatPct => '增值税 %';

  @override
  String get export_colVat => '增值税';

  @override
  String get export_colTotal => '合计';

  @override
  String get export_colPayment => '付款';

  @override
  String get export_colReceipts => '凭证';

  @override
  String get export_colEmployee => '员工';

  @override
  String get export_colRole => '职位';

  @override
  String get export_colMonth => '月份';

  @override
  String get export_colGross => '税前';

  @override
  String get export_colNet => '税后';

  @override
  String get export_colEmployerSs => '公司社保';

  @override
  String get export_colWithdrawalType => '取款类型';

  @override
  String get export_reportTitle => '经营报表';

  @override
  String get export_restaurantNif => '税号';

  @override
  String get export_period => '期间';

  @override
  String get export_generatedOn => '生成于';

  @override
  String get export_totalSales => '销售总额';

  @override
  String get export_totalPurchases => '采购';

  @override
  String get export_totalFixedCosts => '固定成本';

  @override
  String get export_totalOtherExpenses => '其他支出';

  @override
  String get export_totalExpenses => '支出总额';

  @override
  String get export_totalPayroll => '人员成本';

  @override
  String get export_totalWithdrawals => '现金取款';

  @override
  String get export_totalCashDiscrepancy => '现金差额合计';

  @override
  String get export_totalCardDiscrepancy => '刷卡差额合计';

  @override
  String get export_pendingFixed => '待确认的固定成本';

  @override
  String get export_vatPaid => '进项增值税';

  @override
  String get export_averageTicket => '平均客单价';

  @override
  String get export_profit => '利润';

  @override
  String get export_dailyDetail => '每日明细';

  @override
  String get export_statusOpen => '进行中';

  @override
  String get export_statusClosed => '已结';

  @override
  String get export_statusNoActivity => '无营业';

  @override
  String get export_paymentPaid => '已付';

  @override
  String get export_paymentPending => '未付';

  @override
  String get actionSave => '保存';

  @override
  String get dayClosedBanner => '当日已结账';

  @override
  String get dayNoActivityBanner => '当日已标记为无营业';

  @override
  String get dayReopen => '重新打开';

  @override
  String get dayReopenAuthReason => '确认以重新打开当日账目';

  @override
  String get dayReopenReasonTitle => '重新打开的原因';

  @override
  String get dayReopened => '当日账目已重新打开';

  @override
  String get daySectionSales => '销售额';

  @override
  String get dayShiftLunch => '午市';

  @override
  String get dayShiftDinner => '晚市';

  @override
  String get dayCoversLunch => '午市客数';

  @override
  String get dayCoversDinner => '晚市客数';

  @override
  String get dayTotalSales => '销售总额';

  @override
  String get daySectionTips => '小费';

  @override
  String get dayTipsCash => '现金小费（€）';

  @override
  String get dayTipsCard => '刷卡小费（€）';

  @override
  String get daySectionCashOut => '现金支出';

  @override
  String get dayWithdrawals => '取款';

  @override
  String get dayCashExpenses => '现金支出费用';

  @override
  String get dayAddWithdrawal => '添加取款';

  @override
  String get dayAddCashExpense => '添加现金费用';

  @override
  String get dayNoneYet => '暂无';

  @override
  String get dayVoid => '作废';

  @override
  String get dayVoidReasonTitle => '作废原因';

  @override
  String get dayVoided => '已作废';

  @override
  String get daySectionCount => '盘点';

  @override
  String get dayOpeningFloat => '期初备用金（€）';

  @override
  String get dayOpeningFloatHint => '来自前一天的结账金额，仅在必要时修改。';

  @override
  String get dayCountTotal => '总额';

  @override
  String get dayCountDenominations => '纸币和硬币';

  @override
  String get dayCountedCash => '清点现金（€）';

  @override
  String get dayCountedCashValue => '清点现金';

  @override
  String get dayTerminalTotal => '刷卡机合计（€）';

  @override
  String get daySectionResult => '结果';

  @override
  String get dayExpected => '应有现金';

  @override
  String get dayCashDiff => '现金差额';

  @override
  String get dayCardDiff => '刷卡差额';

  @override
  String get dayOver => '多出';

  @override
  String get dayShort => '短少';

  @override
  String get dayDiffPending => '待填写数据';

  @override
  String get dayComment => '备注';

  @override
  String get dayCommentRequired => '备注（有差额时必填）';

  @override
  String get dayCloseButton => '结账';

  @override
  String get dayClosedNoPending => '已结账，没有待处理的日期';

  @override
  String get dayFormInvalid => '请检查标记的金额';

  @override
  String get dayErrCommentRequired => '有差额时请填写备注后再结账';

  @override
  String get dayErrCountedMissing => '请填写清点现金';

  @override
  String get dayErrTerminalMissing => '请填写刷卡机合计';

  @override
  String get dayErrLocked => '该日或其所在月份已结账，请先重新打开';

  @override
  String get dayErrNotOpen => '当日账目未处于打开状态';

  @override
  String get dayErrSave => '无法保存，请重试。';

  @override
  String get dayLoadError => '无法打开当日账目';

  @override
  String get dayInvalidDate => '日期无效';

  @override
  String get sheetWithdrawalTitle => '新建取款';

  @override
  String get sheetCashExpenseTitle => '新建现金费用';

  @override
  String get fieldAmount => '金额（€）';

  @override
  String get fieldTotalAmount => '总金额（€）';

  @override
  String get fieldType => '类型';

  @override
  String get fieldNote => '备注（可选）';

  @override
  String get fieldCategory => '类别';

  @override
  String get fieldSupplierOptional => '供应商（可选）';

  @override
  String get fieldVat => '增值税';

  @override
  String get fieldInvoiceOptional => '发票号（可选）';

  @override
  String get noSupplier => '无供应商';

  @override
  String get amountMustBePositive => '金额必须大于零';

  @override
  String get expTabPending => '待付款';

  @override
  String get expTabAll => '全部';

  @override
  String get expIncomplete => '缺凭证';

  @override
  String get expVoidedChip => '已作废';

  @override
  String get expEmpty => '暂无费用';

  @override
  String expDueOn(String date) {
    return '到期日 $date';
  }

  @override
  String get expTotalsTitle => '按供应商和类别汇总';

  @override
  String get expTotalsBySupplier => '按供应商';

  @override
  String get expTotalsByCategory => '按类别';

  @override
  String get expFieldDate => '日期';

  @override
  String get expFieldSupplier => '供应商';

  @override
  String get expSupplierPick => '选择供应商';

  @override
  String get expSupplierSearch => '搜索供应商';

  @override
  String get expSupplierNew => '新建供应商';

  @override
  String get expSupplierClear => '移除供应商';

  @override
  String get expFieldBase => '税前金额（€）';

  @override
  String get expFieldTotal => '合计（€）';

  @override
  String get expFieldPayment => '付款方式';

  @override
  String get expFieldDue => '到期日';

  @override
  String get expDueNone => '无到期日';

  @override
  String get expStatusPaid => '已付';

  @override
  String get expStatusPending => '未付';

  @override
  String get expSummaryBase => '税前';

  @override
  String get expSummaryVat => '增值税';

  @override
  String get expSummaryTotal => '合计';

  @override
  String get expReceipts => '凭证';

  @override
  String get expReceiptCamera => '拍照';

  @override
  String get expReceiptGallery => '相册';

  @override
  String get expReceiptPdf => 'PDF';

  @override
  String get expReceiptNone => '暂无凭证';

  @override
  String get expReceiptError => '无法添加凭证';

  @override
  String get expVoidButton => '作废费用';

  @override
  String get expVoidReasonTitle => '作废原因';

  @override
  String get expLockedBanner => '该费用属于已结账的期间，无法修改';

  @override
  String expVoidedBanner(String reason) {
    return '费用已作废：$reason';
  }

  @override
  String get expErrSave => '无法保存费用';

  @override
  String get expErrLocked => '该期间已结账，请先重新打开';

  @override
  String get expNotFound => '未找到该费用';

  @override
  String get suppFieldName => '名称';

  @override
  String get suppFieldNif => '税号';

  @override
  String get suppFieldPhone => '电话';

  @override
  String get suppFieldCategory => '默认类别';

  @override
  String get suppNone => '暂无供应商';

  @override
  String get suppNewTitle => '新建供应商';

  @override
  String get suppEditTitle => '编辑供应商';

  @override
  String get suppErrSave => '无法保存供应商';

  @override
  String get expLoadError => '无法加载该费用';

  @override
  String get fixedCostNewTitle => '新增固定成本';

  @override
  String get fixedCostEditTitle => '编辑固定成本';

  @override
  String get fixedCostFieldConcept => '名称';

  @override
  String get fixedCostFieldPeriodicity => '周期';

  @override
  String get fixedCostFieldChargeDay => '收费日 (1–31)';

  @override
  String get fixedCostFieldStartMonth => '起始月份 (YYYY-MM)';

  @override
  String get fixedCostFieldPlanned => '计划金额 (€)';

  @override
  String get fixedCostSectionDefs => '定义';

  @override
  String get fixedCostSectionPending => '待确认';

  @override
  String get fixedCostNone => '暂无固定成本';

  @override
  String get fixedCostNonePending => '暂无待确认项目';

  @override
  String get fixedCostConfirmTitle => '确认实际金额';

  @override
  String get fixedCostActive => '有效';

  @override
  String get fixedCostDeactivate => '停用';

  @override
  String get fixedCostActivate => '启用';

  @override
  String get fixedCostErrSave => '无法保存固定成本';

  @override
  String get periodicityMonthly => '每月';

  @override
  String get periodicityBimonthly => '每两月';

  @override
  String get periodicityQuarterly => '每季度';

  @override
  String get periodicityAnnual => '每年';

  @override
  String get payrollNoEmployees => '本月无在职员工';

  @override
  String get payrollErrSave => '无法保存工资';

  @override
  String get payrollTotalCost => '本月总成本';

  @override
  String get payrollPercentOfSales => '占营业额比例';

  @override
  String get payrollPaymentSave => '登记工资';

  @override
  String get payrollPaymentVoid => '作废工资';

  @override
  String get payrollVoidReasonTitle => '作废工资原因';

  @override
  String get payrollFieldGross => '税前 (€)';

  @override
  String get payrollFieldNet => '税后 (€)';

  @override
  String get payrollFieldEmployerSs => '社保 (€)';

  @override
  String get payrollEmployeeNewTitle => '新增员工';

  @override
  String get payrollEmployeeEditTitle => '编辑员工';

  @override
  String get payrollFieldHiredOn => '入职日期';

  @override
  String get payrollFieldLeftOn => '离职日期 (可选)';

  @override
  String get payrollNoPayment => '未登记工资';

  @override
  String get payrollErrEmployee => '无法保存员工';

  @override
  String get withdrawalsPeriodMonth => '本月';

  @override
  String get withdrawalsPeriodWeek => '本周';

  @override
  String get withdrawalsTotalsTitle => '按类型汇总';

  @override
  String get withdrawalsEmpty => '此期间无取款';

  @override
  String get withdrawalsErrLoad => '无法加载取款记录';

  @override
  String get reportPeriodLastMonth => '上个月';

  @override
  String get reportErrLoad => '无法加载报告';

  @override
  String get reportExportPdf => 'PDF';

  @override
  String get reportExportXlsx => 'Excel';

  @override
  String get reportExportCsv => 'CSV';

  @override
  String get reportExportGestor => 'Gestor ZIP';

  @override
  String get reportExportErr => '无法导出';

  @override
  String get reportNoData => '此期间无数据';

  @override
  String get alertEmpty => '暂无提醒';

  @override
  String get alertMissingReceipt => '支出缺少凭证';

  @override
  String get alertInvoiceOverdue => '发票已逾期';

  @override
  String get alertBackupOld => '已超过 14 天未备份';

  @override
  String get alertGoDay => '查看该日';

  @override
  String get alertGoExpense => '查看支出';

  @override
  String get alertGoBackup => '立即备份';

  @override
  String get settingsRestaurant => '餐厅信息';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsThreshold => '差异阈值 (€)';

  @override
  String get settingsBackupEvery => '备份提醒间隔 (天)';

  @override
  String get settingsChangePin => '修改 PIN';

  @override
  String get settingsBiometrics => '生物识别';

  @override
  String get settingsCatalogPayments => '支付方式';

  @override
  String get settingsCatalogCategories => '支出分类';

  @override
  String get settingsCatalogWithdrawals => '取款类型';

  @override
  String get settingsMonths => '账期管理';

  @override
  String get settingsSaved => '已保存';

  @override
  String get settingsErrSave => '无法保存';

  @override
  String get settingsPinChanged => 'PIN 已修改';

  @override
  String get settingsErrPin => '无法修改 PIN';

  @override
  String get settingsBiometricsNotAvailable => '此设备不支持生物识别';

  @override
  String get catalogNew => '新增';

  @override
  String get catalogFieldName => '名称';

  @override
  String get catalogActive => '有效';

  @override
  String get catalogInactive => '已停用';

  @override
  String get catalogErrSave => '无法保存';

  @override
  String get catalogEmpty => '暂无数据';

  @override
  String get historyEmpty => '暂无变更记录';

  @override
  String get historyErrLoad => '无法加载历史记录';

  @override
  String get historyField => '字段';

  @override
  String get historyOldValue => '原值';

  @override
  String get historyNewValue => '新值';

  @override
  String get backupSectionCreate => '创建备份';

  @override
  String get backupSectionRestore => '恢复备份';

  @override
  String get backupPasswordLabel => '密码 (最少 8 位)';

  @override
  String get backupPasswordConfirm => '确认密码';

  @override
  String get backupPasswordMismatch => '两次密码不一致';

  @override
  String get backupPasswordTooShort => '至少 8 个字符';

  @override
  String get backupCreateButton => '创建并导出';

  @override
  String get backupPickFile => '选择 .toaudit 文件';

  @override
  String get backupInspecting => '验证中…';

  @override
  String get backupPreviewTitle => '备份预览';

  @override
  String get backupPreviewDate => '备份日期';

  @override
  String get backupPreviewDays => '天数';

  @override
  String get backupPreviewExpenses => '支出数';

  @override
  String get backupRestoreButton => '立即恢复';

  @override
  String get backupRestoring => '恢复中…';

  @override
  String get backupRestoredTitle => '恢复完成';

  @override
  String get backupRestoredBody => '数据已成功恢复，请关闭并重新打开应用以应用更改。';

  @override
  String get backupErrDecrypt => '密码错误或文件损坏';

  @override
  String get backupErrTooNew => '此备份由更新版本的应用创建';

  @override
  String get backupErrRestore => '无法恢复备份';

  @override
  String get backupErrCreate => '无法创建备份';

  @override
  String get backupCancelDelete => '取消并清理';

  @override
  String get backupLastCopy => '上次备份';

  @override
  String get monthsClose => '关闭月份';

  @override
  String get monthsReopen => '重开月份';

  @override
  String get monthsStatusOpen => '开放';

  @override
  String get monthsStatusClosed => '已关闭';

  @override
  String get monthsErrSave => '无法更改月份状态';

  @override
  String get monthsReopenReasonTitle => '重开月份的原因';

  @override
  String get monthsErrAlreadyClosed => '月份已关闭';

  @override
  String get monthsEmpty => '暂无月份数据';

  @override
  String reportGestorMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '缺少 $count 份凭证',
      one: '缺少 1 份凭证',
    );
    return '警告：$_temp0';
  }

  @override
  String alertDiscrepancy(String date) {
    return '$date 存在差异';
  }

  @override
  String alertDayOpen(String date) {
    return '$date 仍处于开放状态';
  }

  @override
  String alertDayUnregistered(String date) {
    return '$date 未登记';
  }

  @override
  String alertFloatMismatch(String date) {
    return '$date 备用金不符';
  }

  @override
  String monthsErrNotReady(String dates) {
    return '以下日期尚未完成：$dates';
  }

  @override
  String get periodToday => '今天';

  @override
  String get periodCustom => '自定义';

  @override
  String get reportSavePdf => '保存 PDF';

  @override
  String get backupPasswordWarning => '请妥善保管此密码：没有它就无法恢复备份，也无法找回。';

  @override
  String get backupErrNotToaudit => '文件扩展名必须是 .toaudit';

  @override
  String get backupErrVerify => '恢复失败，已找回原有数据';

  @override
  String get backupErrRestart => '请重启应用以完成数据恢复';

  @override
  String get backupErrInspect => '无法读取备份';

  @override
  String get backupRestoreConfirm => '当前所有数据将被备份中的数据替换。是否继续？';

  @override
  String get backupCreated => '备份已创建';

  @override
  String get backupRestoredInApp => '备份已恢复';

  @override
  String get backupPasswordDialogTitle => '备份密码';
}

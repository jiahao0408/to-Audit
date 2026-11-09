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
}

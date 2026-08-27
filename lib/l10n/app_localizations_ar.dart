// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class LAr extends L {
  LAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Kite';

  @override
  String get navOverview => 'نظرة عامة';

  @override
  String get navManage => 'الإدارة';

  @override
  String get navApps => 'التطبيقات';

  @override
  String get navBuild => 'البناء';

  @override
  String get navDashboard => 'لوحة التحكم';

  @override
  String get navProjects => 'المشاريع';

  @override
  String get navOrders => 'الطلبات';

  @override
  String get navCustomers => 'العملاء';

  @override
  String get navProducts => 'المنتجات';

  @override
  String get navInbox => 'البريد';

  @override
  String get navBoard => 'اللوحة';

  @override
  String get navCalendar => 'التقويم';

  @override
  String get navChat => 'المحادثة';

  @override
  String get navComponents => 'المكوّنات';

  @override
  String get navForms => 'النماذج';

  @override
  String get navWizard => 'المعالج';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionEdit => 'تعديل';

  @override
  String get actionRefresh => 'تحديث';

  @override
  String get actionExport => 'تصدير';

  @override
  String get actionSearch => 'بحث';

  @override
  String get actionClear => 'مسح';

  @override
  String get actionPrevious => 'السابق';

  @override
  String get actionNext => 'التالي';

  @override
  String get actionSignIn => 'تسجيل الدخول';

  @override
  String get actionSignOut => 'تسجيل الخروج';

  @override
  String get signInTitle => 'تسجيل الدخول';

  @override
  String get signInSubtitle => 'أي بريد إلكتروني يعمل — هذا مزوّد تجريبي.';

  @override
  String get fieldEmail => 'البريد الإلكتروني';

  @override
  String get fieldPassword => 'كلمة المرور';

  @override
  String get fieldName => 'الاسم';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get noAccount => 'ليس لديك حساب؟ أنشئ واحدًا';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get language => 'اللغة';

  @override
  String get theme => 'المظهر';

  @override
  String get accent => 'اللون';

  @override
  String get emptyTitle => 'لا شيء يطابق عوامل التصفية';

  @override
  String get emptyMessage => 'جرّب مسح البحث أو اختيار حالة مختلفة.';

  @override
  String get errorTitle => 'حدث خطأ ما';

  @override
  String get errorRetry => 'إعادة المحاولة';

  @override
  String pageOf(int page, int pages) {
    return 'صفحة $page من $pages';
  }

  @override
  String rangeOfTotal(int first, int last, int total) {
    return '$first–$last من $total';
  }
}

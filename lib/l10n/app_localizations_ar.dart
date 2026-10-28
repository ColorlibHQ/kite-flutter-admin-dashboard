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

  @override
  String get authProductionSubtitle => 'سجّل الدخول بحساب فريقك.';

  @override
  String get authDemoNotice =>
      'وضع تجريبي: لا تُرسل رسائل ولا تُتحقق كلمات المرور.';

  @override
  String get authSigningIn => 'جارٍ تسجيل الدخول…';

  @override
  String get authInvalidEmail => 'أدخل بريدًا إلكترونيًا صالحًا.';

  @override
  String get authPasswordRequired => 'أدخل كلمة المرور.';

  @override
  String get authCreateAccount => 'إنشاء حساب';

  @override
  String get authCreateSubtitle => 'أنشئ حسابك. يمنح المسؤول صلاحيات الوصول.';

  @override
  String get authFullName => 'الاسم الكامل';

  @override
  String get authPasswordHint => 'استخدم 12 حرفًا على الأقل.';

  @override
  String get authAlreadyAccount => 'لديك حساب؟ سجّل الدخول';

  @override
  String get authBackToSignIn => 'العودة لتسجيل الدخول';

  @override
  String get authResetTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get authResetSubtitle => 'اطلب رابطًا لإعادة تعيين كلمة المرور.';

  @override
  String get authResetSent => 'إذا كان الحساب موجودًا، فسيصلك رابط قريبًا.';

  @override
  String get authSendReset => 'إرسال رابط إعادة التعيين';

  @override
  String get authVerifyTitle => 'تحقق من بريدك الإلكتروني';

  @override
  String get authVerifySubtitle => 'افتح رابط البريد أو أدخل رمز التحقق.';

  @override
  String get authVerificationCode => 'رمز التحقق';

  @override
  String get authVerify => 'تحقق';

  @override
  String get authResend => 'إعادة إرسال الرمز';

  @override
  String get authCodeSent => 'راجع بريدك للتحقق من الحساب.';

  @override
  String get authDemoCode => 'رمز التحقق التجريبي: 123456';

  @override
  String get authUpdatePassword => 'تحديث كلمة المرور';

  @override
  String get authNewPassword => 'كلمة المرور الجديدة';

  @override
  String get authConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get authPasswordsMismatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get authLockTitle => 'الشاشة مقفلة';

  @override
  String get authUnlock => 'فتح القفل';

  @override
  String get authOtherAccount => 'تسجيل الدخول بحساب آخر';

  @override
  String get authInvalidCredentials => 'بيانات الدخول أو رمز التحقق غير صحيح.';

  @override
  String get authUnconfirmed => 'أكد بريدك قبل تسجيل الدخول.';

  @override
  String get authWeakPassword => 'اختر كلمة مرور أقوى من 12 حرفًا على الأقل.';

  @override
  String get authRateLimited => 'محاولات كثيرة. انتظر قليلًا وحاول مجددًا.';

  @override
  String get authConnectionError =>
      'تعذر الاتصال. تحقق من اتصالك وحاول مجددًا.';

  @override
  String get authUnavailable => 'المصادقة غير متاحة. حاول مجددًا.';

  @override
  String get authCallbackFailed =>
      'تعذر التحقق من الرابط. اطلب رابطًا جديدًا أو سجّل الدخول.';

  @override
  String get working => 'جارٍ التنفيذ…';

  @override
  String get loading => 'جارٍ التحميل';

  @override
  String get accessDenied => 'تم رفض الوصول';

  @override
  String get accessDeniedMessage =>
      'لا يملك حسابك صلاحية لهذا الإجراء. اطلب الوصول من المسؤول.';

  @override
  String get roleNone => 'بلا صلاحيات';

  @override
  String get roleViewer => 'مشاهد';

  @override
  String get roleEditor => 'محرر';

  @override
  String get roleAdmin => 'مسؤول';

  @override
  String get appearance => 'المظهر';

  @override
  String get account => 'الحساب';

  @override
  String get role => 'الدور';

  @override
  String get dataSource => 'مصدر البيانات';

  @override
  String get dataSourceHelp =>
      'تستخدم القوائم والبحث والتعديلات مصدر البيانات المحدد. تُمسح تغييرات العرض التجريبي عند إعادة التشغيل.';

  @override
  String get systemMode => 'النظام';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get accentSlate => 'رمادي';

  @override
  String get accentBlue => 'أزرق';

  @override
  String get accentViolet => 'بنفسجي';

  @override
  String get languageHelp =>
      'تُحفظ اللغة والسمة ولون التمييز على هذا الجهاز. تستخدم العربية تخطيطًا من اليمين إلى اليسار.';

  @override
  String get preferenceSaveFailed => 'تعذر حفظ التفضيلات. حاول مجددًا.';

  @override
  String get details => 'التفاصيل';

  @override
  String get chooseOne => 'اختر خيارًا';

  @override
  String get optional => 'اختياري';

  @override
  String get numbersOnly => 'أدخل رقمًا صالحًا.';

  @override
  String get couldNotSave => 'تعذر الحفظ';

  @override
  String get refreshed => 'تم التحديث';

  @override
  String get openRecord => 'فتح السجل';

  @override
  String get openNavigation => 'فتح التنقل';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get accountMenu => 'قائمة الحساب';

  @override
  String get order => 'طلب';

  @override
  String get customer => 'عميل';

  @override
  String get product => 'منتج';

  @override
  String get fieldStatus => 'الحالة';

  @override
  String get fieldItems => 'العناصر';

  @override
  String get fieldTotal => 'الإجمالي';

  @override
  String get fieldDate => 'التاريخ';

  @override
  String get fieldNotes => 'ملاحظات';

  @override
  String get fieldSpend => 'إجمالي الإنفاق';

  @override
  String get fieldSku => 'رمز المنتج';

  @override
  String get fieldPrice => 'السعر';

  @override
  String get fieldStock => 'المخزون';

  @override
  String get statusPaid => 'مدفوع';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusRefunded => 'مسترد';

  @override
  String get statusShipped => 'تم الشحن';

  @override
  String get statusCancelled => 'ملغى';

  @override
  String get statusActive => 'نشط';

  @override
  String get statusChurned => 'غير نشط';

  @override
  String get statusInStock => 'متوفر';

  @override
  String get statusLow => 'منخفض';

  @override
  String get statusOutOfStock => 'نفد المخزون';

  @override
  String newResource(String resource) {
    return 'إنشاء $resource';
  }

  @override
  String editRecord(String record) {
    return 'تعديل $record';
  }

  @override
  String deleteRecord(String record) {
    return 'حذف $record؟';
  }

  @override
  String get deleteWarning => 'سيؤدي هذا إلى حذف السجل نهائيًا.';

  @override
  String recordDeleted(String record) {
    return 'تم حذف $record';
  }

  @override
  String recordCreated(String record) {
    return 'تم إنشاء $record';
  }

  @override
  String recordSaved(String record) {
    return 'تم حفظ $record';
  }

  @override
  String searchResource(String resource) {
    return 'البحث في $resource…';
  }

  @override
  String requiredField(String field) {
    return 'حقل $field مطلوب.';
  }

  @override
  String chooseField(String field) {
    return 'اختر $field.';
  }

  @override
  String fieldsNeedAttention(int count) {
    return 'يرجى مراجعة $count من الحقول';
  }

  @override
  String get authDemoAccount => 'حساب تجريبي';

  @override
  String authDemoCredentials(String email, String password) {
    return 'البريد الإلكتروني: $email\nكلمة المرور: $password';
  }

  @override
  String get authDemoHelp =>
      'استكشف بهذا الحساب المُعبّأ مسبقًا. لا يلزم التسجيل؛ تُعاد بيانات العرض عند إعادة التشغيل.';

  @override
  String get authPreviewHelp => 'هل تريد استكشاف القالب دون حساب؟';

  @override
  String get authOpenDemo => 'جرّب العرض العام';
}

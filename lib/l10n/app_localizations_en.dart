// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LEn extends L {
  LEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Kite';

  @override
  String get navOverview => 'Overview';

  @override
  String get navManage => 'Manage';

  @override
  String get navApps => 'Apps';

  @override
  String get navBuild => 'Build';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navProjects => 'Projects';

  @override
  String get navOrders => 'Orders';

  @override
  String get navCustomers => 'Customers';

  @override
  String get navProducts => 'Products';

  @override
  String get navInbox => 'Inbox';

  @override
  String get navBoard => 'Board';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navChat => 'Chat';

  @override
  String get navComponents => 'Components';

  @override
  String get navForms => 'Forms';

  @override
  String get navWizard => 'Wizard';

  @override
  String get navSettings => 'Settings';

  @override
  String get navProfile => 'Profile';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionRefresh => 'Refresh';

  @override
  String get actionExport => 'Export';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionPrevious => 'Previous';

  @override
  String get actionNext => 'Next';

  @override
  String get actionSignIn => 'Sign in';

  @override
  String get actionSignOut => 'Sign out';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signInSubtitle => 'Any email works — this is the mock provider.';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldName => 'Name';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get noAccount => 'No account? Create one';

  @override
  String get lightMode => 'Light mode';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get accent => 'Accent';

  @override
  String get emptyTitle => 'Nothing matches those filters';

  @override
  String get emptyMessage =>
      'Try clearing the search or choosing a different status.';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorRetry => 'Try again';

  @override
  String pageOf(int page, int pages) {
    return 'Page $page of $pages';
  }

  @override
  String rangeOfTotal(int first, int last, int total) {
    return '$first–$last of $total';
  }

  @override
  String get authProductionSubtitle => 'Sign in with your team account.';

  @override
  String get authDemoNotice =>
      'Demo mode: no email is sent and no password is verified.';

  @override
  String get authSigningIn => 'Signing in…';

  @override
  String get authInvalidEmail => 'Enter a valid email address.';

  @override
  String get authPasswordRequired => 'Enter your password.';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authCreateSubtitle =>
      'Create your team account. An administrator assigns access.';

  @override
  String get authFullName => 'Full name';

  @override
  String get authPasswordHint => 'Use at least 12 characters.';

  @override
  String get authAlreadyAccount => 'Already have an account? Sign in';

  @override
  String get authBackToSignIn => 'Back to sign in';

  @override
  String get authResetTitle => 'Reset password';

  @override
  String get authResetSubtitle => 'Request a link to reset your password.';

  @override
  String get authResetSent =>
      'If this account exists, a reset link will arrive shortly.';

  @override
  String get authSendReset => 'Send reset link';

  @override
  String get authVerifyTitle => 'Verify your email';

  @override
  String get authVerifySubtitle =>
      'Follow the email link or enter your verification code.';

  @override
  String get authVerificationCode => 'Verification code';

  @override
  String get authVerify => 'Verify';

  @override
  String get authResend => 'Resend code';

  @override
  String get authCodeSent => 'Check your email for the verification message.';

  @override
  String get authDemoCode => 'Demo verification code: 123456';

  @override
  String get authUpdatePassword => 'Update password';

  @override
  String get authNewPassword => 'New password';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authPasswordsMismatch => 'Passwords do not match.';

  @override
  String get authLockTitle => 'Screen locked';

  @override
  String get authUnlock => 'Unlock';

  @override
  String get authOtherAccount => 'Sign in as someone else';

  @override
  String get authInvalidCredentials =>
      'The credentials or verification code are invalid.';

  @override
  String get authUnconfirmed => 'Confirm your email before signing in.';

  @override
  String get authWeakPassword =>
      'Choose a stronger password with at least 12 characters.';

  @override
  String get authRateLimited =>
      'Too many attempts. Wait a moment and try again.';

  @override
  String get authConnectionError =>
      'Could not connect. Check your connection and try again.';

  @override
  String get authUnavailable =>
      'Authentication is unavailable. Please try again.';

  @override
  String get authCallbackFailed =>
      'This link could not be verified. Request a new link or sign in.';

  @override
  String get working => 'Working…';

  @override
  String get loading => 'Loading';

  @override
  String get accessDenied => 'Access denied';

  @override
  String get accessDeniedMessage =>
      'Your account does not have permission for this action. Ask an administrator for access.';

  @override
  String get roleNone => 'No access';

  @override
  String get roleViewer => 'Viewer';

  @override
  String get roleEditor => 'Editor';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get appearance => 'Appearance';

  @override
  String get account => 'Account';

  @override
  String get role => 'Role';

  @override
  String get dataSource => 'Data source';

  @override
  String get dataSourceHelp =>
      'Resource lists, search, and edits use your configured data source. Demo changes reset on restart.';

  @override
  String get systemMode => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get accentSlate => 'Slate';

  @override
  String get accentBlue => 'Blue';

  @override
  String get accentViolet => 'Violet';

  @override
  String get languageHelp =>
      'Language, theme, and accent are saved on this device. Arabic uses a right-to-left layout.';

  @override
  String get preferenceSaveFailed =>
      'Preferences could not be saved. Try again.';

  @override
  String get details => 'Details';

  @override
  String get chooseOne => 'Choose one';

  @override
  String get optional => 'Optional';

  @override
  String get numbersOnly => 'Enter a valid number.';

  @override
  String get couldNotSave => 'Could not save';

  @override
  String get refreshed => 'Refreshed';

  @override
  String get openRecord => 'Open record';

  @override
  String get openNavigation => 'Open navigation';

  @override
  String get notifications => 'Notifications';

  @override
  String get accountMenu => 'Account menu';

  @override
  String get order => 'Order';

  @override
  String get customer => 'Customer';

  @override
  String get product => 'Product';

  @override
  String get fieldStatus => 'Status';

  @override
  String get fieldItems => 'Items';

  @override
  String get fieldTotal => 'Total';

  @override
  String get fieldDate => 'Date';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get fieldSpend => 'Lifetime spend';

  @override
  String get fieldSku => 'SKU';

  @override
  String get fieldPrice => 'Price';

  @override
  String get fieldStock => 'Stock';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusRefunded => 'Refunded';

  @override
  String get statusShipped => 'Shipped';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusActive => 'Active';

  @override
  String get statusChurned => 'Churned';

  @override
  String get statusInStock => 'In stock';

  @override
  String get statusLow => 'Low';

  @override
  String get statusOutOfStock => 'Out of stock';

  @override
  String newResource(String resource) {
    return 'New $resource';
  }

  @override
  String editRecord(String record) {
    return 'Edit $record';
  }

  @override
  String deleteRecord(String record) {
    return 'Delete $record?';
  }

  @override
  String get deleteWarning => 'This permanently removes the record.';

  @override
  String recordDeleted(String record) {
    return '$record deleted';
  }

  @override
  String recordCreated(String record) {
    return '$record created';
  }

  @override
  String recordSaved(String record) {
    return '$record saved';
  }

  @override
  String searchResource(String resource) {
    return 'Search $resource…';
  }

  @override
  String requiredField(String field) {
    return '$field is required.';
  }

  @override
  String chooseField(String field) {
    return 'Choose $field.';
  }

  @override
  String fieldsNeedAttention(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fields need attention',
      one: 'One field needs attention',
    );
    return '$_temp0';
  }

  @override
  String get authDemoAccount => 'Demo account';

  @override
  String authDemoCredentials(String email, String password) {
    return 'Email: $email\nPassword: $password';
  }

  @override
  String get authDemoHelp =>
      'Use this prefilled account to explore. No registration needed; demo data resets on restart.';

  @override
  String get authPreviewHelp =>
      'Want to explore the template without an account?';

  @override
  String get authOpenDemo => 'Try the public demo';
}

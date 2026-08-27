// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class LJa extends L {
  LJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'Kite';

  @override
  String get navOverview => '概要';

  @override
  String get navManage => '管理';

  @override
  String get navApps => 'アプリ';

  @override
  String get navBuild => 'ビルド';

  @override
  String get navDashboard => 'ダッシュボード';

  @override
  String get navProjects => 'プロジェクト';

  @override
  String get navOrders => '注文';

  @override
  String get navCustomers => '顧客';

  @override
  String get navProducts => '商品';

  @override
  String get navInbox => '受信箱';

  @override
  String get navBoard => 'ボード';

  @override
  String get navCalendar => 'カレンダー';

  @override
  String get navChat => 'チャット';

  @override
  String get navComponents => 'コンポーネント';

  @override
  String get navForms => 'フォーム';

  @override
  String get navWizard => 'ウィザード';

  @override
  String get navSettings => '設定';

  @override
  String get navProfile => 'プロフィール';

  @override
  String get actionSave => '保存';

  @override
  String get actionCancel => 'キャンセル';

  @override
  String get actionDelete => '削除';

  @override
  String get actionEdit => '編集';

  @override
  String get actionRefresh => '更新';

  @override
  String get actionExport => '書き出し';

  @override
  String get actionSearch => '検索';

  @override
  String get actionClear => 'クリア';

  @override
  String get actionPrevious => '前へ';

  @override
  String get actionNext => '次へ';

  @override
  String get actionSignIn => 'サインイン';

  @override
  String get actionSignOut => 'サインアウト';

  @override
  String get signInTitle => 'サインイン';

  @override
  String get signInSubtitle => 'どのメールでも使えます — モックプロバイダです。';

  @override
  String get fieldEmail => 'メール';

  @override
  String get fieldPassword => 'パスワード';

  @override
  String get fieldName => '名前';

  @override
  String get forgotPassword => 'パスワードをお忘れですか？';

  @override
  String get noAccount => 'アカウントがありませんか？作成する';

  @override
  String get lightMode => 'ライトモード';

  @override
  String get darkMode => 'ダークモード';

  @override
  String get language => '言語';

  @override
  String get theme => 'テーマ';

  @override
  String get accent => 'アクセント';

  @override
  String get emptyTitle => '条件に一致するものがありません';

  @override
  String get emptyMessage => '検索を消すか、別のステータスを選んでください。';

  @override
  String get errorTitle => '問題が発生しました';

  @override
  String get errorRetry => '再試行';

  @override
  String pageOf(int page, int pages) {
    return '$pages ページ中 $page ページ';
  }

  @override
  String rangeOfTotal(int first, int last, int total) {
    return '$total 件中 $first〜$last 件';
  }
}

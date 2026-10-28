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

  @override
  String get authProductionSubtitle => 'チームアカウントでログインしてください。';

  @override
  String get authDemoNotice => 'デモモード：メール送信やパスワード確認は行いません。';

  @override
  String get authSigningIn => 'ログイン中…';

  @override
  String get authInvalidEmail => '有効なメールアドレスを入力してください。';

  @override
  String get authPasswordRequired => 'パスワードを入力してください。';

  @override
  String get authCreateAccount => 'アカウント作成';

  @override
  String get authCreateSubtitle => 'アカウントを作成すると、管理者が権限を付与します。';

  @override
  String get authFullName => '氏名';

  @override
  String get authPasswordHint => '12文字以上を使用してください。';

  @override
  String get authAlreadyAccount => 'アカウントをお持ちですか？ログイン';

  @override
  String get authBackToSignIn => 'ログインに戻る';

  @override
  String get authResetTitle => 'パスワードの再設定';

  @override
  String get authResetSubtitle => 'パスワード再設定リンクをリクエストします。';

  @override
  String get authResetSent => 'アカウントが存在する場合、再設定リンクが届きます。';

  @override
  String get authSendReset => '再設定リンクを送信';

  @override
  String get authVerifyTitle => 'メールを確認';

  @override
  String get authVerifySubtitle => 'メールのリンクを開くか、確認コードを入力してください。';

  @override
  String get authVerificationCode => '確認コード';

  @override
  String get authVerify => '確認';

  @override
  String get authResend => 'コードを再送信';

  @override
  String get authCodeSent => '確認メールをご確認ください。';

  @override
  String get authDemoCode => 'デモ確認コード：123456';

  @override
  String get authUpdatePassword => 'パスワードを更新';

  @override
  String get authNewPassword => '新しいパスワード';

  @override
  String get authConfirmPassword => 'パスワードの確認';

  @override
  String get authPasswordsMismatch => 'パスワードが一致しません。';

  @override
  String get authLockTitle => '画面ロック';

  @override
  String get authUnlock => 'ロック解除';

  @override
  String get authOtherAccount => '別のアカウントでログイン';

  @override
  String get authInvalidCredentials => '認証情報または確認コードが正しくありません。';

  @override
  String get authUnconfirmed => 'ログイン前にメールを確認してください。';

  @override
  String get authWeakPassword => '12文字以上の強力なパスワードを設定してください。';

  @override
  String get authRateLimited => '試行回数が多すぎます。しばらくしてから再試行してください。';

  @override
  String get authConnectionError => '接続できませんでした。接続を確認して再試行してください。';

  @override
  String get authUnavailable => '認証を利用できません。再試行してください。';

  @override
  String get authCallbackFailed => 'リンクを確認できませんでした。新しいリンクを取得するかログインしてください。';

  @override
  String get working => '処理中…';

  @override
  String get loading => '読み込み中';

  @override
  String get accessDenied => 'アクセスが拒否されました';

  @override
  String get accessDeniedMessage => 'この操作の権限がありません。管理者にアクセス権を依頼してください。';

  @override
  String get roleNone => 'アクセス権なし';

  @override
  String get roleViewer => '閲覧者';

  @override
  String get roleEditor => '編集者';

  @override
  String get roleAdmin => '管理者';

  @override
  String get appearance => '外観';

  @override
  String get account => 'アカウント';

  @override
  String get role => '役割';

  @override
  String get dataSource => 'データソース';

  @override
  String get dataSourceHelp =>
      '一覧、検索、編集には設定済みのデータソースを使用します。デモの変更は再起動時にリセットされます。';

  @override
  String get systemMode => 'システム';

  @override
  String get light => 'ライト';

  @override
  String get dark => 'ダーク';

  @override
  String get accentSlate => 'スレート';

  @override
  String get accentBlue => 'ブルー';

  @override
  String get accentViolet => 'バイオレット';

  @override
  String get languageHelp => '言語、テーマ、アクセントはこの端末に保存されます。アラビア語は右から左のレイアウトです。';

  @override
  String get preferenceSaveFailed => '設定を保存できませんでした。再試行してください。';

  @override
  String get details => '詳細';

  @override
  String get chooseOne => '選択してください';

  @override
  String get optional => '任意';

  @override
  String get numbersOnly => '有効な数値を入力してください。';

  @override
  String get couldNotSave => '保存できませんでした';

  @override
  String get refreshed => '更新しました';

  @override
  String get openRecord => 'レコードを開く';

  @override
  String get openNavigation => 'ナビゲーションを開く';

  @override
  String get notifications => '通知';

  @override
  String get accountMenu => 'アカウントメニュー';

  @override
  String get order => '注文';

  @override
  String get customer => '顧客';

  @override
  String get product => '商品';

  @override
  String get fieldStatus => '状態';

  @override
  String get fieldItems => '商品数';

  @override
  String get fieldTotal => '合計';

  @override
  String get fieldDate => '日付';

  @override
  String get fieldNotes => 'メモ';

  @override
  String get fieldSpend => '累計購入額';

  @override
  String get fieldSku => 'SKU';

  @override
  String get fieldPrice => '価格';

  @override
  String get fieldStock => '在庫';

  @override
  String get statusPaid => '支払い済み';

  @override
  String get statusPending => '保留中';

  @override
  String get statusRefunded => '返金済み';

  @override
  String get statusShipped => '発送済み';

  @override
  String get statusCancelled => 'キャンセル済み';

  @override
  String get statusActive => '有効';

  @override
  String get statusChurned => '離脱';

  @override
  String get statusInStock => '在庫あり';

  @override
  String get statusLow => '在庫わずか';

  @override
  String get statusOutOfStock => '在庫切れ';

  @override
  String newResource(String resource) {
    return '$resourceを作成';
  }

  @override
  String editRecord(String record) {
    return '$recordを編集';
  }

  @override
  String deleteRecord(String record) {
    return '$recordを削除しますか？';
  }

  @override
  String get deleteWarning => 'このレコードは完全に削除されます。';

  @override
  String recordDeleted(String record) {
    return '$recordを削除しました';
  }

  @override
  String recordCreated(String record) {
    return '$recordを作成しました';
  }

  @override
  String recordSaved(String record) {
    return '$recordを保存しました';
  }

  @override
  String searchResource(String resource) {
    return '$resourceを検索…';
  }

  @override
  String requiredField(String field) {
    return '$fieldは必須です。';
  }

  @override
  String chooseField(String field) {
    return '$fieldを選択してください。';
  }

  @override
  String fieldsNeedAttention(int count) {
    return '$count個の項目を確認してください';
  }

  @override
  String get authDemoAccount => 'デモアカウント';

  @override
  String authDemoCredentials(String email, String password) {
    return 'メール: $email\nパスワード: $password';
  }

  @override
  String get authDemoHelp => '入力済みのアカウントでお試しください。登録は不要です。デモデータは再起動時にリセットされます。';

  @override
  String get authPreviewHelp => 'アカウントなしでテンプレートを試しますか？';

  @override
  String get authOpenDemo => '公開デモを試す';
}

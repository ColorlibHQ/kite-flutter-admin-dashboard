// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class LFr extends L {
  LFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Kite';

  @override
  String get navOverview => 'Aperçu';

  @override
  String get navManage => 'Gérer';

  @override
  String get navApps => 'Applications';

  @override
  String get navBuild => 'Créer';

  @override
  String get navDashboard => 'Tableau de bord';

  @override
  String get navProjects => 'Projets';

  @override
  String get navOrders => 'Commandes';

  @override
  String get navCustomers => 'Clients';

  @override
  String get navProducts => 'Produits';

  @override
  String get navInbox => 'Boîte de réception';

  @override
  String get navBoard => 'Tableau';

  @override
  String get navCalendar => 'Calendrier';

  @override
  String get navChat => 'Discussion';

  @override
  String get navComponents => 'Composants';

  @override
  String get navForms => 'Formulaires';

  @override
  String get navWizard => 'Assistant';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get navProfile => 'Profil';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get actionRefresh => 'Actualiser';

  @override
  String get actionExport => 'Exporter';

  @override
  String get actionSearch => 'Rechercher';

  @override
  String get actionClear => 'Effacer';

  @override
  String get actionPrevious => 'Précédent';

  @override
  String get actionNext => 'Suivant';

  @override
  String get actionSignIn => 'Se connecter';

  @override
  String get actionSignOut => 'Se déconnecter';

  @override
  String get signInTitle => 'Se connecter';

  @override
  String get signInSubtitle =>
      'N\'importe quel e-mail convient — c\'est le fournisseur simulé.';

  @override
  String get fieldEmail => 'E-mail';

  @override
  String get fieldPassword => 'Mot de passe';

  @override
  String get fieldName => 'Nom';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get noAccount => 'Pas de compte ? Créez-en un';

  @override
  String get lightMode => 'Mode clair';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get language => 'Langue';

  @override
  String get theme => 'Thème';

  @override
  String get accent => 'Accent';

  @override
  String get emptyTitle => 'Aucun résultat pour ces filtres';

  @override
  String get emptyMessage =>
      'Essayez d\'effacer la recherche ou de choisir un autre statut.';

  @override
  String get errorTitle => 'Une erreur est survenue';

  @override
  String get errorRetry => 'Réessayer';

  @override
  String pageOf(int page, int pages) {
    return 'Page $page sur $pages';
  }

  @override
  String rangeOfTotal(int first, int last, int total) {
    return '$first–$last sur $total';
  }

  @override
  String get authProductionSubtitle =>
      'Connectez-vous avec votre compte professionnel.';

  @override
  String get authDemoNotice =>
      'Mode démo : aucun e-mail envoyé ni mot de passe vérifié.';

  @override
  String get authSigningIn => 'Connexion…';

  @override
  String get authInvalidEmail => 'Saisissez une adresse e-mail valide.';

  @override
  String get authPasswordRequired => 'Saisissez votre mot de passe.';

  @override
  String get authCreateAccount => 'Créer un compte';

  @override
  String get authCreateSubtitle =>
      'Créez votre compte. Un administrateur attribuera les accès.';

  @override
  String get authFullName => 'Nom complet';

  @override
  String get authPasswordHint => 'Utilisez au moins 12 caractères.';

  @override
  String get authAlreadyAccount => 'Déjà un compte ? Se connecter';

  @override
  String get authBackToSignIn => 'Retour à la connexion';

  @override
  String get authResetTitle => 'Réinitialiser le mot de passe';

  @override
  String get authResetSubtitle =>
      'Demandez un lien pour réinitialiser votre mot de passe.';

  @override
  String get authResetSent =>
      'Si ce compte existe, un lien arrivera prochainement.';

  @override
  String get authSendReset => 'Envoyer le lien';

  @override
  String get authVerifyTitle => 'Vérifiez votre e-mail';

  @override
  String get authVerifySubtitle =>
      'Ouvrez le lien reçu ou saisissez votre code.';

  @override
  String get authVerificationCode => 'Code de vérification';

  @override
  String get authVerify => 'Vérifier';

  @override
  String get authResend => 'Renvoyer le code';

  @override
  String get authCodeSent =>
      'Consultez votre messagerie pour vérifier votre compte.';

  @override
  String get authDemoCode => 'Code de démonstration : 123456';

  @override
  String get authUpdatePassword => 'Mettre à jour le mot de passe';

  @override
  String get authNewPassword => 'Nouveau mot de passe';

  @override
  String get authConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get authPasswordsMismatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get authLockTitle => 'Écran verrouillé';

  @override
  String get authUnlock => 'Déverrouiller';

  @override
  String get authOtherAccount => 'Utiliser un autre compte';

  @override
  String get authInvalidCredentials =>
      'Les identifiants ou le code sont incorrects.';

  @override
  String get authUnconfirmed =>
      'Confirmez votre e-mail avant de vous connecter.';

  @override
  String get authWeakPassword =>
      'Choisissez un mot de passe plus fort, avec au moins 12 caractères.';

  @override
  String get authRateLimited => 'Trop de tentatives. Patientez puis réessayez.';

  @override
  String get authConnectionError =>
      'Connexion impossible. Vérifiez votre connexion et réessayez.';

  @override
  String get authUnavailable => 'Authentification indisponible. Réessayez.';

  @override
  String get authCallbackFailed =>
      'Ce lien n’a pas pu être vérifié. Demandez-en un autre ou connectez-vous.';

  @override
  String get working => 'Traitement…';

  @override
  String get loading => 'Chargement';

  @override
  String get accessDenied => 'Accès refusé';

  @override
  String get accessDeniedMessage =>
      'Votre compte n’a pas cette autorisation. Demandez l’accès à un administrateur.';

  @override
  String get roleNone => 'Aucun accès';

  @override
  String get roleViewer => 'Lecteur';

  @override
  String get roleEditor => 'Éditeur';

  @override
  String get roleAdmin => 'Administrateur';

  @override
  String get appearance => 'Apparence';

  @override
  String get account => 'Compte';

  @override
  String get role => 'Rôle';

  @override
  String get dataSource => 'Source de données';

  @override
  String get dataSourceHelp =>
      'Les listes, recherches et modifications utilisent votre source configurée. Les données de démo sont réinitialisées au redémarrage.';

  @override
  String get systemMode => 'Système';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get accentSlate => 'Ardoise';

  @override
  String get accentBlue => 'Bleu';

  @override
  String get accentViolet => 'Violet';

  @override
  String get languageHelp =>
      'La langue, le thème et l’accent sont enregistrés sur cet appareil. L’arabe utilise une disposition de droite à gauche.';

  @override
  String get preferenceSaveFailed =>
      'Les préférences n’ont pas pu être enregistrées. Réessayez.';

  @override
  String get details => 'Détails';

  @override
  String get chooseOne => 'Choisissez une option';

  @override
  String get optional => 'Facultatif';

  @override
  String get numbersOnly => 'Saisissez un nombre valide.';

  @override
  String get couldNotSave => 'Enregistrement impossible';

  @override
  String get refreshed => 'Actualisé';

  @override
  String get openRecord => 'Ouvrir la fiche';

  @override
  String get openNavigation => 'Ouvrir la navigation';

  @override
  String get notifications => 'Notifications';

  @override
  String get accountMenu => 'Menu du compte';

  @override
  String get order => 'Commande';

  @override
  String get customer => 'Client';

  @override
  String get product => 'Produit';

  @override
  String get fieldStatus => 'Statut';

  @override
  String get fieldItems => 'Articles';

  @override
  String get fieldTotal => 'Total';

  @override
  String get fieldDate => 'Date';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get fieldSpend => 'Dépenses cumulées';

  @override
  String get fieldSku => 'Référence';

  @override
  String get fieldPrice => 'Prix';

  @override
  String get fieldStock => 'Stock';

  @override
  String get statusPaid => 'Payé';

  @override
  String get statusPending => 'En attente';

  @override
  String get statusRefunded => 'Remboursé';

  @override
  String get statusShipped => 'Expédié';

  @override
  String get statusCancelled => 'Annulé';

  @override
  String get statusActive => 'Actif';

  @override
  String get statusChurned => 'Inactif';

  @override
  String get statusInStock => 'En stock';

  @override
  String get statusLow => 'Faible';

  @override
  String get statusOutOfStock => 'Rupture de stock';

  @override
  String newResource(String resource) {
    return 'Créer : $resource';
  }

  @override
  String editRecord(String record) {
    return 'Modifier $record';
  }

  @override
  String deleteRecord(String record) {
    return 'Supprimer $record ?';
  }

  @override
  String get deleteWarning => 'Cette action supprime définitivement la fiche.';

  @override
  String recordDeleted(String record) {
    return '$record supprimé';
  }

  @override
  String recordCreated(String record) {
    return '$record créé';
  }

  @override
  String recordSaved(String record) {
    return '$record enregistré';
  }

  @override
  String searchResource(String resource) {
    return 'Rechercher dans $resource…';
  }

  @override
  String requiredField(String field) {
    return 'Le champ $field est obligatoire.';
  }

  @override
  String chooseField(String field) {
    return 'Choisissez $field.';
  }

  @override
  String fieldsNeedAttention(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count champs doivent être corrigés',
      one: 'Un champ doit être corrigé',
    );
    return '$_temp0';
  }

  @override
  String get authDemoAccount => 'Compte de démonstration';

  @override
  String authDemoCredentials(String email, String password) {
    return 'E-mail : $email\nMot de passe : $password';
  }

  @override
  String get authDemoHelp =>
      'Explorez avec ce compte prérempli. Aucune inscription requise ; les données sont réinitialisées au redémarrage.';

  @override
  String get authPreviewHelp =>
      'Vous souhaitez explorer le modèle sans compte ?';

  @override
  String get authOpenDemo => 'Essayer la démo publique';
}

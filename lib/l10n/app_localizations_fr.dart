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
}

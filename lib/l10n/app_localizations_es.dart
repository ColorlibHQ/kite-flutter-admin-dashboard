// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class LEs extends L {
  LEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Kite';

  @override
  String get navOverview => 'Resumen';

  @override
  String get navManage => 'Gestionar';

  @override
  String get navApps => 'Aplicaciones';

  @override
  String get navBuild => 'Construir';

  @override
  String get navDashboard => 'Panel';

  @override
  String get navProjects => 'Proyectos';

  @override
  String get navOrders => 'Pedidos';

  @override
  String get navCustomers => 'Clientes';

  @override
  String get navProducts => 'Productos';

  @override
  String get navInbox => 'Bandeja';

  @override
  String get navBoard => 'Tablero';

  @override
  String get navCalendar => 'Calendario';

  @override
  String get navChat => 'Chat';

  @override
  String get navComponents => 'Componentes';

  @override
  String get navForms => 'Formularios';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get navProfile => 'Perfil';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionRefresh => 'Actualizar';

  @override
  String get actionExport => 'Exportar';

  @override
  String get actionSearch => 'Buscar';

  @override
  String get actionClear => 'Limpiar';

  @override
  String get actionPrevious => 'Anterior';

  @override
  String get actionNext => 'Siguiente';

  @override
  String get actionSignIn => 'Iniciar sesión';

  @override
  String get actionSignOut => 'Cerrar sesión';

  @override
  String get signInTitle => 'Iniciar sesión';

  @override
  String get signInSubtitle =>
      'Cualquier correo sirve — es el proveedor simulado.';

  @override
  String get fieldEmail => 'Correo';

  @override
  String get fieldPassword => 'Contraseña';

  @override
  String get fieldName => 'Nombre';

  @override
  String get forgotPassword => '¿Olvidaste la contraseña?';

  @override
  String get noAccount => '¿Sin cuenta? Crea una';

  @override
  String get lightMode => 'Modo claro';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get language => 'Idioma';

  @override
  String get theme => 'Tema';

  @override
  String get accent => 'Acento';

  @override
  String get emptyTitle => 'Nada coincide con esos filtros';

  @override
  String get emptyMessage =>
      'Prueba a limpiar la búsqueda o elegir otro estado.';

  @override
  String get errorTitle => 'Algo salió mal';

  @override
  String get errorRetry => 'Reintentar';

  @override
  String pageOf(int page, int pages) {
    return 'Página $page de $pages';
  }

  @override
  String rangeOfTotal(int first, int last, int total) {
    return '$first–$last de $total';
  }
}

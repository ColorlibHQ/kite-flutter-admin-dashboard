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
  String get navWizard => 'Asistente';

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

  @override
  String get authProductionSubtitle => 'Inicia sesión con tu cuenta de equipo.';

  @override
  String get authDemoNotice =>
      'Modo de demostración: no se envían correos ni se verifican contraseñas.';

  @override
  String get authSigningIn => 'Iniciando sesión…';

  @override
  String get authInvalidEmail => 'Introduce un correo válido.';

  @override
  String get authPasswordRequired => 'Introduce tu contraseña.';

  @override
  String get authCreateAccount => 'Crear cuenta';

  @override
  String get authCreateSubtitle =>
      'Crea tu cuenta. Un administrador asignará el acceso.';

  @override
  String get authFullName => 'Nombre completo';

  @override
  String get authPasswordHint => 'Usa al menos 12 caracteres.';

  @override
  String get authAlreadyAccount => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get authBackToSignIn => 'Volver al inicio de sesión';

  @override
  String get authResetTitle => 'Restablecer contraseña';

  @override
  String get authResetSubtitle =>
      'Solicita un enlace para restablecer tu contraseña.';

  @override
  String get authResetSent =>
      'Si la cuenta existe, recibirás un enlace en breve.';

  @override
  String get authSendReset => 'Enviar enlace';

  @override
  String get authVerifyTitle => 'Verifica tu correo';

  @override
  String get authVerifySubtitle =>
      'Abre el enlace del correo o introduce el código.';

  @override
  String get authVerificationCode => 'Código de verificación';

  @override
  String get authVerify => 'Verificar';

  @override
  String get authResend => 'Reenviar código';

  @override
  String get authCodeSent => 'Revisa tu correo para verificar la cuenta.';

  @override
  String get authDemoCode => 'Código de demostración: 123456';

  @override
  String get authUpdatePassword => 'Actualizar contraseña';

  @override
  String get authNewPassword => 'Nueva contraseña';

  @override
  String get authConfirmPassword => 'Confirmar contraseña';

  @override
  String get authPasswordsMismatch => 'Las contraseñas no coinciden.';

  @override
  String get authLockTitle => 'Pantalla bloqueada';

  @override
  String get authUnlock => 'Desbloquear';

  @override
  String get authOtherAccount => 'Usar otra cuenta';

  @override
  String get authInvalidCredentials =>
      'Las credenciales o el código no son válidos.';

  @override
  String get authUnconfirmed => 'Confirma tu correo antes de iniciar sesión.';

  @override
  String get authWeakPassword =>
      'Elige una contraseña más segura de al menos 12 caracteres.';

  @override
  String get authRateLimited =>
      'Demasiados intentos. Espera e inténtalo de nuevo.';

  @override
  String get authConnectionError =>
      'No se pudo conectar. Revisa la conexión y reintenta.';

  @override
  String get authUnavailable =>
      'La autenticación no está disponible. Reinténtalo.';

  @override
  String get authCallbackFailed =>
      'No se pudo verificar el enlace. Solicita otro o inicia sesión.';

  @override
  String get working => 'Procesando…';

  @override
  String get loading => 'Cargando';

  @override
  String get accessDenied => 'Acceso denegado';

  @override
  String get accessDeniedMessage =>
      'Tu cuenta no tiene permiso. Solicita acceso a un administrador.';

  @override
  String get roleNone => 'Sin acceso';

  @override
  String get roleViewer => 'Lector';

  @override
  String get roleEditor => 'Editor';

  @override
  String get roleAdmin => 'Administrador';

  @override
  String get appearance => 'Apariencia';

  @override
  String get account => 'Cuenta';

  @override
  String get role => 'Rol';

  @override
  String get dataSource => 'Origen de datos';

  @override
  String get dataSourceHelp =>
      'Las listas, búsquedas y cambios usan el origen configurado. Los datos de demostración se reinician.';

  @override
  String get systemMode => 'Sistema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get accentSlate => 'Pizarra';

  @override
  String get accentBlue => 'Azul';

  @override
  String get accentViolet => 'Violeta';

  @override
  String get languageHelp =>
      'El idioma, tema y acento se guardan en este dispositivo. El árabe usa un diseño de derecha a izquierda.';

  @override
  String get preferenceSaveFailed =>
      'No se pudieron guardar las preferencias. Reinténtalo.';

  @override
  String get details => 'Detalles';

  @override
  String get chooseOne => 'Elige una opción';

  @override
  String get optional => 'Opcional';

  @override
  String get numbersOnly => 'Introduce un número válido.';

  @override
  String get couldNotSave => 'No se pudo guardar';

  @override
  String get refreshed => 'Actualizado';

  @override
  String get openRecord => 'Abrir registro';

  @override
  String get openNavigation => 'Abrir navegación';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get accountMenu => 'Menú de cuenta';

  @override
  String get order => 'Pedido';

  @override
  String get customer => 'Cliente';

  @override
  String get product => 'Producto';

  @override
  String get fieldStatus => 'Estado';

  @override
  String get fieldItems => 'Artículos';

  @override
  String get fieldTotal => 'Total';

  @override
  String get fieldDate => 'Fecha';

  @override
  String get fieldNotes => 'Notas';

  @override
  String get fieldSpend => 'Gasto total';

  @override
  String get fieldSku => 'SKU';

  @override
  String get fieldPrice => 'Precio';

  @override
  String get fieldStock => 'Existencias';

  @override
  String get statusPaid => 'Pagado';

  @override
  String get statusPending => 'Pendiente';

  @override
  String get statusRefunded => 'Reembolsado';

  @override
  String get statusShipped => 'Enviado';

  @override
  String get statusCancelled => 'Cancelado';

  @override
  String get statusActive => 'Activo';

  @override
  String get statusChurned => 'Inactivo';

  @override
  String get statusInStock => 'En stock';

  @override
  String get statusLow => 'Bajo';

  @override
  String get statusOutOfStock => 'Agotado';

  @override
  String newResource(String resource) {
    return 'Crear $resource';
  }

  @override
  String editRecord(String record) {
    return 'Editar $record';
  }

  @override
  String deleteRecord(String record) {
    return '¿Eliminar $record?';
  }

  @override
  String get deleteWarning => 'Esto elimina el registro permanentemente.';

  @override
  String recordDeleted(String record) {
    return '$record eliminado';
  }

  @override
  String recordCreated(String record) {
    return '$record creado';
  }

  @override
  String recordSaved(String record) {
    return '$record guardado';
  }

  @override
  String searchResource(String resource) {
    return 'Buscar en $resource…';
  }

  @override
  String requiredField(String field) {
    return '$field es obligatorio.';
  }

  @override
  String chooseField(String field) {
    return 'Elige $field.';
  }

  @override
  String fieldsNeedAttention(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count campos necesitan atención',
      one: 'Un campo necesita atención',
    );
    return '$_temp0';
  }

  @override
  String get authDemoAccount => 'Cuenta de demostración';

  @override
  String authDemoCredentials(String email, String password) {
    return 'Correo: $email\nContraseña: $password';
  }

  @override
  String get authDemoHelp =>
      'Explora con esta cuenta predefinida. No necesitas registrarte; los datos se restablecen al reiniciar.';

  @override
  String get authPreviewHelp =>
      '¿Quieres explorar la plantilla sin una cuenta?';

  @override
  String get authOpenDemo => 'Probar la demo pública';
}

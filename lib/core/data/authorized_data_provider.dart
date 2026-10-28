import '../auth/auth_models.dart';
import 'data_provider.dart';

/// Mirrors server policy for UX and blocks accidental unauthorized mutations.
/// This is not a replacement for RLS/API authorization on the server.
class AuthorizedDataProvider implements DataProvider {
  AuthorizedDataProvider(this.delegate, {required this.currentUser});
  final DataProvider delegate;
  final SessionUser? Function() currentUser;
  void _require(bool Function(UserRole) allows) {
    final user = currentUser();
    if (user == null || user.needsPasswordReset || !allows(user.role)) {
      throw const PermissionDeniedException();
    }
  }

  @override
  Future<ListResult> getList(String resource, ListParams params) {
    _require((role) => role.canRead);
    return delegate.getList(resource, params);
  }

  @override
  Future<JsonMap> getOne(String resource, String id) {
    _require((role) => role.canRead);
    return delegate.getOne(resource, id);
  }

  @override
  Future<JsonMap> create(String resource, JsonMap data) {
    _require((role) => role.canWrite);
    return delegate.create(resource, data);
  }

  @override
  Future<JsonMap> update(String resource, String id, JsonMap data) {
    _require((role) => role.canWrite);
    return delegate.update(resource, id, data);
  }

  @override
  Future<void> delete(String resource, String id) {
    _require((role) => role.canDelete);
    return delegate.delete(resource, id);
  }
}

class PermissionDeniedException extends DataProviderException {
  const PermissionDeniedException() : super('Permission denied.');
}

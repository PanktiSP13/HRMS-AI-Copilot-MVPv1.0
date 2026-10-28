import '../../common/constants/app_constants.dart';

class PolicyPermissions {
  PolicyPermissions._();

  /// Employee, Manager and HR Admin can view policies.
  static bool canView(String? role) {
    return role == UserRole.employee || role == UserRole.manager || role == UserRole.hrAdmin;
  }

  /// Only HR Admin can upload a policy PDF.
  static bool canUpload(String? role) {
    return role == UserRole.hrAdmin;
  }

  /// Only HR Admin can edit a policy.
  static bool canEdit(String? role) {
    return role == UserRole.hrAdmin;
  }

  /// Only HR Admin can delete a policy.
  static bool canDelete(String? role) {
    return role == UserRole.hrAdmin;
  }

  /// All roles that can view policies can download them.
  static bool canDownload(String? role) {
    return canView(role);
  }
}

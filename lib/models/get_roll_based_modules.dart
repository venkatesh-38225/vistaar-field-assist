class GetRoleBasedModule {
  final String? module;
  final String? role;
  final String? access;

  GetRoleBasedModule({
    this.module,
    this.role,
    this.access,
  });

  factory GetRoleBasedModule.fromJson(Map<String, dynamic> json) {
    return GetRoleBasedModule(
      module: json['module'] as String?,
      role: json['role'] as String?,
      access: json['access'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'module': module,
      'role': role,
      'access': access,
    };
  }
}

class GetRoleBasedModuleList {
  final bool success;
  final String? error;
  final List<GetRoleBasedModule> modulesList;

  GetRoleBasedModuleList({
    required this.success,
    this.error,
    required this.modulesList,
  });

  factory GetRoleBasedModuleList.fromJson(Map<String, dynamic> json) {
    var modulesData = json['modules'] as List?;
    return GetRoleBasedModuleList(
      success: json['success'] as bool? ?? false,
      error: json['error'] as String?,
      modulesList: modulesData != null
          ? modulesData
              .map((item) =>
                  GetRoleBasedModule.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'error': error,
      'modules': modulesList.map((item) => item.toJson()).toList(),
    };
  }

  List<String> get modules => modulesList.map((e) => e.module ?? '').toList();
}

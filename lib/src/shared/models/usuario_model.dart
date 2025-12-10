class Usuario {
  final String id;
  final String email;
  final String? telefono;
  final String nombre;
  final String apellido;
  final RolUsuario rol;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool activo;

  Usuario({
    required this.id,
    required this.email,
    this.telefono,
    required this.nombre,
    required this.apellido,
    required this.rol,
    required this.createdAt,
    this.updatedAt,
    this.activo = true,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      email: json['email'] as String,
      telefono: json['telefono'] as String?,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      rol: RolUsuario.fromString(json['rol'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      activo: json['activo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'telefono': telefono,
      'nombre': nombre,
      'apellido': apellido,
      'rol': rol.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'activo': activo,
    };
  }

  String get nombreCompleto => '$nombre $apellido';

  bool get esSuperadmin => rol == RolUsuario.superadmin;
  bool get esDueno => rol == RolUsuario.dueno;
  bool get esEmpleado => rol == RolUsuario.empleado;

  Usuario copyWith({
    String? id,
    String? email,
    String? telefono,
    String? nombre,
    String? apellido,
    RolUsuario? rol,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? activo,
  }) {
    return Usuario(
      id: id ?? this.id,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      rol: rol ?? this.rol,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      activo: activo ?? this.activo,
    );
  }
}

enum RolUsuario {
  superadmin,
  dueno,
  empleado;

  static RolUsuario fromString(String rol) {
    switch (rol.toLowerCase()) {
      case 'superadmin':
        return RolUsuario.superadmin;
      case 'dueno':
      case 'dueño':
        return RolUsuario.dueno;
      case 'empleado':
        return RolUsuario.empleado;
      default:
        return RolUsuario.empleado;
    }
  }

  String get displayName {
    switch (this) {
      case RolUsuario.superadmin:
        return 'Superadmin';
      case RolUsuario.dueno:
        return 'Dueño';
      case RolUsuario.empleado:
        return 'Empleado';
    }
  }
}

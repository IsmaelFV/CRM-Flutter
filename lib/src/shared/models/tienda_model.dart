class Tienda {
  final String id;
  final String nombre;
  final String? direccion;
  final String? telefono;
  final String? email;
  final String duenoId;
  final bool activa;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Tienda({
    required this.id,
    required this.nombre,
    this.direccion,
    this.telefono,
    this.email,
    required this.duenoId,
    this.activa = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory Tienda.fromJson(Map<String, dynamic> json) {
    return Tienda(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String?,
      telefono: json['telefono'] as String?,
      email: json['email'] as String?,
      duenoId: json['dueno_id'] as String,
      activa: json['activa'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'dueno_id': duenoId,
      'activa': activa,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Tienda copyWith({
    String? id,
    String? nombre,
    String? direccion,
    String? telefono,
    String? email,
    String? duenoId,
    bool? activa,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tienda(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      duenoId: duenoId ?? this.duenoId,
      activa: activa ?? this.activa,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

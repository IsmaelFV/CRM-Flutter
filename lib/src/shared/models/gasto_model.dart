class Gasto {
  final String id;
  final double importe;
  final DateTime fecha;
  final String concepto;
  final int? cantidad;
  final MetodoPago metodoPago;
  final String? comentarios;
  final String? fotoUrl;
  final String? categoriaGasto;
  final String creadoPorId;
  final String? creadoPorNombre;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Gasto({
    required this.id,
    required this.importe,
    required this.fecha,
    required this.concepto,
    this.cantidad,
    required this.metodoPago,
    this.comentarios,
    this.fotoUrl,
    this.categoriaGasto,
    required this.creadoPorId,
    this.creadoPorNombre,
    required this.createdAt,
    this.updatedAt,
  });

  factory Gasto.fromJson(Map<String, dynamic> json) {
    return Gasto(
      id: json['id'] as String,
      importe: (json['importe'] as num).toDouble(),
      fecha: DateTime.parse(json['fecha'] as String),
      concepto: json['concepto'] as String,
      cantidad: json['cantidad'] as int?,
      metodoPago: MetodoPago.fromString(json['metodo_pago'] as String),
      comentarios: json['comentarios'] as String?,
      fotoUrl: json['foto_url'] as String?,
      categoriaGasto: json['categoria_gasto'] as String?,
      creadoPorId: json['creado_por_id'] as String,
      creadoPorNombre: json['creado_por_nombre'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'importe': importe,
      'fecha': fecha.toIso8601String(),
      'concepto': concepto,
      'cantidad': cantidad,
      'metodo_pago': metodoPago.toString().split('.').last,
      'comentarios': comentarios,
      'foto_url': fotoUrl,
      'categoria_gasto': categoriaGasto,
      'creado_por_id': creadoPorId,
      'creado_por_nombre': creadoPorNombre,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get tieneFoto => fotoUrl != null && fotoUrl!.isNotEmpty;

  Gasto copyWith({
    String? id,
    double? importe,
    DateTime? fecha,
    String? concepto,
    int? cantidad,
    MetodoPago? metodoPago,
    String? comentarios,
    String? fotoUrl,
    String? categoriaGasto,
    String? creadoPorId,
    String? creadoPorNombre,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Gasto(
      id: id ?? this.id,
      importe: importe ?? this.importe,
      fecha: fecha ?? this.fecha,
      concepto: concepto ?? this.concepto,
      cantidad: cantidad ?? this.cantidad,
      metodoPago: metodoPago ?? this.metodoPago,
      comentarios: comentarios ?? this.comentarios,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      categoriaGasto: categoriaGasto ?? this.categoriaGasto,
      creadoPorId: creadoPorId ?? this.creadoPorId,
      creadoPorNombre: creadoPorNombre ?? this.creadoPorNombre,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum MetodoPago {
  efectivo,
  tarjeta,
  transferencia,
  bizum,
  otro;

  static MetodoPago fromString(String metodo) {
    switch (metodo.toLowerCase()) {
      case 'efectivo':
        return MetodoPago.efectivo;
      case 'tarjeta':
        return MetodoPago.tarjeta;
      case 'transferencia':
        return MetodoPago.transferencia;
      case 'bizum':
        return MetodoPago.bizum;
      default:
        return MetodoPago.otro;
    }
  }

  String get displayName {
    switch (this) {
      case MetodoPago.efectivo:
        return 'Efectivo';
      case MetodoPago.tarjeta:
        return 'Tarjeta';
      case MetodoPago.transferencia:
        return 'Transferencia';
      case MetodoPago.bizum:
        return 'Bizum';
      case MetodoPago.otro:
        return 'Otro';
    }
  }
}

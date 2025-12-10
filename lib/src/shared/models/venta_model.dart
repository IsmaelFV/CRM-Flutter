class Venta {
  final String id;
  final double importe;
  final DateTime fecha;
  final String productoId;
  final String? productoNombre;
  final int cantidad;
  final MetodoPago metodoPago;
  final String? comentarios;
  final String creadoPorId;
  final String? creadoPorNombre;
  final DateTime createdAt;

  Venta({
    required this.id,
    required this.importe,
    required this.fecha,
    required this.productoId,
    this.productoNombre,
    required this.cantidad,
    required this.metodoPago,
    this.comentarios,
    required this.creadoPorId,
    this.creadoPorNombre,
    required this.createdAt,
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      id: json['id'] as String,
      importe: (json['importe'] as num).toDouble(),
      fecha: DateTime.parse(json['fecha'] as String),
      productoId: json['producto_id'] as String,
      productoNombre: json['producto_nombre'] as String?,
      cantidad: json['cantidad'] as int,
      metodoPago: MetodoPago.fromString(json['metodo_pago'] as String),
      comentarios: json['comentarios'] as String?,
      creadoPorId: json['creado_por_id'] as String,
      creadoPorNombre: json['creado_por_nombre'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'importe': importe,
      'fecha': fecha.toIso8601String(),
      'producto_id': productoId,
      'producto_nombre': productoNombre,
      'cantidad': cantidad,
      'metodo_pago': metodoPago.toString().split('.').last,
      'comentarios': comentarios,
      'creado_por_id': creadoPorId,
      'creado_por_nombre': creadoPorNombre,
      'created_at': createdAt.toIso8601String(),
    };
  }

  double get precioUnitario => cantidad > 0 ? importe / cantidad : 0;

  Venta copyWith({
    String? id,
    double? importe,
    DateTime? fecha,
    String? productoId,
    String? productoNombre,
    int? cantidad,
    MetodoPago? metodoPago,
    String? comentarios,
    String? creadoPorId,
    String? creadoPorNombre,
    DateTime? createdAt,
  }) {
    return Venta(
      id: id ?? this.id,
      importe: importe ?? this.importe,
      fecha: fecha ?? this.fecha,
      productoId: productoId ?? this.productoId,
      productoNombre: productoNombre ?? this.productoNombre,
      cantidad: cantidad ?? this.cantidad,
      metodoPago: metodoPago ?? this.metodoPago,
      comentarios: comentarios ?? this.comentarios,
      creadoPorId: creadoPorId ?? this.creadoPorId,
      creadoPorNombre: creadoPorNombre ?? this.creadoPorNombre,
      createdAt: createdAt ?? this.createdAt,
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

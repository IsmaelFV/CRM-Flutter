class Producto {
  final String id;
  final String nombre;
  final double precio;
  final int stock;
  final String? codigoBarras;
  final String? categoriaId;
  final String? categoria;
  final String? descripcion;
  final String? imagenUrl;
  final int stockMinimo;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String creadoPorId;
  final bool activo;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.stock,
    this.codigoBarras,
    this.categoriaId,
    this.categoria,
    this.descripcion,
    this.imagenUrl,
    this.stockMinimo = 5,
    required this.createdAt,
    this.updatedAt,
    required this.creadoPorId,
    this.activo = true,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      precio: (json['precio'] as num).toDouble(),
      stock: json['stock'] as int,
      codigoBarras: json['codigo_barras'] as String?,
      categoriaId: json['categoria_id'] as String?,
      categoria: json['categoria'] as String?,
      descripcion: json['descripcion'] as String?,
      imagenUrl: json['imagen_url'] as String?,
      stockMinimo: json['stock_minimo'] as int? ?? 5,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      creadoPorId: json['creado_por_id'] as String,
      activo: json['activo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'stock': stock,
      'codigo_barras': codigoBarras,
      'categoria_id': categoriaId,
      'categoria': categoria,
      'descripcion': descripcion,
      'imagen_url': imagenUrl,
      'stock_minimo': stockMinimo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'creado_por_id': creadoPorId,
      'activo': activo,
    };
  }

  bool get stockBajo => stock <= stockMinimo;
  bool get sinStock => stock <= 0;

  Producto copyWith({
    String? id,
    String? nombre,
    double? precio,
    int? stock,
    String? codigoBarras,
    String? categoriaId,
    String? categoria,
    String? descripcion,
    String? imagenUrl,
    int? stockMinimo,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? creadoPorId,
    bool? activo,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      stock: stock ?? this.stock,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      categoriaId: categoriaId ?? this.categoriaId,
      categoria: categoria ?? this.categoria,
      descripcion: descripcion ?? this.descripcion,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      creadoPorId: creadoPorId ?? this.creadoPorId,
      activo: activo ?? this.activo,
    );
  }
}

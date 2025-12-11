import 'package:uuid/uuid.dart';
import '../shared/models/producto_model.dart';
import 'supabase_service.dart';
import 'tienda_service.dart';

class ProductoService {
  final _uuid = const Uuid();
  final _tiendaService = TiendaService();

  // Obtener todos los productos activos
  Future<List<Producto>> getProductos() async {
    try {
      final response = await SupabaseService.productos
          .select()
          .eq('activo', true)
          .order('nombre');
      
      return (response as List)
          .map((json) => Producto.fromJson(json))
          .toList();
    } catch (e) {
      print('Error obteniendo productos: $e');
      return [];
    }
  }

  // Obtener productos con stock bajo
  Future<List<Producto>> getProductosStockBajo() async {
    try {
      final response = await SupabaseService.productos
          .select()
          .eq('activo', true)
          .order('stock');
      
      final productos = (response as List)
          .map((json) => Producto.fromJson(json))
          .toList();
      
      return productos.where((p) => p.stockBajo).toList();
    } catch (e) {
      print('Error obteniendo productos con stock bajo: $e');
      return [];
    }
  }

  // Obtener producto por ID
  Future<Producto?> getProductoById(String id) async {
    try {
      final response = await SupabaseService.productos
          .select()
          .eq('id', id)
          .single();
      
      return Producto.fromJson(response);
    } catch (e) {
      print('Error obteniendo producto: $e');
      return null;
    }
  }

  // Buscar productos por nombre o código de barras
  Future<List<Producto>> buscarProductos(String query) async {
    try {
      final response = await SupabaseService.productos
          .select()
          .eq('activo', true)
          .or('nombre.ilike.%$query%,codigo_barras.ilike.%$query%')
          .order('nombre');
      
      return (response as List)
          .map((json) => Producto.fromJson(json))
          .toList();
    } catch (e) {
      print('Error buscando productos: $e');
      return [];
    }
  }

  // Crear producto
  Future<Producto?> crearProducto({
    required String nombre,
    required double precio,
    required int stock,
    String? codigoBarras,
    String? categoriaId,
    String? descripcion,
    int stockMinimo = 5,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Usuario no autenticado');

      // Obtener duenoId del usuario actual
      final duenoId = await _tiendaService.getDuenoIdActual(userId);
      if (duenoId == null) throw Exception('No se pudo determinar la tienda');

      final id = _uuid.v4();
      final now = DateTime.now().toIso8601String();

      final data = {
        'id': id,
        'nombre': nombre,
        'precio': precio,
        'stock': stock,
        'codigo_barras': codigoBarras,
        'categoria_id': categoriaId,
        'descripcion': descripcion,
        'stock_minimo': stockMinimo,
        'creado_por_id': userId,
        'dueno_id': duenoId,
        'created_at': now,
        'activo': true,
      };

      final response = await SupabaseService.productos
          .insert(data)
          .select()
          .single();
      
      return Producto.fromJson(response);
    } catch (e) {
      print('Error creando producto: $e');
      return null;
    }
  }

  // Actualizar producto
  Future<bool> actualizarProducto(String id, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();
      
      await SupabaseService.productos
          .update(updates)
          .eq('id', id);
      
      return true;
    } catch (e) {
      print('Error actualizando producto: $e');
      return false;
    }
  }

  // Actualizar stock
  Future<bool> actualizarStock(String productoId, int nuevoStock) async {
    return await actualizarProducto(productoId, {'stock': nuevoStock});
  }

  // Reducir stock (al hacer una venta)
  Future<bool> reducirStock(String productoId, int cantidad) async {
    try {
      final producto = await getProductoById(productoId);
      if (producto == null) return false;

      final nuevoStock = producto.stock - cantidad;
      if (nuevoStock < 0) {
        throw Exception('Stock insuficiente');
      }

      return await actualizarStock(productoId, nuevoStock);
    } catch (e) {
      print('Error reduciendo stock: $e');
      return false;
    }
  }

  // Eliminar producto (soft delete)
  Future<bool> eliminarProducto(String id) async {
    return await actualizarProducto(id, {'activo': false});
  }

  // Stream de productos en tiempo real
  Stream<List<Producto>> productosStream() {
    return SupabaseService.productos
        .stream(primaryKey: ['id'])
        .eq('activo', true)
        .order('nombre')
        .map((data) => data.map((json) => Producto.fromJson(json)).toList());
  }
}

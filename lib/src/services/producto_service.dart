import 'package:uuid/uuid.dart';
import '../shared/models/producto_model.dart';
import 'supabase_service.dart';
import 'tienda_service.dart';

class ProductoService {
  final _uuid = const Uuid();
  final _tiendaService = TiendaService();

  // ==============================================================================
  // OBTENER PRODUCTOS (CON FILTRO MULTI-TIENDA)
  // ==============================================================================
  // Obtiene la lista de productos aplicando el filtro de tienda si es necesario.
  // Parámetro opcional [duenoId]:
  // - Si se proporciona: Filtra los productos de esa tienda específica.
  // - Si es null (y es Superadmin): Devuelve todos los productos de todas las tiendas.
  // - Si es null (y es Dueño/Empleado): RLS forzará a ver solo sus propios productos.
  Future<List<Producto>> getProductos({String? duenoId}) async {
    try {
      // Iniciamos la consulta base
      dynamic query = SupabaseService.productos
          .select()
          .eq('activo', true);

      // Si hay un ID específico, aplicamos el filtro WHERE dueno_id = [duenoId]
      if (duenoId != null) {
        query = query.eq('dueno_id', duenoId);
      }

      final response = await query.order('nombre');
      
      return (response as List)
          .map((json) => Producto.fromJson(json))
          .toList();
    } catch (e) {
      print('Error obteniendo productos: $e');
      return [];
    }
  }

  // ==============================================================================
  // OBTENER PRODUCTOS CON STOCK BAJO (CON FILTRO MULTI-TIENDA)
  // ==============================================================================
  // Obtiene la lista de productos con stock bajo aplicando el filtro de tienda si es necesario.
  // Parámetro opcional [duenoId]:
  // - Si se proporciona: Filtra los productos de esa tienda específica.
  // - Si es null (y es Superadmin): Devuelve todos los productos de todas las tiendas.
  // - Si es null (y es Dueño/Empleado): RLS forzará a ver solo sus propios productos.
  // Obtener productos con stock bajo (opcionalmente filtrados por dueño)
  Future<List<Producto>> getProductosStockBajo({String? duenoId}) async {
    try {
      dynamic query = SupabaseService.productos
          .select()
          .eq('activo', true);

      // Filtro adicional por dueño (para superadmin con tienda seleccionada)
      if (duenoId != null) {
        query = query.eq('dueno_id', duenoId);
      }

      final response = await query.order('stock');
      
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

  // Buscar productos por nombre o código de barras (opcionalmente filtrados por dueño)
  Future<List<Producto>> buscarProductos(String query, {String? duenoId}) async {
    try {
      dynamic q = SupabaseService.productos
          .select()
          .eq('activo', true)
          .or('nombre.ilike.%$query%,codigo_barras.ilike.%$query%');

      if (duenoId != null) {
        q = q.eq('dueno_id', duenoId);
      }

      final response = await q.order('nombre');
      
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

      // Obtener duenoId del usuario actual (null para superadmin)
      final duenoId = await _tiendaService.getDuenoIdActual(userId);

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

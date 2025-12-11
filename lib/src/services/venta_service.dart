import 'package:uuid/uuid.dart';
import '../shared/models/venta_model.dart';
import 'supabase_service.dart';
import 'producto_service.dart';
import 'tienda_service.dart';

class VentaService {
  final _uuid = const Uuid();
  final _productoService = ProductoService();
  final _tiendaService = TiendaService();

  // Obtener todas las ventas (opcionalmente filtradas por dueño)
  Future<List<Venta>> getVentas({DateTime? desde, DateTime? hasta, String? duenoId}) async {
    try {
      dynamic query = SupabaseService.ventas
          .select('''
            *,
            productos!inner(nombre)
          ''');

      if (desde != null) {
        query = query.gte('fecha', desde.toIso8601String());
      }
      if (hasta != null) {
        query = query.lte('fecha', hasta.toIso8601String());
      }

      // Filtro adicional por dueño (para superadmin con tienda seleccionada)
      if (duenoId != null) {
        query = query.eq('dueno_id', duenoId);
      }

      query = query.order('fecha', ascending: false);

      final response = await query;
      
      return (response as List).map((json) {
        final venta = Map<String, dynamic>.from(json);
        if (json['productos'] != null) {
          venta['producto_nombre'] = json['productos']['nombre'];
        }
        return Venta.fromJson(venta);
      }).toList();
    } catch (e) {
      print('Error obteniendo ventas: $e');
      return [];
    }
  }

  // Obtener ventas del día
  Future<List<Venta>> getVentasHoy({String? duenoId}) async {
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day);
    final fin = inicio.add(const Duration(days: 1));
    
    return await getVentas(desde: inicio, hasta: fin, duenoId: duenoId);
  }

  // Obtener ventas del mes
  Future<List<Venta>> getVentasMes({String? duenoId}) async {
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, 1);
    
    return await getVentas(desde: inicio, duenoId: duenoId);
  }

  // Crear venta
  Future<Venta?> crearVenta({
    required double importe,
    required String productoId,
    required int cantidad,
    required MetodoPago metodoPago,
    String? comentarios,
    DateTime? fecha,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Usuario no autenticado');

      // Obtener duenoId del usuario actual (null para superadmin)
      final duenoId = await _tiendaService.getDuenoIdActual(userId);

      // Reducir stock del producto
      final stockActualizado = await _productoService.reducirStock(
        productoId,
        cantidad,
      );

      if (!stockActualizado) {
        throw Exception('No se pudo actualizar el stock');
      }

      final id = _uuid.v4();
      final now = DateTime.now();

      final data = {
        'id': id,
        'importe': importe,
        'fecha': (fecha ?? now).toIso8601String(),
        'producto_id': productoId,
        'cantidad': cantidad,
        'metodo_pago': metodoPago.toString().split('.').last,
        'comentarios': comentarios,
        'creado_por_id': userId,
        'dueno_id': duenoId,
        'created_at': now.toIso8601String(),
      };

      final response = await SupabaseService.ventas
          .insert(data)
          .select('''
            *,
            productos!inner(nombre)
          ''')
          .single();

      final venta = Map<String, dynamic>.from(response);
      if (response['productos'] != null) {
        venta['producto_nombre'] = response['productos']['nombre'];
      }
      
      return Venta.fromJson(venta);
    } catch (e) {
      print('Error creando venta: $e');
      return null;
    }
  }

  // Obtener total de ventas
  Future<double> getTotalVentas({DateTime? desde, DateTime? hasta, String? duenoId}) async {
    final ventas = await getVentas(desde: desde, hasta: hasta, duenoId: duenoId);
    return ventas.fold<double>(0.0, (sum, venta) => sum + venta.importe);
  }

  // Obtener total de ventas del día
  Future<double> getTotalVentasHoy({String? duenoId}) async {
    final ventas = await getVentasHoy(duenoId: duenoId);
    return ventas.fold<double>(0.0, (sum, venta) => sum + venta.importe);
  }

  // Obtener total de ventas del mes
  Future<double> getTotalVentasMes({String? duenoId}) async {
    final ventas = await getVentasMes(duenoId: duenoId);
    return ventas.fold<double>(0.0, (sum, venta) => sum + venta.importe);
  }

  // Stream de ventas en tiempo real
  Stream<List<Venta>> ventasStream() {
    return SupabaseService.ventas
        .stream(primaryKey: ['id'])
        .order('fecha', ascending: false)
        .map((data) => data.map((json) => Venta.fromJson(json)).toList());
  }

  // Estadísticas de ventas por producto
  Future<Map<String, dynamic>> getEstadisticasPorProducto({
    DateTime? desde,
    DateTime? hasta,
  }) async {
    final ventas = await getVentas(desde: desde, hasta: hasta);
    
    final Map<String, Map<String, dynamic>> stats = {};
    
    for (final venta in ventas) {
      final productoId = venta.productoId;
      if (!stats.containsKey(productoId)) {
        stats[productoId] = {
          'producto_nombre': venta.productoNombre ?? 'Desconocido',
          'cantidad_total': 0,
          'importe_total': 0.0,
          'num_ventas': 0,
        };
      }
      
      stats[productoId]!['cantidad_total'] += venta.cantidad;
      stats[productoId]!['importe_total'] += venta.importe;
      stats[productoId]!['num_ventas'] += 1;
    }
    
    return stats;
  }
}

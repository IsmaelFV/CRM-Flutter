import 'dart:io';
import 'package:uuid/uuid.dart';
import '../shared/models/gasto_model.dart';
import 'supabase_service.dart';
import 'tienda_service.dart';

class GastoService {
  final _uuid = const Uuid();
  final _tiendaService = TiendaService();

  // Obtener todos los gastos (opcionalmente filtrados por dueño)
  Future<List<Gasto>> getGastos({DateTime? desde, DateTime? hasta, String? duenoId}) async {
    try {
      dynamic query = SupabaseService.gastos.select();

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
      
      return (response as List)
          .map((json) => Gasto.fromJson(json))
          .toList();
    } catch (e) {
      print('Error obteniendo gastos: $e');
      return [];
    }
  }

  // Obtener gastos del día
  Future<List<Gasto>> getGastosHoy({String? duenoId}) async {
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day);
    final fin = inicio.add(const Duration(days: 1));
    
    return await getGastos(desde: inicio, hasta: fin, duenoId: duenoId);
  }

  // Obtener gastos del mes
  Future<List<Gasto>> getGastosMes({String? duenoId}) async {
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, 1);
    
    return await getGastos(desde: inicio, duenoId: duenoId);
  }

  // Crear gasto
  Future<Gasto?> crearGasto({
    required double importe,
    required String concepto,
    required MetodoPago metodoPago,
    int? cantidad,
    String? comentarios,
    String? categoriaGasto,
    File? foto,
    DateTime? fecha,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) throw Exception('Usuario no autenticado');

      // Obtener duenoId del usuario actual (null para superadmin)
      final duenoId = await _tiendaService.getDuenoIdActual(userId);

      String? fotoUrl;
      
      // Subir foto si existe
      if (foto != null) {
        fotoUrl = await _subirFoto(foto);
      }

      final id = _uuid.v4();
      final now = DateTime.now();

      final data = {
        'id': id,
        'importe': importe,
        'fecha': (fecha ?? now).toIso8601String(),
        'concepto': concepto,
        'cantidad': cantidad,
        'metodo_pago': metodoPago.toString().split('.').last,
        'comentarios': comentarios,
        'foto_url': fotoUrl,
        'categoria_gasto': categoriaGasto,
        'creado_por_id': userId,
        'dueno_id': duenoId,
        'created_at': now.toIso8601String(),
      };

      final response = await SupabaseService.gastos
          .insert(data)
          .select()
          .single();
      
      return Gasto.fromJson(response);
    } catch (e) {
      print('Error creando gasto: $e');
      return null;
    }
  }

  // Subir foto al storage
  Future<String?> _subirFoto(File foto) async {
    try {
      final fileName = '${_uuid.v4()}_${foto.path.split('/').last}';
      final path = 'gastos/$fileName';

      await SupabaseService.storage
          .from('imagenes')
          .upload(path, foto);

      return SupabaseService.getBucketUrl('imagenes', path);
    } catch (e) {
      print('Error subiendo foto: $e');
      return null;
    }
  }

  // Actualizar gasto
  Future<bool> actualizarGasto(String id, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();
      
      await SupabaseService.gastos
          .update(updates)
          .eq('id', id);
      
      return true;
    } catch (e) {
      print('Error actualizando gasto: $e');
      return false;
    }
  }

  // Eliminar gasto
  Future<bool> eliminarGasto(String id) async {
    try {
      await SupabaseService.gastos.delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error eliminando gasto: $e');
      return false;
    }
  }

  // Obtener total de gastos
  Future<double> getTotalGastos({DateTime? desde, DateTime? hasta, String? duenoId}) async {
    final gastos = await getGastos(desde: desde, hasta: hasta, duenoId: duenoId);
    return gastos.fold<double>(0.0, (sum, gasto) => sum + gasto.importe);
  }

  // Obtener total de gastos de hoy
  Future<double> getTotalGastosHoy({String? duenoId}) async {
    final gastos = await getGastosHoy(duenoId: duenoId);
    return gastos.fold<double>(0.0, (sum, gasto) => sum + gasto.importe);
  }

  // Obtener total de gastos del mes
  Future<double> getTotalGastosMes({String? duenoId}) async {
    final gastos = await getGastosMes(duenoId: duenoId);
    return gastos.fold<double>(0.0, (sum, gasto) => sum + gasto.importe);
  }

  // Stream de gastos en tiempo real
  Stream<List<Gasto>> gastosStream() {
    return SupabaseService.gastos
        .stream(primaryKey: ['id'])
        .order('fecha', ascending: false)
        .map((data) => data.map((json) => Gasto.fromJson(json)).toList());
  }

  // Estadísticas de gastos por categoría
  Future<Map<String, double>> getGastosPorCategoria({
    DateTime? desde,
    DateTime? hasta,
  }) async {
    final gastos = await getGastos(desde: desde, hasta: hasta);
    
    final Map<String, double> stats = {};
    
    for (final gasto in gastos) {
      final categoria = gasto.categoriaGasto ?? 'Sin categoría';
      stats[categoria] = (stats[categoria] ?? 0.0) + gasto.importe;
    }
    
    return stats;
  }
}

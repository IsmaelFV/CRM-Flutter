import '../shared/models/tienda_model.dart';
import 'supabase_service.dart';

class TiendaService {
  // Obtener tienda del usuario actual (dueño o empleado)
  Future<Tienda?> getTiendaActual(String userId) async {
    try {
      // Primero verificar si el usuario es dueño
      final responseDueno = await SupabaseService.client
          .from('tiendas')
          .select()
          .eq('dueno_id', userId)
          .maybeSingle();

      if (responseDueno != null) {
        return Tienda.fromJson(responseDueno);
      }

      // Si no es dueño, buscar la tienda de su dueño
      final responseUsuario = await SupabaseService.client
          .from('usuarios')
          .select('dueno_id')
          .eq('id', userId)
          .single();

      final duenoId = responseUsuario['dueno_id'];
      if (duenoId == null) return null;

      final responseTienda = await SupabaseService.client
          .from('tiendas')
          .select()
          .eq('dueno_id', duenoId)
          .single();

      return Tienda.fromJson(responseTienda);
    } catch (e) {
      print('Error obteniendo tienda actual: $e');
      return null;
    }
  }

  // Obtener todas las tiendas (solo para superadmin)
  Future<List<Tienda>> getAllTiendas() async {
    try {
      final response = await SupabaseService.client
          .from('tiendas')
          .select()
          .order('nombre');

      return (response as List)
          .map((tienda) => Tienda.fromJson(tienda))
          .toList();
    } catch (e) {
      print('Error obteniendo todas las tiendas: $e');
      return [];
    }
  }

  // Crear tienda (solo para superadmin o al crear un dueño)
  Future<Tienda?> crearTienda({
    required String nombre,
    required String duenoId,
    String? direccion,
    String? telefono,
    String? email,
  }) async {
    try {
      final response = await SupabaseService.client
          .from('tiendas')
          .insert({
            'nombre': nombre,
            'dueno_id': duenoId,
            'direccion': direccion,
            'telefono': telefono,
            'email': email,
            'activa': true,
          })
          .select()
          .single();

      return Tienda.fromJson(response);
    } catch (e) {
      print('Error creando tienda: $e');
      return null;
    }
  }

  // Actualizar tienda
  Future<bool> actualizarTienda(Tienda tienda) async {
    try {
      await SupabaseService.client
          .from('tiendas')
          .update(tienda.toJson())
          .eq('id', tienda.id);
      return true;
    } catch (e) {
      print('Error actualizando tienda: $e');
      return false;
    }
  }

  // Activar/Desactivar tienda
  Future<bool> toggleTiendaActiva(String tiendaId, bool activa) async {
    try {
      await SupabaseService.client
          .from('tiendas')
          .update({'activa': activa})
          .eq('id', tiendaId);
      return true;
    } catch (e) {
      print('Error cambiando estado de tienda: $e');
      return false;
    }
  }

  // Obtener ID del dueño de la tienda del usuario actual
  Future<String?> getDuenoIdActual(String userId) async {
    try {
      final usuario = await SupabaseService.client
          .from('usuarios')
          .select('rol, dueno_id')
          .eq('id', userId)
          .single();

      final rol = usuario['rol'] as String;
      
      // Si es dueño, retornar su propio ID
      if (rol == 'dueno') {
        return userId;
      }
      
      // Si es empleado, retornar el ID de su dueño
      if (rol == 'empleado') {
        return usuario['dueno_id'] as String?;
      }
      
      // Superadmin retorna null (puede ver todo)
      return null;
    } catch (e) {
      print('Error obteniendo duenoId actual: $e');
      return null;
    }
  }
}

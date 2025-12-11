import 'package:supabase_flutter/supabase_flutter.dart';
import '../shared/models/usuario_model.dart';
import 'supabase_service.dart';

class UserService {
  // Obtener todos los usuarios
  Future<List<Usuario>> getAllUsers() async {
    try {
      final response = await SupabaseService.usuarios
          .select()
          .order('nombre', ascending: true);

      return (response as List).map((json) => Usuario.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo usuarios: $e');
      return [];
    }
  }

  // Actualizar rol de usuario
  Future<bool> updateUserRole(String userId, RolUsuario nuevoRol) async {
    try {
      await SupabaseService.usuarios.update({
        'rol': nuevoRol.toString().split('.').last,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      return true;
    } catch (e) {
      print('Error actualizando rol: $e');
      return false;
    }
  }

  // Activar/Desactivar usuario
  Future<bool> toggleUserStatus(String userId, bool nuevoEstado) async {
    try {
      await SupabaseService.usuarios.update({
        'activo': nuevoEstado,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      return true;
    } catch (e) {
      print('Error cambiando estado de usuario: $e');
      return false;
    }
  }

  // Eliminar usuario completamente (de auth.users y public.usuarios)
  Future<bool> deleteUser(String userId) async {
    try {
      // Llamar a la función SQL que elimina el usuario completamente
      await SupabaseService.client.rpc('delete_user_completely', params: {
        'user_id': userId,
      });
      
      return true;
    } catch (e) {
      print('Error eliminando usuario: $e');
      return false;
    }
  }
}

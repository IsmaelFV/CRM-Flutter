import 'package:supabase_flutter/supabase_flutter.dart';
import '../shared/models/usuario_model.dart';
import 'supabase_service.dart';
import 'tienda_service.dart';

class AuthService {
  final _client = SupabaseService.client;
  final _tiendaService = TiendaService();

  // Registro con email y contraseña
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    String? telefono,
    RolUsuario rol = RolUsuario.empleado,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'nombre': nombre,
        'apellido': apellido,
        'telefono': telefono,
      },
    );

    if (response.user != null) {
      // Obtener duenoId si es empleado
      String? duenoId;
      if (rol == RolUsuario.empleado) {
        final currentUserId = _client.auth.currentUser?.id;
        if (currentUserId != null) {
          duenoId = await _tiendaService.getDuenoIdActual(currentUserId);
        }
      }
      
      // Crear registro en tabla usuarios
      await SupabaseService.usuarios.insert({
        'id': response.user!.id,
        'email': email,
        'nombre': nombre,
        'apellido': apellido,
        'telefono': telefono,
        'rol': rol.toString().split('.').last,
        'dueno_id': duenoId,
        'activo': true,
      });
      
      // Si es dueño, crear su tienda
      if (rol == RolUsuario.dueno) {
        await _tiendaService.crearTienda(
          nombre: 'Tienda de $nombre $apellido',
          duenoId: response.user!.id,
        );
      }
    }

    return response;
  }

  // Login con email y contraseña
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Login con teléfono (OTP)
  Future<void> signInWithPhone(String phone) async {
    await _client.auth.signInWithOtp(
      phone: phone,
    );
  }

  // Verificar OTP de teléfono
  Future<AuthResponse> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    return await _client.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  // Login con Google
  Future<bool> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.marketmove://login-callback/',
      );
      return true;
    } catch (e) {
      print('Error en Google Sign-In: $e');
      return false;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Obtener usuario actual
  Future<Usuario?> getCurrentUser() async {
    final user = SupabaseService.currentUser;
    if (user == null) return null;

    try {
      final response = await SupabaseService.usuarios
          .select()
          .eq('id', user.id)
          .single();
      
      return Usuario.fromJson(response);
    } catch (e) {
      print('Error obteniendo usuario: $e');
      return null;
    }
  }

  // Resetear contraseña
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // Actualizar contraseña
  Future<UserResponse> updatePassword(String newPassword) async {
    return await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // Actualizar perfil
  Future<void> updateProfile({
    String? nombre,
    String? apellido,
    String? telefono,
  }) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    await SupabaseService.usuarios.update({
      if (nombre != null) 'nombre': nombre,
      if (apellido != null) 'apellido': apellido,
      if (telefono != null) 'telefono': telefono,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  // Stream de cambios de autenticación
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  
  // Auth
  static User? get currentUser => client.auth.currentUser;
  static String? get currentUserId => currentUser?.id;
  static bool get isAuthenticated => currentUser != null;
  
  // Stream de cambios de autenticación
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
  
  // Tablas
  static SupabaseQueryBuilder get usuarios => client.from('usuarios');
  static SupabaseQueryBuilder get productos => client.from('productos');
  static SupabaseQueryBuilder get ventas => client.from('ventas');
  static SupabaseQueryBuilder get gastos => client.from('gastos');
  static SupabaseQueryBuilder get categorias => client.from('categorias');
  
  // Storage
  static SupabaseStorageClient get storage => client.storage;
  static String getBucketUrl(String bucket, String path) {
    return storage.from(bucket).getPublicUrl(path);
  }
}

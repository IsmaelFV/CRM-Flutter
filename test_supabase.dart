import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Tus credenciales
  const supabaseUrl = 'https://rxyvtnngpwfwxiratrzr.supabase.co';
  const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ4eXZ0bm5ncHdmd3hpcmF0cnpyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUzODYyMDUsImV4cCI6MjA4MDk2MjIwNX0.1F2ceCmgwJ37hg0B9mucMCPHDIdTYDgkqm_r4xeGBZM';

  print('🔍 Probando conexión a Supabase...');
  print('URL: $supabaseUrl');
  
  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    
    print('✅ Inicialización exitosa');
    
    // Probar consulta simple
    final response = await Supabase.instance.client
        .from('usuarios')
        .select('count')
        .count();
    
    print('✅ Conexión a base de datos exitosa');
    print('📊 Tabla usuarios existe');
    
  } catch (e) {
    print('❌ Error: $e');
    print('');
    print('Posibles causas:');
    print('1. Las tablas no existen (ejecuta schema.sql)');
    print('2. Problema de CORS (configura Site URL en Supabase)');
    print('3. Credenciales incorrectas');
  }
}

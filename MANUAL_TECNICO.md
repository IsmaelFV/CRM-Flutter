# Manual Técnico - MarketMove App

## 🏗️ Arquitectura del Proyecto

### Tecnologías Utilizadas

- **Frontend**: Flutter 3.x
- **Backend**: Supabase (PostgreSQL + Auth + Storage + Realtime)
- **Gestión de Estado**: Provider
- **Autenticación**: Supabase Auth (Email, Phone, Google OAuth)
- **Base de Datos**: PostgreSQL con Row Level Security (RLS)
- **Storage**: Supabase Storage para imágenes

### Estructura del Proyecto

```
lib/
├── main.dart                          # Punto de entrada
├── src/
│   ├── config/
│   │   ├── app_theme.dart            # Tema de la aplicación
│   │   └── supabase_config.dart      # Configuración de Supabase
│   ├── features/
│   │   ├── auth/                     # Autenticación
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── dashboard/                # Dashboard principal
│   │   │   └── dashboard_screen.dart
│   │   ├── ventas/                   # Módulo de ventas
│   │   │   ├── ventas_screen.dart
│   │   │   └── crear_venta_screen.dart
│   │   ├── gastos/                   # Módulo de gastos
│   │   │   ├── gastos_screen.dart
│   │   │   └── crear_gasto_screen.dart
│   │   ├── productos/                # Módulo de productos
│   │   │   ├── productos_screen.dart
│   │   │   └── crear_producto_screen.dart
│   │   └── admin/                    # Panel de administración
│   │       └── admin_screen.dart
│   ├── services/
│   │   ├── supabase_service.dart     # Cliente de Supabase
│   │   ├── auth_service.dart         # Servicio de autenticación
│   │   ├── producto_service.dart     # CRUD de productos
│   │   ├── venta_service.dart        # CRUD de ventas
│   │   ├── gasto_service.dart        # CRUD de gastos
│   │   └── export_service.dart       # Exportación a Excel
│   └── shared/
│       ├── models/                   # Modelos de datos
│       │   ├── usuario_model.dart
│       │   ├── producto_model.dart
│       │   ├── venta_model.dart
│       │   └── gasto_model.dart
│       ├── providers/                # Gestión de estado
│       │   ├── auth_provider.dart
│       │   └── dashboard_provider.dart
│       └── widgets/                  # Widgets reutilizables
```

## 🗄️ Base de Datos

### Esquema de Tablas

#### usuarios
```sql
- id: UUID (PK, FK a auth.users)
- email: TEXT
- telefono: TEXT
- nombre: TEXT
- apellido: TEXT
- rol: TEXT (superadmin, dueno, empleado)
- activo: BOOLEAN
- created_at: TIMESTAMP
- updated_at: TIMESTAMP
```

#### productos
```sql
- id: UUID (PK)
- nombre: TEXT
- precio: DECIMAL(10,2)
- stock: INTEGER
- codigo_barras: TEXT
- categoria_id: UUID (FK)
- categoria: TEXT
- descripcion: TEXT
- imagen_url: TEXT
- stock_minimo: INTEGER
- creado_por_id: UUID (FK)
- activo: BOOLEAN
- created_at: TIMESTAMP
- updated_at: TIMESTAMP
```

#### ventas
```sql
- id: UUID (PK)
- importe: DECIMAL(10,2)
- fecha: TIMESTAMP
- producto_id: UUID (FK)
- producto_nombre: TEXT
- cantidad: INTEGER
- metodo_pago: TEXT
- comentarios: TEXT
- creado_por_id: UUID (FK)
- creado_por_nombre: TEXT
- created_at: TIMESTAMP
```

#### gastos
```sql
- id: UUID (PK)
- importe: DECIMAL(10,2)
- fecha: TIMESTAMP
- concepto: TEXT
- cantidad: INTEGER
- metodo_pago: TEXT
- comentarios: TEXT
- foto_url: TEXT
- categoria_gasto: TEXT
- creado_por_id: UUID (FK)
- creado_por_nombre: TEXT
- created_at: TIMESTAMP
- updated_at: TIMESTAMP
```

### Row Level Security (RLS)

Todas las tablas tienen RLS habilitado con políticas específicas por rol:

- **Superadmin**: Acceso total
- **Dueño**: Lectura total, escritura en productos
- **Empleado**: Lectura total, escritura en ventas y gastos

## 🔐 Autenticación

### Flujo de Autenticación

1. Usuario ingresa credenciales
2. Supabase Auth valida
3. Se obtiene el token JWT
4. Se consulta la tabla `usuarios` para obtener el rol
5. AuthProvider actualiza el estado
6. La app redirige al Dashboard

### Métodos Soportados

- **Email + Contraseña**: Registro y login estándar
- **Google OAuth**: Sign-in con cuenta de Google
- **Teléfono + OTP**: (Configuración adicional requerida)

## 📡 Servicios

### SupabaseService

Cliente centralizado para acceder a Supabase:

```dart
SupabaseService.client        // Cliente de Supabase
SupabaseService.currentUser   // Usuario actual
SupabaseService.usuarios      // Tabla usuarios
SupabaseService.productos     // Tabla productos
SupabaseService.ventas        // Tabla ventas
SupabaseService.gastos        // Tabla gastos
```

### AuthService

Gestión de autenticación:

```dart
signUpWithEmail()      // Registro con email
signInWithEmail()      // Login con email
signInWithGoogle()     // Login con Google
signOut()              // Cerrar sesión
getCurrentUser()       // Obtener usuario actual
updateProfile()        // Actualizar perfil
```

### ProductoService

CRUD de productos:

```dart
getProductos()              // Obtener todos
getProductosStockBajo()     // Productos con stock bajo
crearProducto()             // Crear nuevo
actualizarProducto()        // Actualizar
actualizarStock()           // Actualizar stock
reducirStock()              // Reducir stock (venta)
eliminarProducto()          // Soft delete
```

### VentaService

Gestión de ventas:

```dart
getVentas()                 // Obtener todas
getVentasHoy()              // Ventas del día
getVentasMes()              // Ventas del mes
crearVenta()                // Registrar venta
getTotalVentas()            // Total de ventas
getEstadisticasPorProducto() // Estadísticas
```

### GastoService

Gestión de gastos:

```dart
getGastos()                 // Obtener todos
getGastosHoy()              // Gastos del día
getGastosMes()              // Gastos del mes
crearGasto()                // Registrar gasto
getTotalGastos()            // Total de gastos
getGastosPorCategoria()     // Estadísticas
```

### ExportService

Exportación de datos a Excel:

```dart
exportarVentas()            // Exportar ventas
exportarGastos()            // Exportar gastos
exportarProductos()         // Exportar productos
exportarInformeCompleto()   // Informe completo
```

## 🎨 Gestión de Estado

### Providers

#### AuthProvider

Gestiona el estado de autenticación:

```dart
currentUser              // Usuario actual
isAuthenticated         // ¿Está autenticado?
isSuperadmin           // ¿Es superadmin?
isDueno                // ¿Es dueño?
isEmpleado             // ¿Es empleado?
signInWithEmail()      // Login
signOut()              // Logout
```

#### DashboardProvider

Gestiona datos del dashboard:

```dart
ventasHoy              // Total ventas del día
gastosHoy              // Total gastos del día
gananciasHoy           // Ganancias del día
ventasMes              // Total ventas del mes
gastosMes              // Total gastos del mes
gananciasMes           // Ganancias del mes
productosStockBajo     // Productos con stock bajo
cargarDatos()          // Recargar datos
```

## 🚀 Instalación y Configuración

### 1. Clonar el Repositorio

```bash
git clone <url-repositorio>
cd CRM-Flutter
```

### 2. Instalar Dependencias

```bash
flutter pub get
```

### 3. Configurar Supabase

1. Crea un proyecto en [Supabase](https://supabase.com)
2. Copia `lib/src/config/supabase_config.example.dart` a `supabase_config.dart`
3. Añade tus credenciales:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://tu-proyecto.supabase.co';
  static const String supabaseAnonKey = 'tu-anon-key';
}
```

### 4. Ejecutar Scripts SQL

En el SQL Editor de Supabase, ejecuta en orden:

1. `supabase/schema.sql` - Crea las tablas
2. `supabase/rls_policies.sql` - Configura RLS

### 5. Configurar Storage

1. Ve a Storage en Supabase
2. Crea un bucket llamado `imagenes`
3. Hazlo público

### 6. Ejecutar la App

```bash
flutter run
```

## 🔧 Configuración Adicional

### Google Sign-In

1. Configura OAuth en Google Cloud Console
2. Añade las credenciales en Supabase Auth
3. Configura los SHA-1/SHA-256 para Android

### Permisos Android

En `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### Permisos iOS

En `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Necesitamos acceso a la cámara para adjuntar fotos a los gastos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Necesitamos acceso a la galería para seleccionar fotos</string>
```

## 📊 Monitoreo y Logs

### Logs de Supabase

- Ve a Logs en el dashboard de Supabase
- Filtra por tipo: API, Auth, Storage

### Logs de Flutter

```dart
print('Mensaje de log');
debugPrint('Mensaje de debug');
```

## 🧪 Testing

### Pruebas Unitarias

```bash
flutter test
```

### Pruebas de Integración

```bash
flutter test integration_test/
```

## 🚢 Deployment

### Android

```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## 🔒 Seguridad

### Buenas Prácticas Implementadas

- ✅ Row Level Security (RLS) en todas las tablas
- ✅ Validación de roles en el backend
- ✅ Tokens JWT para autenticación
- ✅ HTTPS para todas las comunicaciones
- ✅ Sanitización de inputs
- ✅ Soft delete para productos

### Recomendaciones

- Cambia las credenciales de Supabase regularmente
- No compartas el archivo `supabase_config.dart`
- Revisa los logs de acceso periódicamente
- Mantén actualizado Flutter y las dependencias

## 📝 Mantenimiento

### Actualizar Dependencias

```bash
flutter pub upgrade
```

### Limpiar Caché

```bash
flutter clean
flutter pub get
```

### Backup de Base de Datos

Usa las herramientas de backup de Supabase o exporta regularmente con la app.

---

**Desarrollado para MarketMove S.L.**

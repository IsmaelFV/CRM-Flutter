# MarketMove App 🚀

Aplicación móvil profesional para la gestión de pequeños comercios desarrollada con Flutter y Supabase.

## 📋 Características principales

- ✅ **Autenticación multi-método**: Email, teléfono y Google Sign-In
- 👥 **Sistema de roles**: Superadmin, Dueños y Empleados
- 💰 **Gestión de ventas**: Registro completo con productos, métodos de pago
- 📊 **Control de gastos**: Con adjuntos de fotos y categorización
- 📦 **Inventario de productos**: Control de stock en tiempo real
- 📈 **Dashboard en tiempo real**: Estadísticas, gráficos y alertas
- 📤 **Exportación a Excel**: Informes detallados
- 📧 **Envío de reportes por email**
- 🔒 **Seguridad avanzada**: Row Level Security (RLS) en Supabase

## 🏗️ Arquitectura del proyecto

```
lib/
├── src/
│   ├── features/
│   │   ├── auth/           # Autenticación y registro
│   │   ├── ventas/         # Módulo de ventas
│   │   ├── gastos/         # Módulo de gastos
│   │   ├── productos/      # Módulo de productos
│   │   ├── dashboard/      # Pantalla principal
│   │   └── admin/          # Panel de administración
│   ├── shared/
│   │   ├── models/         # Modelos de datos
│   │   ├── services/       # Servicios (Supabase, etc.)
│   │   ├── providers/      # Gestión de estado
│   │   ├── widgets/        # Widgets reutilizables
│   │   └── utils/          # Utilidades y helpers
│   └── config/             # Configuración de la app
└── main.dart
```

## 🚀 Configuración inicial

### 1. Instalar dependencias

```bash
flutter pub get
```

### 2. Configurar Supabase

1. Crea un proyecto en [Supabase](https://supabase.com)
2. Copia la URL y la API Key
3. Crea el archivo `lib/src/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'TU_SUPABASE_URL';
  static const String supabaseAnonKey = 'TU_SUPABASE_ANON_KEY';
}
```

### 3. Ejecutar scripts SQL en Supabase

Ejecuta los scripts SQL proporcionados en `supabase/` para crear las tablas y configurar RLS.

### 4. Configurar autenticación de Google (opcional)

Sigue la [documentación oficial](https://supabase.com/docs/guides/auth/social-login/auth-google) para configurar Google Sign-In.

## 📱 Ejecutar la aplicación

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web (desarrollo)
flutter run -d chrome
```

## 👤 Usuarios de prueba

Después de la configuración inicial, crea un superadmin desde Supabase:

1. Ve a Authentication > Users
2. Crea un usuario
3. En la tabla `usuarios`, actualiza su `rol` a `superadmin`

## 📊 Estructura de la base de datos

### Tablas principales:

- **usuarios**: Información de usuarios y roles
- **productos**: Catálogo de productos
- **ventas**: Registro de ventas
- **gastos**: Registro de gastos
- **categorias**: Categorías de productos

## 🔐 Roles y permisos

| Funcionalidad | Superadmin | Dueño | Empleado |
|--------------|------------|-------|----------|
| Gestionar usuarios | ✅ | ❌ | ❌ |
| Ver dashboard | ✅ | ✅ | ✅ |
| Crear ventas | ✅ | ✅ | ✅ |
| Crear gastos | ✅ | ✅ | ✅ |
| Gestionar productos | ✅ | ✅ | ❌ |
| Ver estadísticas completas | ✅ | ✅ | ⚠️ Limitado |
| Exportar datos | ✅ | ✅ | ❌ |

## 📦 Dependencias principales

- **supabase_flutter**: Backend y autenticación
- **provider**: Gestión de estado
- **fl_chart**: Gráficos y estadísticas
- **excel**: Exportación de datos
- **image_picker**: Captura de fotos para gastos
- **google_sign_in**: Autenticación con Google

## 🎨 Diseño

- Paleta de colores moderna y profesional
- Diseño adaptable (responsive)
- Soporte para modo claro/oscuro
- Iconografía consistente

## 📄 Licencia

Proyecto desarrollado para MarketMove S.L.

## 👨‍💻 Desarrollo

Desarrollado con Flutter 3.x y Supabase.

---

**MarketMove App** - Gestión inteligente para tu comercio 🏪

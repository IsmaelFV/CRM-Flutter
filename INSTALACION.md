# 🚀 Guía de Instalación - MarketMove App

## Requisitos Previos

- Flutter SDK 3.0 o superior
- Dart SDK 3.0 o superior
- Android Studio o VS Code
- Cuenta de Supabase (gratuita)
- Git

## Paso 1: Clonar el Proyecto

```bash
cd Documents
git clone <url-del-repositorio>
cd CRM-Flutter
```

## Paso 2: Instalar Dependencias

```bash
flutter pub get
```

## Paso 3: Configurar Supabase

### 3.1 Crear Proyecto en Supabase

1. Ve a [https://supabase.com](https://supabase.com)
2. Crea una cuenta o inicia sesión
3. Crea un nuevo proyecto
4. Espera a que se complete la configuración (2-3 minutos)

### 3.2 Obtener Credenciales

1. En tu proyecto de Supabase, ve a **Settings** > **API**
2. Copia:
   - **Project URL** (ejemplo: https://xxxxx.supabase.co)
   - **anon public key** (clave larga que empieza con eyJ...)

### 3.3 Configurar Credenciales en la App

1. Copia el archivo de ejemplo:
   ```bash
   cp lib/src/config/supabase_config.example.dart lib/src/config/supabase_config.dart
   ```

2. Abre `lib/src/config/supabase_config.dart` y reemplaza con tus credenciales:
   ```dart
   class SupabaseConfig {
     static const String supabaseUrl = 'https://xxxxx.supabase.co';
     static const String supabaseAnonKey = 'eyJhbGc...tu-clave-aqui';
   }
   ```

## Paso 4: Configurar Base de Datos

### 4.1 Ejecutar Script de Schema

1. En Supabase, ve a **SQL Editor**
2. Crea una nueva query
3. Copia todo el contenido de `supabase/schema.sql`
4. Pégalo en el editor
5. Haz clic en **Run**
6. Verifica que se ejecutó sin errores

### 4.2 Ejecutar Script de RLS

1. En el SQL Editor, crea otra nueva query
2. Copia todo el contenido de `supabase/rls_policies.sql`
3. Pégalo en el editor
4. Haz clic en **Run**
5. Verifica que se ejecutó sin errores

### 4.3 Configurar Storage

1. Ve a **Storage** en Supabase
2. Haz clic en **Create a new bucket**
3. Nombre: `imagenes`
4. Marca como **Public bucket**
5. Haz clic en **Create bucket**

## Paso 5: Configurar Autenticación

### 5.1 Habilitar Métodos de Autenticación

1. Ve a **Authentication** > **Providers**
2. Habilita:
   - ✅ Email
   - ✅ Google (opcional, requiere configuración adicional)
   - ✅ Phone (opcional, requiere Twilio)

### 5.2 Configurar Google Sign-In (Opcional)

Si quieres habilitar Google Sign-In:

1. Ve a [Google Cloud Console](https://console.cloud.google.com)
2. Crea un proyecto
3. Habilita Google+ API
4. Crea credenciales OAuth 2.0
5. En Supabase, ve a **Authentication** > **Providers** > **Google**
6. Añade el Client ID y Client Secret
7. Copia la Callback URL y añádela en Google Cloud Console

## Paso 6: Crear Usuario Superadmin

### 6.1 Registrar Usuario

1. Ejecuta la app: `flutter run`
2. Regístrate con un email y contraseña
3. Verifica tu email (revisa spam si no llega)

### 6.2 Convertir a Superadmin

1. Ve a Supabase > **Table Editor** > **usuarios**
2. Busca tu usuario por email
3. Edita el campo `rol` y cámbialo a `superadmin`
4. Guarda los cambios
5. Cierra sesión y vuelve a iniciar sesión en la app

## Paso 7: Ejecutar la Aplicación

### Android

```bash
flutter run
```

### iOS (requiere Mac)

```bash
flutter run -d ios
```

### Web (desarrollo)

```bash
flutter run -d chrome
```

## Paso 8: Verificar Instalación

1. Inicia sesión con tu usuario superadmin
2. Verifica que puedes acceder a todas las pestañas
3. Crea un producto de prueba
4. Registra una venta de prueba
5. Registra un gasto de prueba
6. Verifica que el dashboard muestra los datos

## 🔧 Solución de Problemas

### Error: "Supabase URL not configured"

- Verifica que creaste el archivo `supabase_config.dart`
- Verifica que las credenciales son correctas
- Reinicia la app

### Error: "Table does not exist"

- Ejecuta los scripts SQL en el orden correcto
- Verifica que no hubo errores en la ejecución
- Revisa los logs en Supabase

### Error: "Permission denied"

- Verifica que ejecutaste el script de RLS
- Verifica que tu usuario tiene el rol correcto
- Revisa las políticas en Supabase > **Authentication** > **Policies**

### Error al subir imágenes

- Verifica que creaste el bucket `imagenes`
- Verifica que el bucket es público
- Revisa los permisos de storage en RLS

### La app no compila

```bash
flutter clean
flutter pub get
flutter run
```

## 📱 Configuración de Permisos

### Android

El archivo `AndroidManifest.xml` ya incluye los permisos necesarios.

### iOS

El archivo `Info.plist` ya incluye las descripciones de permisos necesarias.

## 🎉 ¡Listo!

Tu aplicación MarketMove está configurada y lista para usar.

### Próximos Pasos

1. Crea más usuarios con diferentes roles
2. Añade productos a tu catálogo
3. Empieza a registrar ventas y gastos
4. Explora las funcionalidades de exportación

## 📚 Documentación Adicional

- [Manual de Usuario](MANUAL_USUARIO.md)
- [Manual Técnico](MANUAL_TECNICO.md)
- [README](README.md)

## 🆘 Soporte

Si tienes problemas durante la instalación:

1. Revisa esta guía nuevamente
2. Consulta la documentación de [Flutter](https://flutter.dev/docs)
3. Consulta la documentación de [Supabase](https://supabase.com/docs)

---

**MarketMove App** - Gestión inteligente para tu comercio 🏪

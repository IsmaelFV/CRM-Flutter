# 🔄 Instrucciones de Migración a Sistema Multitienda

## ⚠️ IMPORTANTE: Leer antes de ejecutar

Esta migración convertirá tu CRM de tienda única a **sistema multitienda**. Es un cambio estructural importante en la base de datos.

---

## 📋 Orden de ejecución

### 1️⃣ **Hacer backup de la base de datos** (OBLIGATORIO)

**Opción A: Backup automático de Supabase** (recomendado si está disponible)
- Ve a `Database` → `Backups`
- Crea un backup manual antes de continuar

**Opción B: Backup manual con scripts SQL** (si no tienes acceso a backups automáticos)

1. Ejecuta `generar_backup_datos.sql` en Supabase SQL Editor
2. Copia **TODO** el resultado (output)
3. Guárdalo en un archivo llamado `backup_datos_[fecha].sql` en tu computadora
4. Este archivo te permitirá restaurar los datos si algo sale mal

**Archivos de seguridad creados:**
- ✅ `backup_esquema_original.sql` - Restaura la estructura original (sin multitienda)
- ✅ `generar_backup_datos.sql` - Genera backup de todos tus datos actuales

### 2️⃣ **Ejecutar script de migración multitienda**

Abre el archivo: `migracion_multitienda.sql`

1. Ve a Supabase → `SQL Editor`
2. Crea una nueva query
3. Copia y pega **TODO** el contenido de `migracion_multitienda.sql`
4. Haz clic en `Run`

**Esto creará:**
- Tabla `tiendas`
- Tabla `auditoria`
- Campo `dueno_id` en todas las tablas
- Nuevas políticas RLS filtradas por tienda
- Funciones helper para multitienda

### 3️⃣ **Ejecutar script de migración de datos existentes**

Abre el archivo: `migracion_datos_existentes.sql`

1. En el mismo `SQL Editor` de Supabase
2. Crea una nueva query
3. Copia y pega **TODO** el contenido de `migracion_datos_existentes.sql`
4. Haz clic en `Run`

**Esto hará:**
- Identificar o crear un dueño por defecto
- Crear una tienda para ese dueño
- Asignar todos los productos/ventas/gastos existentes a esa tienda
- Asignar todos los empleados a ese dueño
- Mostrar un resumen de la migración

### 4️⃣ **Verificar la migración**

Después de ejecutar ambos scripts, verifica en Supabase:

```sql
-- Ver tiendas creadas
SELECT * FROM public.tiendas;

-- Ver usuarios y sus dueños
SELECT id, nombre, apellido, rol, dueno_id FROM public.usuarios;

-- Ver productos con su tienda
SELECT id, nombre, dueno_id FROM public.productos LIMIT 10;

-- Ver ventas con su tienda
SELECT id, importe, dueno_id FROM public.ventas LIMIT 10;

-- Ver gastos con su tienda
SELECT id, importe, dueno_id FROM public.gastos LIMIT 10;
```

---

## 🎯 Resultado esperado

Después de la migración:

✅ **Tiendas**: Cada dueño tiene una tienda  
✅ **Empleados**: Todos asignados a un dueño  
✅ **Productos**: Todos pertenecen a una tienda  
✅ **Ventas**: Todas pertenecen a una tienda  
✅ **Gastos**: Todos pertenecen a una tienda  
✅ **RLS**: Políticas filtran automáticamente por tienda  
✅ **Auditoría**: Sistema de logs funcionando  

---

## 🔍 Solución de problemas

### Error: "No se encontró ningún dueño"

**Solución**: Crea manualmente un usuario con rol `dueno`:

```sql
-- Promover un usuario existente a dueño
UPDATE public.usuarios
SET rol = 'dueno'
WHERE email = 'tu-email@ejemplo.com';
```

Luego vuelve a ejecutar `migracion_datos_existentes.sql`.

### Error: "violates foreign key constraint"

**Causa**: Intentaste ejecutar los scripts en orden incorrecto.

**Solución**: 
1. Restaura el backup
2. Ejecuta primero `migracion_multitienda.sql`
3. Luego ejecuta `migracion_datos_existentes.sql`

### Error: "column dueno_id already exists"

**Causa**: Ya ejecutaste el script antes.

**Solución**: No pasa nada, el script usa `IF NOT EXISTS`. Puedes continuar.

---

## 📞 Siguiente paso

Una vez completada la migración SQL, continúa con:

**Fase 2**: Actualizar modelos Dart para incluir `dueno_id`

---

## 🔙 Rollback (en caso de emergencia)

Si algo sale mal:

1. Ve a Supabase → `Database` → `Backups`
2. Restaura el backup que creaste en el paso 1
3. Contacta para revisar el problema

---

**¿Listo para ejecutar?** Sigue los pasos en orden y verifica cada uno antes de continuar.

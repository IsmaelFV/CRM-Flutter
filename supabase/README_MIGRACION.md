# 📦 Archivos de Migración a Sistema Multitienda

## 📂 Archivos creados

### 🔧 Scripts de migración (ejecutar en orden)

1. **`generar_backup_datos.sql`** ⚠️ EJECUTAR PRIMERO
   - Genera un backup de todos tus datos actuales
   - Copia el resultado y guárdalo en un archivo
   - **Tiempo estimado**: 10 segundos

2. **`migracion_multitienda.sql`** 🔄 EJECUTAR SEGUNDO
   - Crea la estructura multitienda
   - Añade tablas `tiendas` y `auditoria`
   - Añade campo `dueno_id` a todas las tablas
   - Actualiza políticas RLS
   - **Tiempo estimado**: 30 segundos

3. **`migracion_datos_existentes.sql`** 📊 EJECUTAR TERCERO
   - Asigna todos los datos existentes a un dueño por defecto
   - Crea la "Tienda Principal"
   - Muestra resumen de la migración
   - **Tiempo estimado**: 20 segundos

### 🔙 Scripts de restauración (solo si algo sale mal)

4. **`backup_esquema_original.sql`**
   - Revierte la estructura a tienda única
   - Elimina tablas y campos de multitienda
   - Restaura políticas RLS originales
   - ⚠️ Solo usar si necesitas deshacer la migración

### 📖 Documentación

5. **`INSTRUCCIONES_MIGRACION.md`**
   - Guía paso a paso completa
   - Solución de problemas
   - Verificación de la migración

6. **`README_MIGRACION.md`** (este archivo)
   - Resumen de todos los archivos
   - Orden de ejecución rápido

---

## ⚡ Guía rápida de ejecución

```
┌─────────────────────────────────────────────────────┐
│  PASO 1: Backup                                     │
│  Ejecuta: generar_backup_datos.sql                  │
│  Guarda el resultado en un archivo                  │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│  PASO 2: Migración de estructura                    │
│  Ejecuta: migracion_multitienda.sql                 │
│  Crea tablas y campos nuevos                        │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│  PASO 3: Migración de datos                         │
│  Ejecuta: migracion_datos_existentes.sql            │
│  Asigna datos a tienda por defecto                  │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│  PASO 4: Verificación                               │
│  Revisa que todo se migró correctamente             │
│  Ver INSTRUCCIONES_MIGRACION.md                     │
└─────────────────────────────────────────────────────┘
```

---

## ✅ Checklist de migración

- [ ] He leído `INSTRUCCIONES_MIGRACION.md` completo
- [ ] He ejecutado `generar_backup_datos.sql` y guardado el resultado
- [ ] He ejecutado `migracion_multitienda.sql` sin errores
- [ ] He ejecutado `migracion_datos_existentes.sql` sin errores
- [ ] He verificado que los datos se migraron correctamente
- [ ] Estoy listo para continuar con Fase 2 (actualizar código Dart)

---

## 🆘 Si algo sale mal

1. **No entres en pánico** 🧘
2. Ejecuta el archivo de backup que guardaste en el Paso 1
3. Ejecuta `backup_esquema_original.sql` para restaurar la estructura
4. Revisa el error en `INSTRUCCIONES_MIGRACION.md` → Solución de problemas
5. Si persiste, contacta para ayuda

---

## 📊 Qué cambia después de la migración

### Antes (tienda única)
```
usuarios
├── superadmin
├── dueno
└── empleado

productos (todos globales)
ventas (todas globales)
gastos (todos globales)
```

### Después (multitienda)
```
usuarios
├── superadmin (ve todas las tiendas)
├── dueno_1 → tienda_1
│   ├── empleado_1
│   ├── empleado_2
│   ├── productos_tienda_1
│   ├── ventas_tienda_1
│   └── gastos_tienda_1
└── dueno_2 → tienda_2
    ├── empleado_3
    ├── productos_tienda_2
    ├── ventas_tienda_2
    └── gastos_tienda_2
```

---

## 🎯 Siguiente paso

Una vez completada la migración SQL, continúa con:

**Fase 2**: Actualizar modelos Dart para incluir `dueno_id`

Avísame cuando hayas ejecutado los 3 scripts y esté todo OK.

---

**Fecha de creación**: Diciembre 2025  
**Versión**: 1.0  
**Autor**: Sistema de migración automática

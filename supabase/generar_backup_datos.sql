-- ==============================================================================
-- SCRIPT PARA GENERAR BACKUP DE DATOS ACTUALES
-- Ejecuta este script ANTES de la migración multitienda
-- Copia el resultado y guárdalo en un archivo para poder restaurar después
-- ==============================================================================

-- ==============================================================================
-- INSTRUCCIONES:
-- 1. Ejecuta este script en Supabase SQL Editor
-- 2. Copia TODO el resultado (output)
-- 3. Guárdalo en un archivo llamado "backup_datos_[fecha].sql"
-- 4. Si necesitas restaurar, ejecuta ese archivo en SQL Editor
-- ==============================================================================

-- Mostrar información del backup
SELECT '-- ============================================' AS backup_info
UNION ALL
SELECT '-- BACKUP DE DATOS - ' || NOW()::TEXT
UNION ALL
SELECT '-- ============================================'
UNION ALL
SELECT '';

-- ==============================================================================
-- BACKUP DE USUARIOS
-- ==============================================================================
SELECT '-- USUARIOS (' || COUNT(*)::TEXT || ' registros)' FROM public.usuarios
UNION ALL
SELECT 'DELETE FROM public.usuarios WHERE id NOT IN (SELECT id FROM auth.users);'
UNION ALL
SELECT 'INSERT INTO public.usuarios (id, email, telefono, nombre, apellido, rol, activo, created_at, updated_at) VALUES' 
UNION ALL
SELECT '  (' || 
    quote_literal(id::TEXT) || '::UUID, ' ||
    quote_literal(email) || ', ' ||
    COALESCE(quote_literal(telefono), 'NULL') || ', ' ||
    quote_literal(nombre) || ', ' ||
    quote_literal(apellido) || ', ' ||
    quote_literal(rol) || ', ' ||
    activo::TEXT || ', ' ||
    quote_literal(created_at::TEXT) || '::TIMESTAMPTZ, ' ||
    COALESCE(quote_literal(updated_at::TEXT) || '::TIMESTAMPTZ', 'NULL') ||
    ')' ||
    CASE WHEN ROW_NUMBER() OVER (ORDER BY created_at) < COUNT(*) OVER () THEN ',' ELSE ';' END
FROM public.usuarios
ORDER BY created_at;

SELECT '' AS separator;

-- ==============================================================================
-- BACKUP DE CATEGORÍAS
-- ==============================================================================
SELECT '-- CATEGORÍAS (' || COUNT(*)::TEXT || ' registros)' FROM public.categorias
UNION ALL
SELECT 'DELETE FROM public.categorias;'
UNION ALL
SELECT 'INSERT INTO public.categorias (id, nombre, descripcion, created_at) VALUES'
UNION ALL
SELECT '  (' || 
    quote_literal(id::TEXT) || '::UUID, ' ||
    quote_literal(nombre) || ', ' ||
    COALESCE(quote_literal(descripcion), 'NULL') || ', ' ||
    quote_literal(created_at::TEXT) || '::TIMESTAMPTZ' ||
    ')' ||
    CASE WHEN ROW_NUMBER() OVER (ORDER BY created_at) < COUNT(*) OVER () THEN ',' ELSE ';' END
FROM public.categorias
ORDER BY created_at;

SELECT '' AS separator;

-- ==============================================================================
-- BACKUP DE PRODUCTOS
-- ==============================================================================
SELECT '-- PRODUCTOS (' || COUNT(*)::TEXT || ' registros)' FROM public.productos
UNION ALL
SELECT 'DELETE FROM public.productos;'
UNION ALL
SELECT 'INSERT INTO public.productos (id, nombre, precio, stock, codigo_barras, categoria_id, categoria, descripcion, imagen_url, stock_minimo, creado_por_id, activo, created_at, updated_at) VALUES'
UNION ALL
SELECT '  (' || 
    quote_literal(id::TEXT) || '::UUID, ' ||
    quote_literal(nombre) || ', ' ||
    precio::TEXT || ', ' ||
    stock::TEXT || ', ' ||
    COALESCE(quote_literal(codigo_barras), 'NULL') || ', ' ||
    COALESCE(quote_literal(categoria_id::TEXT) || '::UUID', 'NULL') || ', ' ||
    COALESCE(quote_literal(categoria), 'NULL') || ', ' ||
    COALESCE(quote_literal(descripcion), 'NULL') || ', ' ||
    COALESCE(quote_literal(imagen_url), 'NULL') || ', ' ||
    stock_minimo::TEXT || ', ' ||
    quote_literal(creado_por_id::TEXT) || '::UUID, ' ||
    activo::TEXT || ', ' ||
    quote_literal(created_at::TEXT) || '::TIMESTAMPTZ, ' ||
    COALESCE(quote_literal(updated_at::TEXT) || '::TIMESTAMPTZ', 'NULL') ||
    ')' ||
    CASE WHEN ROW_NUMBER() OVER (ORDER BY created_at) < COUNT(*) OVER () THEN ',' ELSE ';' END
FROM public.productos
ORDER BY created_at;

SELECT '' AS separator;

-- ==============================================================================
-- BACKUP DE VENTAS
-- ==============================================================================
SELECT '-- VENTAS (' || COUNT(*)::TEXT || ' registros)' FROM public.ventas
UNION ALL
SELECT 'DELETE FROM public.ventas;'
UNION ALL
SELECT 'INSERT INTO public.ventas (id, importe, fecha, producto_id, producto_nombre, cantidad, metodo_pago, comentarios, creado_por_id, creado_por_nombre, created_at) VALUES'
UNION ALL
SELECT '  (' || 
    quote_literal(id::TEXT) || '::UUID, ' ||
    importe::TEXT || ', ' ||
    quote_literal(fecha::TEXT) || '::TIMESTAMPTZ, ' ||
    quote_literal(producto_id::TEXT) || '::UUID, ' ||
    COALESCE(quote_literal(producto_nombre), 'NULL') || ', ' ||
    cantidad::TEXT || ', ' ||
    quote_literal(metodo_pago) || ', ' ||
    COALESCE(quote_literal(comentarios), 'NULL') || ', ' ||
    quote_literal(creado_por_id::TEXT) || '::UUID, ' ||
    COALESCE(quote_literal(creado_por_nombre), 'NULL') || ', ' ||
    quote_literal(created_at::TEXT) || '::TIMESTAMPTZ' ||
    ')' ||
    CASE WHEN ROW_NUMBER() OVER (ORDER BY created_at) < COUNT(*) OVER () THEN ',' ELSE ';' END
FROM public.ventas
ORDER BY created_at;

SELECT '' AS separator;

-- ==============================================================================
-- BACKUP DE GASTOS
-- ==============================================================================
SELECT '-- GASTOS (' || COUNT(*)::TEXT || ' registros)' FROM public.gastos
UNION ALL
SELECT 'DELETE FROM public.gastos;'
UNION ALL
SELECT 'INSERT INTO public.gastos (id, importe, fecha, concepto, cantidad, metodo_pago, comentarios, foto_url, categoria_gasto, creado_por_id, creado_por_nombre, created_at, updated_at) VALUES'
UNION ALL
SELECT '  (' || 
    quote_literal(id::TEXT) || '::UUID, ' ||
    importe::TEXT || ', ' ||
    quote_literal(fecha::TEXT) || '::TIMESTAMPTZ, ' ||
    quote_literal(concepto) || ', ' ||
    COALESCE(cantidad::TEXT, 'NULL') || ', ' ||
    quote_literal(metodo_pago) || ', ' ||
    COALESCE(quote_literal(comentarios), 'NULL') || ', ' ||
    COALESCE(quote_literal(foto_url), 'NULL') || ', ' ||
    COALESCE(quote_literal(categoria_gasto), 'NULL') || ', ' ||
    quote_literal(creado_por_id::TEXT) || '::UUID, ' ||
    COALESCE(quote_literal(creado_por_nombre), 'NULL') || ', ' ||
    quote_literal(created_at::TEXT) || '::TIMESTAMPTZ, ' ||
    COALESCE(quote_literal(updated_at::TEXT) || '::TIMESTAMPTZ', 'NULL') ||
    ')' ||
    CASE WHEN ROW_NUMBER() OVER (ORDER BY created_at) < COUNT(*) OVER () THEN ',' ELSE ';' END
FROM public.gastos
ORDER BY created_at;

SELECT '' AS separator;

-- ==============================================================================
-- RESUMEN DEL BACKUP
-- ==============================================================================
SELECT '-- ============================================' AS resumen
UNION ALL
SELECT '-- RESUMEN DEL BACKUP'
UNION ALL
SELECT '-- ============================================'
UNION ALL
SELECT '-- Usuarios: ' || COUNT(*)::TEXT FROM public.usuarios
UNION ALL
SELECT '-- Categorías: ' || COUNT(*)::TEXT FROM public.categorias
UNION ALL
SELECT '-- Productos: ' || COUNT(*)::TEXT FROM public.productos
UNION ALL
SELECT '-- Ventas: ' || COUNT(*)::TEXT FROM public.ventas
UNION ALL
SELECT '-- Gastos: ' || COUNT(*)::TEXT FROM public.gastos
UNION ALL
SELECT '-- ============================================'
UNION ALL
SELECT '-- Backup generado: ' || NOW()::TEXT
UNION ALL
SELECT '-- ============================================';

-- ==============================================================================
-- VERIFICAR DATOS POR TIENDA
-- Ejecuta estas queries en Supabase SQL Editor para ver cómo están los datos
-- ==============================================================================

-- 1. Ver todos los usuarios y sus tiendas
SELECT 
    u.id,
    u.nombre || ' ' || u.apellido as nombre_completo,
    u.email,
    u.rol,
    u.dueno_id,
    t.nombre as tienda
FROM public.usuarios u
LEFT JOIN public.tiendas t ON (
    CASE 
        WHEN u.rol = 'dueno' THEN u.id = t.dueno_id
        WHEN u.rol = 'empleado' THEN u.dueno_id = t.dueno_id
        ELSE false
    END
)
ORDER BY u.rol, u.nombre;

-- 2. Ver productos por dueño/tienda
SELECT 
    p.id,
    p.nombre as producto,
    p.dueno_id,
    u.nombre || ' ' || u.apellido as dueno,
    t.nombre as tienda
FROM public.productos p
LEFT JOIN public.usuarios u ON p.dueno_id = u.id
LEFT JOIN public.tiendas t ON p.dueno_id = t.dueno_id
ORDER BY t.nombre, p.nombre;

-- 3. Ver ventas por dueño/tienda
SELECT 
    v.id,
    v.importe,
    v.fecha,
    v.dueno_id,
    u.nombre || ' ' || u.apellido as dueno,
    t.nombre as tienda
FROM public.ventas v
LEFT JOIN public.usuarios u ON v.dueno_id = u.id
LEFT JOIN public.tiendas t ON v.dueno_id = t.dueno_id
ORDER BY t.nombre, v.fecha DESC
LIMIT 20;

-- 4. Ver gastos por dueño/tienda
SELECT 
    g.id,
    g.concepto,
    g.importe,
    g.fecha,
    g.dueno_id,
    u.nombre || ' ' || u.apellido as dueno,
    t.nombre as tienda
FROM public.gastos g
LEFT JOIN public.usuarios u ON g.dueno_id = u.id
LEFT JOIN public.tiendas t ON g.dueno_id = t.dueno_id
ORDER BY t.nombre, g.fecha DESC
LIMIT 20;

-- 5. Resumen por tienda
SELECT 
    t.nombre as tienda,
    t.dueno_id,
    u.nombre || ' ' || u.apellido as dueno,
    (SELECT COUNT(*) FROM public.productos WHERE dueno_id = t.dueno_id) as productos,
    (SELECT COUNT(*) FROM public.ventas WHERE dueno_id = t.dueno_id) as ventas,
    (SELECT COUNT(*) FROM public.gastos WHERE dueno_id = t.dueno_id) as gastos,
    (SELECT COUNT(*) FROM public.usuarios WHERE dueno_id = t.dueno_id AND rol = 'empleado') as empleados
FROM public.tiendas t
LEFT JOIN public.usuarios u ON t.dueno_id = u.id
ORDER BY t.nombre;

-- 6. Ver si hay datos sin dueño asignado (huérfanos)
SELECT 
    'Productos sin dueño' as tipo,
    COUNT(*) as cantidad
FROM public.productos
WHERE dueno_id IS NULL

UNION ALL

SELECT 
    'Ventas sin dueño' as tipo,
    COUNT(*) as cantidad
FROM public.ventas
WHERE dueno_id IS NULL

UNION ALL

SELECT 
    'Gastos sin dueño' as tipo,
    COUNT(*) as cantidad
FROM public.gastos
WHERE dueno_id IS NULL;

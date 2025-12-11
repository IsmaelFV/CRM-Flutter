-- ==============================================================================
-- RENOMBRAR TIENDA PRINCIPAL
-- Cambia el nombre de "Tienda Principal" a "Tienda de [Nombre del Dueño]"
-- ==============================================================================

-- Ver la tienda actual y su dueño
SELECT 
    t.id as tienda_id,
    t.nombre as nombre_actual,
    t.dueno_id,
    u.nombre || ' ' || u.apellido as dueno
FROM public.tiendas t
JOIN public.usuarios u ON t.dueno_id = u.id
WHERE t.nombre = 'Tienda Principal';

-- Renombrar automáticamente usando el nombre del dueño
UPDATE public.tiendas t
SET nombre = 'Tienda de ' || u.nombre || ' ' || u.apellido
FROM public.usuarios u
WHERE t.dueno_id = u.id 
  AND t.nombre = 'Tienda Principal';

-- Verificar el cambio
SELECT 
    t.nombre as nuevo_nombre,
    u.nombre || ' ' || u.apellido as dueno
FROM public.tiendas t
JOIN public.usuarios u ON t.dueno_id = u.id;

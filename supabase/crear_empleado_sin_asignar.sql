-- Script para crear un empleado de prueba sin dueño asignado
-- Esto permite probar la funcionalidad de "Empleados Disponibles"

-- Primero, verificar si ya existe un empleado sin asignar
SELECT 
    id,
    nombre,
    apellido,
    email,
    rol,
    dueno_id
FROM public.usuarios
WHERE rol = 'empleado' AND dueno_id IS NULL;

-- Si no hay ninguno, puedes crear uno manualmente:
-- NOTA: Necesitas crear primero el usuario en auth.users desde Supabase Dashboard
-- o usar la pantalla de registro de la app

-- Alternativamente, puedes "desasignar" un empleado existente:
-- UPDATE public.usuarios
-- SET dueno_id = NULL
-- WHERE id = 'ID_DEL_EMPLEADO_AQUI';

-- Para ver todos los empleados y sus asignaciones:
SELECT 
    u.id,
    u.nombre,
    u.apellido,
    u.email,
    u.rol,
    u.dueno_id,
    u.activo,
    t.nombre as tienda_nombre
FROM public.usuarios u
LEFT JOIN public.tiendas t ON u.dueno_id = t.dueno_id
WHERE u.rol = 'empleado'
ORDER BY u.dueno_id NULLS FIRST, u.nombre;

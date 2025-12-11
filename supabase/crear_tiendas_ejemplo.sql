-- ==============================================================================
-- CREAR TIENDAS DE EJEMPLO
-- Este script crea tiendas adicionales para probar el sistema multitienda
-- ==============================================================================

-- Ver tiendas actuales
SELECT 
    t.id,
    t.nombre,
    t.dueno_id,
    u.nombre || ' ' || u.apellido as dueno,
    t.activa
FROM public.tiendas t
LEFT JOIN public.usuarios u ON t.dueno_id = u.id
ORDER BY t.nombre;

-- ==============================================================================
-- OPCIÓN 1: Si quieres crear nuevos dueños con sus tiendas
-- ==============================================================================

-- Primero, necesitas crear usuarios con rol 'dueno' en la app
-- O puedes promover usuarios existentes a dueños:

-- Ver usuarios que podrían ser dueños
SELECT id, nombre, apellido, email, rol 
FROM public.usuarios 
WHERE rol != 'superadmin'
ORDER BY nombre;

-- Promover un usuario a dueño (cambia el ID por el que quieras)
-- UPDATE public.usuarios 
-- SET rol = 'dueno', dueno_id = NULL
-- WHERE id = 'AQUI_EL_ID_DEL_USUARIO';

-- Luego crear su tienda
-- INSERT INTO public.tiendas (nombre, dueno_id, activa)
-- VALUES ('Tienda de Juan', 'AQUI_EL_ID_DEL_DUENO', true);

-- ==============================================================================
-- OPCIÓN 2: Renombrar la tienda actual para que sea más descriptiva
-- ==============================================================================

-- Ver el nombre actual de la tienda
SELECT t.nombre, u.nombre || ' ' || u.apellido as dueno
FROM public.tiendas t
JOIN public.usuarios u ON t.dueno_id = u.id;

-- Renombrar la tienda (cambia el nombre por el que quieras)
-- UPDATE public.tiendas
-- SET nombre = 'Tienda de [NOMBRE DEL DUEÑO]'
-- WHERE id = 'AQUI_EL_ID_DE_LA_TIENDA';

-- ==============================================================================
-- EJEMPLO COMPLETO: Crear un nuevo dueño con su tienda
-- ==============================================================================

-- PASO 1: Crear el usuario dueño (hazlo desde la app con el registro)
-- O si ya tienes un usuario, promoverlo:
/*
UPDATE public.usuarios 
SET rol = 'dueno', dueno_id = NULL
WHERE email = 'email_del_usuario@ejemplo.com';
*/

-- PASO 2: Obtener el ID del dueño que acabas de crear/promover
/*
SELECT id, nombre, apellido FROM public.usuarios WHERE rol = 'dueno';
*/

-- PASO 3: Crear la tienda para ese dueño
/*
INSERT INTO public.tiendas (nombre, dueno_id, direccion, telefono, activa)
VALUES (
    'Tienda de Fernando',  -- Nombre de la tienda
    'AQUI_EL_ID_DEL_DUENO',  -- ID del dueño
    'Calle Ejemplo 123',  -- Dirección (opcional)
    '666777888',  -- Teléfono (opcional)
    true  -- Activa
);
*/

-- ==============================================================================
-- VERIFICAR RESULTADO
-- ==============================================================================

-- Ver todas las tiendas con sus dueños
SELECT 
    t.nombre as tienda,
    u.nombre || ' ' || u.apellido as dueno,
    u.email,
    t.activa,
    (SELECT COUNT(*) FROM public.productos WHERE dueno_id = t.dueno_id) as productos,
    (SELECT COUNT(*) FROM public.ventas WHERE dueno_id = t.dueno_id) as ventas
FROM public.tiendas t
JOIN public.usuarios u ON t.dueno_id = u.id
ORDER BY t.nombre;

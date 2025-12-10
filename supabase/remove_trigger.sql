-- ==============================================================================
-- SCRIPT DE LIMPIEZA DE TRIGGERS
-- Elimina el trigger automático que causa duplicidad de usuarios
-- ==============================================================================

-- 1. Eliminar el trigger que se dispara al crear un usuario en Auth
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- 2. Eliminar la función asociada al trigger
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Nota: Ahora la responsabilidad de crear el usuario en la tabla 'public.usuarios'
-- recae totalmente en la aplicación Flutter, que es lo correcto para este caso.

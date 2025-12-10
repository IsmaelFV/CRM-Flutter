-- ==============================================================================
-- SOLUCIÓN FINAL PARA EL REGISTRO DE USUARIOS
-- Permite que los nuevos usuarios puedan crear su propio perfil
-- ==============================================================================

-- 1. Asegurar que la función helper existe (por si acaso)
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS text AS $$
BEGIN
  RETURN (SELECT rol FROM public.usuarios WHERE id = auth.uid());
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Eliminar política restrictiva de inserción
DROP POLICY IF EXISTS "Los superadmins pueden crear usuarios" ON public.usuarios;
DROP POLICY IF EXISTS "Usuarios pueden crear su perfil" ON public.usuarios;

-- 3. Crear política permisiva para el registro
-- Permite insertar si: eres Superadmin O BIEN estás creando tu propio perfil
CREATE POLICY "Permitir registro de usuarios"
    ON public.usuarios FOR INSERT
    WITH CHECK (
        -- Opción A: Es el propio usuario registrándose
        auth.uid() = id
        OR
        -- Opción B: Es un superadmin creando otro usuario
        public.get_my_role() = 'superadmin'
    );

-- 4. Asegurar permisos de lectura para que la app no falle tras el registro
DROP POLICY IF EXISTS "Los usuarios pueden ver su propio perfil" ON public.usuarios;
CREATE POLICY "Los usuarios pueden ver su propio perfil"
    ON public.usuarios FOR SELECT
    USING (auth.uid() = id);

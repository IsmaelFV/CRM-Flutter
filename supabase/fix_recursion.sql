-- ==============================================================================
-- SCRIPT DE CORRECCIÓN DE RECURSIÓN INFINITA
-- Ejecuta TODO este script en el SQL Editor de Supabase para arreglar el error.
-- ==============================================================================

-- 1. Función de seguridad para leer el rol sin activar bucles infinitos
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS text AS $$
BEGIN
  -- Esta consulta se ejecuta con permisos de sistema (SECURITY DEFINER)
  -- evitando las restricciones RLS normales para esta lectura específica
  RETURN (SELECT rol FROM public.usuarios WHERE id = auth.uid());
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Eliminar las políticas conflictivas antiguas
DROP POLICY IF EXISTS "Los superadmins pueden ver todos los usuarios" ON public.usuarios;
DROP POLICY IF EXISTS "Los superadmins pueden crear usuarios" ON public.usuarios;
DROP POLICY IF EXISTS "Los superadmins pueden actualizar usuarios" ON public.usuarios;
DROP POLICY IF EXISTS "Los usuarios pueden ver su propio perfil" ON public.usuarios;
DROP POLICY IF EXISTS "Los usuarios pueden actualizar su perfil" ON public.usuarios;

-- 3. Crear las nuevas políticas seguras que usan la función helper

-- Lectura: Superadmins ven todo
CREATE POLICY "Los superadmins pueden ver todos los usuarios"
    ON public.usuarios FOR SELECT
    USING (public.get_my_role() = 'superadmin');

-- Inserción: Superadmins crean usuarios
CREATE POLICY "Los superadmins pueden crear usuarios"
    ON public.usuarios FOR INSERT
    WITH CHECK (public.get_my_role() = 'superadmin');

-- Actualización: Superadmins editan usuarios
CREATE POLICY "Los superadmins pueden actualizar usuarios"
    ON public.usuarios FOR UPDATE
    USING (public.get_my_role() = 'superadmin');

-- Lectura: Usuarios ven su perfil
CREATE POLICY "Los usuarios pueden ver su propio perfil"
    ON public.usuarios FOR SELECT
    USING (auth.uid() = id);

-- Actualización: Usuarios editan su perfil
CREATE POLICY "Los usuarios pueden actualizar su perfil"
    ON public.usuarios FOR UPDATE
    USING (auth.uid() = id);

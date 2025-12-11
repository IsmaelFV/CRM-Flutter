-- ==============================================================================
-- POLÍTICA DE ELIMINACIÓN DE USUARIOS
-- Permite a superadmins eliminar cualquier usuario
-- Permite a dueños eliminar solo empleados
-- ==============================================================================

-- Eliminar política anterior si existe
DROP POLICY IF EXISTS "Superadmins pueden eliminar usuarios" ON public.usuarios;
DROP POLICY IF EXISTS "Dueños pueden eliminar empleados" ON public.usuarios;

-- Superadmins pueden eliminar cualquier usuario
CREATE POLICY "Superadmins pueden eliminar usuarios"
    ON public.usuarios FOR DELETE
    USING (public.get_my_role() = 'superadmin');

-- Dueños pueden eliminar solo empleados
CREATE POLICY "Dueños pueden eliminar empleados"
    ON public.usuarios FOR DELETE
    USING (
        public.get_my_role() = 'dueno' 
        AND rol = 'empleado'
    );

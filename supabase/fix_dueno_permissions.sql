-- ==============================================================================
-- CORREGIR PERMISOS PARA DUEÑOS
-- Permite a los dueños actualizar el estado de sus empleados
-- ==============================================================================

-- Eliminar política restrictiva si existe
DROP POLICY IF EXISTS "Dueños pueden actualizar sus empleados" ON public.usuarios;

-- Crear política que permite a dueños actualizar sus empleados
CREATE POLICY "Dueños pueden actualizar sus empleados"
    ON public.usuarios FOR UPDATE
    USING (
        public.get_my_role() = 'dueno' 
        AND rol = 'empleado'
        AND dueno_id = auth.uid()
    )
    WITH CHECK (
        public.get_my_role() = 'dueno' 
        AND rol = 'empleado'
        AND dueno_id = auth.uid()
    );

-- Verificar que la política se creó correctamente
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'usuarios' AND policyname LIKE '%Dueños%';

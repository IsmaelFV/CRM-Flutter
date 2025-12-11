-- ==============================================================================
-- PERMITIR A DUEÑOS VER Y ASIGNAR EMPLEADOS SIN DUEÑO
-- ==============================================================================

-- 1. Permitir a los dueños VER empleados de su tienda o sin asignar
DROP POLICY IF EXISTS "Dueños pueden ver empleados" ON public.usuarios;

CREATE POLICY "Dueños pueden ver empleados"
    ON public.usuarios FOR SELECT
    USING (
      public.get_my_role() = 'dueno'
      AND rol = 'empleado'
      AND (
        dueno_id = auth.uid()      -- empleados de su tienda
        OR dueno_id IS NULL        -- empleados sin asignar
      )
    );

-- 2. Permitir a los dueños ACTUALIZAR empleados de su tienda
--    Y también ASIGNAR empleados sin dueño a su tienda
DROP POLICY IF EXISTS "Dueños pueden actualizar sus empleados" ON public.usuarios;

CREATE POLICY "Dueños pueden actualizar sus empleados"
    ON public.usuarios FOR UPDATE
    USING (
        public.get_my_role() = 'dueno' 
        AND rol = 'empleado'
        AND (
            dueno_id = auth.uid()      -- Ya es su empleado
            OR dueno_id IS NULL        -- Empleado sin asignar que puede reclamar
        )
    )
    WITH CHECK (
        public.get_my_role() = 'dueno' 
        AND rol = 'empleado'
        AND dueno_id = auth.uid()      -- Solo puede asignarlo a sí mismo
    );

-- 3. Verificar que las políticas se crearon correctamente
SELECT 
    schemaname, 
    tablename, 
    policyname, 
    permissive, 
    cmd, 
    qual as "USING condition",
    with_check as "WITH CHECK condition"
FROM pg_policies
WHERE tablename = 'usuarios' 
  AND policyname LIKE '%Dueños%'
ORDER BY policyname;

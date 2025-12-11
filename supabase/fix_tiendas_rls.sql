-- ==============================================================================
-- CORREGIR POLÍTICAS RLS PARA TABLA TIENDAS
-- Permite crear tiendas automáticamente al registrar dueños
-- ==============================================================================

-- Eliminar política restrictiva actual
DROP POLICY IF EXISTS "Superadmin puede crear tiendas" ON public.tiendas;

-- Crear nueva política que permite:
-- 1. Superadmin puede crear cualquier tienda
-- 2. Sistema puede crear tienda para el usuario que se está registrando
CREATE POLICY "Crear tiendas permitido"
    ON public.tiendas FOR INSERT
    WITH CHECK (
        public.get_my_role() = 'superadmin' 
        OR dueno_id = auth.uid()  -- Permite crear su propia tienda
    );

-- Verificar políticas actuales
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'tiendas'
ORDER BY policyname;

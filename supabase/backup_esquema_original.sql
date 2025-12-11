-- ==============================================================================
-- BACKUP DEL ESQUEMA ORIGINAL (ANTES DE MIGRACIÓN MULTITIENDA)
-- Este script permite restaurar la estructura original de la base de datos
-- Ejecutar solo si necesitas revertir la migración multitienda
-- ==============================================================================

-- ==============================================================================
-- PASO 1: ELIMINAR TABLAS Y FUNCIONES DE MULTITIENDA (SI EXISTEN)
-- ==============================================================================

-- Eliminar triggers de auditoría
DROP TRIGGER IF EXISTS auditoria_usuarios ON public.usuarios;
DROP TRIGGER IF EXISTS auditoria_productos ON public.productos;

-- Eliminar funciones de multitienda
DROP FUNCTION IF EXISTS public.registrar_auditoria();
DROP FUNCTION IF EXISTS public.get_my_dueno_id();

-- Eliminar tablas de multitienda
DROP TABLE IF EXISTS public.auditoria CASCADE;
DROP TABLE IF EXISTS public.tiendas CASCADE;

-- ==============================================================================
-- PASO 2: ELIMINAR COLUMNAS dueno_id AÑADIDAS EN LA MIGRACIÓN
-- ==============================================================================

-- Eliminar dueno_id de usuarios
ALTER TABLE public.usuarios DROP COLUMN IF EXISTS dueno_id;

-- Eliminar dueno_id de productos
ALTER TABLE public.productos DROP COLUMN IF EXISTS dueno_id;

-- Eliminar dueno_id de ventas
ALTER TABLE public.ventas DROP COLUMN IF EXISTS dueno_id;

-- Eliminar dueno_id de gastos
ALTER TABLE public.gastos DROP COLUMN IF EXISTS dueno_id;

-- ==============================================================================
-- PASO 3: RESTAURAR POLÍTICAS RLS ORIGINALES
-- ==============================================================================

-- ============================================
-- POLÍTICAS PARA USUARIOS
-- ============================================
DROP POLICY IF EXISTS "Ver usuarios según rol y tienda" ON public.usuarios;
DROP POLICY IF EXISTS "Actualizar usuarios según rol" ON public.usuarios;
DROP POLICY IF EXISTS "Insertar usuarios" ON public.usuarios;
DROP POLICY IF EXISTS "Eliminar usuarios según rol" ON public.usuarios;

-- Usuarios pueden ver su propio perfil
CREATE POLICY "Usuarios pueden ver su propio perfil"
    ON public.usuarios FOR SELECT
    USING (id = auth.uid());

-- Superadmins pueden ver todos los usuarios
CREATE POLICY "Superadmins pueden ver todos los usuarios"
    ON public.usuarios FOR SELECT
    USING (public.get_my_role() = 'superadmin');

-- Dueños pueden ver sus empleados
CREATE POLICY "Dueños pueden ver sus empleados"
    ON public.usuarios FOR SELECT
    USING (
        public.get_my_role() = 'dueno'
    );

-- Usuarios pueden actualizar su propio perfil
CREATE POLICY "Usuarios pueden actualizar su propio perfil"
    ON public.usuarios FOR UPDATE
    USING (id = auth.uid());

-- Superadmins pueden actualizar usuarios
CREATE POLICY "Superadmins pueden actualizar usuarios"
    ON public.usuarios FOR UPDATE
    USING (public.get_my_role() = 'superadmin');

-- Usuarios pueden insertar su propio perfil (registro)
CREATE POLICY "Usuarios pueden insertar su propio perfil"
    ON public.usuarios FOR INSERT
    WITH CHECK (id = auth.uid());

-- Superadmins pueden eliminar usuarios
CREATE POLICY "Superadmins pueden eliminar usuarios"
    ON public.usuarios FOR DELETE
    USING (public.get_my_role() = 'superadmin');

-- Dueños pueden eliminar empleados
CREATE POLICY "Dueños pueden eliminar empleados"
    ON public.usuarios FOR DELETE
    USING (
        public.get_my_role() = 'dueno' 
        AND rol = 'empleado'
    );

-- ============================================
-- POLÍTICAS PARA PRODUCTOS
-- ============================================
DROP POLICY IF EXISTS "Ver productos de mi tienda" ON public.productos;
DROP POLICY IF EXISTS "Crear productos en mi tienda" ON public.productos;
DROP POLICY IF EXISTS "Actualizar productos de mi tienda" ON public.productos;
DROP POLICY IF EXISTS "Eliminar productos de mi tienda" ON public.productos;

-- Todos pueden ver productos activos
CREATE POLICY "Todos pueden ver productos activos"
    ON public.productos FOR SELECT
    USING (activo = true OR public.get_my_role() IN ('superadmin', 'dueno'));

-- Dueños y superadmins pueden crear productos
CREATE POLICY "Dueños y superadmins pueden crear productos"
    ON public.productos FOR INSERT
    WITH CHECK (public.get_my_role() IN ('superadmin', 'dueno'));

-- Dueños y superadmins pueden actualizar productos
CREATE POLICY "Dueños y superadmins pueden actualizar productos"
    ON public.productos FOR UPDATE
    USING (public.get_my_role() IN ('superadmin', 'dueno'));

-- Dueños y superadmins pueden eliminar productos
CREATE POLICY "Dueños y superadmins pueden eliminar productos"
    ON public.productos FOR DELETE
    USING (public.get_my_role() IN ('superadmin', 'dueno'));

-- ============================================
-- POLÍTICAS PARA VENTAS
-- ============================================
DROP POLICY IF EXISTS "Ver ventas de mi tienda" ON public.ventas;
DROP POLICY IF EXISTS "Crear ventas en mi tienda" ON public.ventas;
DROP POLICY IF EXISTS "Actualizar ventas de mi tienda" ON public.ventas;
DROP POLICY IF EXISTS "Eliminar ventas de mi tienda" ON public.ventas;

-- Todos pueden ver ventas
CREATE POLICY "Todos pueden ver ventas"
    ON public.ventas FOR SELECT
    USING (true);

-- Todos pueden crear ventas
CREATE POLICY "Todos pueden crear ventas"
    ON public.ventas FOR INSERT
    WITH CHECK (true);

-- ============================================
-- POLÍTICAS PARA GASTOS
-- ============================================
DROP POLICY IF EXISTS "Ver gastos de mi tienda" ON public.gastos;
DROP POLICY IF EXISTS "Crear gastos en mi tienda" ON public.gastos;
DROP POLICY IF EXISTS "Actualizar gastos de mi tienda" ON public.gastos;
DROP POLICY IF EXISTS "Eliminar gastos de mi tienda" ON public.gastos;

-- Todos pueden ver gastos
CREATE POLICY "Todos pueden ver gastos"
    ON public.gastos FOR SELECT
    USING (true);

-- Todos pueden crear gastos
CREATE POLICY "Todos pueden crear gastos"
    ON public.gastos FOR INSERT
    WITH CHECK (true);

-- Todos pueden actualizar gastos
CREATE POLICY "Todos pueden actualizar gastos"
    ON public.gastos FOR UPDATE
    USING (true);

-- ==============================================================================
-- PASO 4: ELIMINAR ÍNDICES DE MULTITIENDA
-- ==============================================================================

DROP INDEX IF EXISTS idx_tiendas_dueno;
DROP INDEX IF EXISTS idx_usuarios_dueno;
DROP INDEX IF EXISTS idx_productos_dueno;
DROP INDEX IF EXISTS idx_ventas_dueno;
DROP INDEX IF EXISTS idx_gastos_dueno;
DROP INDEX IF EXISTS idx_auditoria_usuario;
DROP INDEX IF EXISTS idx_auditoria_dueno;
DROP INDEX IF EXISTS idx_auditoria_fecha;
DROP INDEX IF EXISTS idx_auditoria_accion;

-- ==============================================================================
-- FINALIZADO
-- ==============================================================================
-- El esquema ha sido restaurado a su estado original (antes de multitienda).
-- Ahora la base de datos funciona como una tienda única sin separación por dueños.
-- 
-- NOTA: Este script NO restaura los datos, solo la estructura.
-- Si necesitas recuperar datos, deberás restaurar desde un backup completo.

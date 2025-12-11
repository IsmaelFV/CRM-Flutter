-- ==============================================================================
-- MIGRACIÓN A SISTEMA MULTITIENDA
-- Este script adapta el CRM para soportar múltiples tiendas independientes
-- ==============================================================================

-- ==============================================================================
-- PASO 1: CREAR TABLA DE TIENDAS
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.tiendas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre TEXT NOT NULL,
    direccion TEXT,
    telefono TEXT,
    email TEXT,
    dueno_id UUID NOT NULL REFERENCES public.usuarios(id) ON DELETE CASCADE,
    activa BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(dueno_id) -- Un dueño = una tienda
);

-- Índice para búsquedas por dueño
CREATE INDEX IF NOT EXISTS idx_tiendas_dueno ON public.tiendas(dueno_id);

-- Trigger para updated_at
CREATE TRIGGER update_tiendas_updated_at
    BEFORE UPDATE ON public.tiendas
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ==============================================================================
-- PASO 2: AÑADIR CAMPO dueno_id A TABLA usuarios
-- ==============================================================================
-- Los empleados deben estar asociados a un dueño
ALTER TABLE public.usuarios 
ADD COLUMN IF NOT EXISTS dueno_id UUID REFERENCES public.usuarios(id) ON DELETE CASCADE;

-- Índice para búsquedas por dueño
CREATE INDEX IF NOT EXISTS idx_usuarios_dueno ON public.usuarios(dueno_id);

-- Comentario explicativo
COMMENT ON COLUMN public.usuarios.dueno_id IS 'ID del dueño al que pertenece este empleado. NULL para superadmin y dueños.';

-- ==============================================================================
-- PASO 3: AÑADIR CAMPO dueno_id A TABLA productos
-- ==============================================================================
-- Primero añadir la columna como nullable
ALTER TABLE public.productos 
ADD COLUMN IF NOT EXISTS dueno_id UUID REFERENCES public.usuarios(id) ON DELETE CASCADE;

-- Índice para búsquedas por dueño
CREATE INDEX IF NOT EXISTS idx_productos_dueno ON public.productos(dueno_id);

-- ==============================================================================
-- PASO 4: AÑADIR CAMPO dueno_id A TABLA ventas
-- ==============================================================================
-- Primero añadir la columna como nullable
ALTER TABLE public.ventas 
ADD COLUMN IF NOT EXISTS dueno_id UUID REFERENCES public.usuarios(id) ON DELETE CASCADE;

-- Índice para búsquedas por dueño
CREATE INDEX IF NOT EXISTS idx_ventas_dueno ON public.ventas(dueno_id);

-- ==============================================================================
-- PASO 5: AÑADIR CAMPO dueno_id A TABLA gastos
-- ==============================================================================
-- Primero añadir la columna como nullable
ALTER TABLE public.gastos 
ADD COLUMN IF NOT EXISTS dueno_id UUID REFERENCES public.usuarios(id) ON DELETE CASCADE;

-- Índice para búsquedas por dueño
CREATE INDEX IF NOT EXISTS idx_gastos_dueno ON public.gastos(dueno_id);

-- ==============================================================================
-- PASO 6: CREAR TABLA DE AUDITORÍA
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.auditoria (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    accion TEXT NOT NULL, -- 'crear_usuario', 'eliminar_usuario', 'cambiar_rol', etc.
    tabla TEXT NOT NULL, -- 'usuarios', 'productos', 'ventas', 'gastos'
    registro_id UUID, -- ID del registro afectado
    usuario_id UUID NOT NULL REFERENCES public.usuarios(id) ON DELETE CASCADE,
    usuario_nombre TEXT,
    dueno_id UUID REFERENCES public.usuarios(id) ON DELETE CASCADE, -- A qué tienda pertenece la acción
    detalles JSONB, -- Información adicional en formato JSON
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para consultas de auditoría
CREATE INDEX IF NOT EXISTS idx_auditoria_usuario ON public.auditoria(usuario_id);
CREATE INDEX IF NOT EXISTS idx_auditoria_dueno ON public.auditoria(dueno_id);
CREATE INDEX IF NOT EXISTS idx_auditoria_fecha ON public.auditoria(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_auditoria_accion ON public.auditoria(accion);

-- ==============================================================================
-- PASO 7: FUNCIÓN HELPER PARA OBTENER dueno_id DEL USUARIO ACTUAL
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.get_my_dueno_id()
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    user_rol TEXT;
    user_dueno_id UUID;
BEGIN
    -- Obtener rol y dueno_id del usuario actual
    SELECT rol, dueno_id INTO user_rol, user_dueno_id
    FROM public.usuarios
    WHERE id = auth.uid();
    
    -- Si es superadmin, retornar NULL (puede ver todo)
    IF user_rol = 'superadmin' THEN
        RETURN NULL;
    END IF;
    
    -- Si es dueño, retornar su propio ID
    IF user_rol = 'dueno' THEN
        RETURN auth.uid();
    END IF;
    
    -- Si es empleado, retornar el ID de su dueño
    IF user_rol = 'empleado' THEN
        RETURN user_dueno_id;
    END IF;
    
    -- Por defecto, sin acceso
    RETURN '00000000-0000-0000-0000-000000000000'::UUID;
END;
$$;

-- ==============================================================================
-- PASO 8: ACTUALIZAR POLÍTICAS RLS PARA FILTRAR POR TIENDA
-- ==============================================================================

-- Eliminar políticas antiguas de usuarios
DROP POLICY IF EXISTS "Usuarios pueden ver su propio perfil" ON public.usuarios;
DROP POLICY IF EXISTS "Superadmins pueden ver todos los usuarios" ON public.usuarios;
DROP POLICY IF EXISTS "Dueños pueden ver sus empleados" ON public.usuarios;
DROP POLICY IF EXISTS "Usuarios pueden actualizar su propio perfil" ON public.usuarios;
DROP POLICY IF EXISTS "Superadmins pueden actualizar usuarios" ON public.usuarios;
DROP POLICY IF EXISTS "Usuarios pueden insertar su propio perfil" ON public.usuarios;
DROP POLICY IF EXISTS "Superadmins pueden eliminar usuarios" ON public.usuarios;
DROP POLICY IF EXISTS "Dueños pueden eliminar empleados" ON public.usuarios;

-- NUEVAS POLÍTICAS PARA USUARIOS
-- Ver usuarios
CREATE POLICY "Ver usuarios según rol y tienda"
    ON public.usuarios FOR SELECT
    USING (
        id = auth.uid() -- Ver su propio perfil
        OR public.get_my_role() = 'superadmin' -- Superadmin ve todo
        OR (public.get_my_role() = 'dueno' AND dueno_id = auth.uid()) -- Dueño ve sus empleados
    );

-- Actualizar usuarios
CREATE POLICY "Actualizar usuarios según rol"
    ON public.usuarios FOR UPDATE
    USING (
        id = auth.uid() -- Actualizar su propio perfil
        OR public.get_my_role() = 'superadmin' -- Superadmin actualiza todo
    );

-- Insertar usuarios (registro)
CREATE POLICY "Insertar usuarios"
    ON public.usuarios FOR INSERT
    WITH CHECK (
        id = auth.uid() -- Insertar su propio perfil
        OR public.get_my_role() = 'superadmin' -- Superadmin puede crear usuarios
    );

-- Eliminar usuarios
CREATE POLICY "Eliminar usuarios según rol"
    ON public.usuarios FOR DELETE
    USING (
        public.get_my_role() = 'superadmin' -- Superadmin elimina cualquiera
        OR (public.get_my_role() = 'dueno' AND dueno_id = auth.uid() AND rol = 'empleado') -- Dueño elimina sus empleados
    );

-- ==============================================================================
-- POLÍTICAS RLS PARA TIENDAS
-- ==============================================================================
ALTER TABLE public.tiendas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Ver tiendas según rol"
    ON public.tiendas FOR SELECT
    USING (
        public.get_my_role() = 'superadmin' -- Superadmin ve todas
        OR dueno_id = auth.uid() -- Dueño ve su tienda
        OR dueno_id = public.get_my_dueno_id() -- Empleado ve la tienda de su dueño
    );

CREATE POLICY "Dueños pueden actualizar su tienda"
    ON public.tiendas FOR UPDATE
    USING (dueno_id = auth.uid() OR public.get_my_role() = 'superadmin');

CREATE POLICY "Superadmin puede crear tiendas"
    ON public.tiendas FOR INSERT
    WITH CHECK (public.get_my_role() = 'superadmin');

CREATE POLICY "Superadmin puede eliminar tiendas"
    ON public.tiendas FOR DELETE
    USING (public.get_my_role() = 'superadmin');

-- ==============================================================================
-- POLÍTICAS RLS PARA PRODUCTOS (FILTRAR POR TIENDA)
-- ==============================================================================
DROP POLICY IF EXISTS "Todos pueden ver productos activos" ON public.productos;
DROP POLICY IF EXISTS "Dueños y superadmins pueden crear productos" ON public.productos;
DROP POLICY IF EXISTS "Dueños y superadmins pueden actualizar productos" ON public.productos;
DROP POLICY IF EXISTS "Dueños y superadmins pueden eliminar productos" ON public.productos;

CREATE POLICY "Ver productos de mi tienda"
    ON public.productos FOR SELECT
    USING (
        public.get_my_role() = 'superadmin' -- Superadmin ve todo
        OR dueno_id = public.get_my_dueno_id() -- Solo productos de mi tienda
    );

CREATE POLICY "Crear productos en mi tienda"
    ON public.productos FOR INSERT
    WITH CHECK (
        public.get_my_role() = 'superadmin'
        OR (public.get_my_role() IN ('dueno', 'empleado') AND dueno_id = public.get_my_dueno_id())
    );

CREATE POLICY "Actualizar productos de mi tienda"
    ON public.productos FOR UPDATE
    USING (
        public.get_my_role() = 'superadmin'
        OR dueno_id = public.get_my_dueno_id()
    );

CREATE POLICY "Eliminar productos de mi tienda"
    ON public.productos FOR DELETE
    USING (
        public.get_my_role() = 'superadmin'
        OR (public.get_my_role() = 'dueno' AND dueno_id = auth.uid())
    );

-- ==============================================================================
-- POLÍTICAS RLS PARA VENTAS (FILTRAR POR TIENDA)
-- ==============================================================================
DROP POLICY IF EXISTS "Todos pueden ver ventas" ON public.ventas;
DROP POLICY IF EXISTS "Todos pueden crear ventas" ON public.ventas;

CREATE POLICY "Ver ventas de mi tienda"
    ON public.ventas FOR SELECT
    USING (
        public.get_my_role() = 'superadmin'
        OR dueno_id = public.get_my_dueno_id()
    );

CREATE POLICY "Crear ventas en mi tienda"
    ON public.ventas FOR INSERT
    WITH CHECK (
        public.get_my_role() = 'superadmin'
        OR dueno_id = public.get_my_dueno_id()
    );

CREATE POLICY "Actualizar ventas de mi tienda"
    ON public.ventas FOR UPDATE
    USING (
        public.get_my_role() = 'superadmin'
        OR dueno_id = public.get_my_dueno_id()
    );

CREATE POLICY "Eliminar ventas de mi tienda"
    ON public.ventas FOR DELETE
    USING (
        public.get_my_role() = 'superadmin'
        OR (public.get_my_role() = 'dueno' AND dueno_id = auth.uid())
    );

-- ==============================================================================
-- POLÍTICAS RLS PARA GASTOS (FILTRAR POR TIENDA)
-- ==============================================================================
DROP POLICY IF EXISTS "Todos pueden ver gastos" ON public.gastos;
DROP POLICY IF EXISTS "Todos pueden crear gastos" ON public.gastos;
DROP POLICY IF EXISTS "Todos pueden actualizar gastos" ON public.gastos;

CREATE POLICY "Ver gastos de mi tienda"
    ON public.gastos FOR SELECT
    USING (
        public.get_my_role() = 'superadmin'
        OR dueno_id = public.get_my_dueno_id()
    );

CREATE POLICY "Crear gastos en mi tienda"
    ON public.gastos FOR INSERT
    WITH CHECK (
        public.get_my_role() = 'superadmin'
        OR dueno_id = public.get_my_dueno_id()
    );

CREATE POLICY "Actualizar gastos de mi tienda"
    ON public.gastos FOR UPDATE
    USING (
        public.get_my_role() = 'superadmin'
        OR dueno_id = public.get_my_dueno_id()
    );

CREATE POLICY "Eliminar gastos de mi tienda"
    ON public.gastos FOR DELETE
    USING (
        public.get_my_role() = 'superadmin'
        OR (public.get_my_role() = 'dueno' AND dueno_id = auth.uid())
    );

-- ==============================================================================
-- POLÍTICAS RLS PARA AUDITORÍA
-- ==============================================================================
ALTER TABLE public.auditoria ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Ver auditoría según rol"
    ON public.auditoria FOR SELECT
    USING (
        public.get_my_role() = 'superadmin' -- Superadmin ve todo
        OR dueno_id = auth.uid() -- Dueño ve logs de su tienda
    );

CREATE POLICY "Todos pueden insertar en auditoría"
    ON public.auditoria FOR INSERT
    WITH CHECK (true); -- Cualquier usuario autenticado puede crear logs

-- ==============================================================================
-- PASO 9: FUNCIÓN PARA REGISTRAR AUDITORÍA AUTOMÁTICAMENTE
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.registrar_auditoria()
RETURNS TRIGGER AS $$
DECLARE
    v_usuario_nombre TEXT;
    v_dueno_id UUID;
BEGIN
    -- Obtener nombre del usuario actual
    SELECT nombre || ' ' || apellido INTO v_usuario_nombre
    FROM public.usuarios
    WHERE id = auth.uid();
    
    -- Obtener dueno_id del usuario actual
    v_dueno_id := public.get_my_dueno_id();
    
    -- Insertar registro de auditoría
    INSERT INTO public.auditoria (
        accion,
        tabla,
        registro_id,
        usuario_id,
        usuario_nombre,
        dueno_id,
        detalles
    ) VALUES (
        TG_OP, -- INSERT, UPDATE, DELETE
        TG_TABLE_NAME,
        COALESCE(NEW.id, OLD.id),
        auth.uid(),
        v_usuario_nombre,
        v_dueno_id,
        jsonb_build_object(
            'old', to_jsonb(OLD),
            'new', to_jsonb(NEW)
        )
    );
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- PASO 10: TRIGGERS DE AUDITORÍA PARA ACCIONES CRÍTICAS
-- ==============================================================================

-- Auditoría en usuarios (crear, actualizar rol, eliminar)
CREATE TRIGGER auditoria_usuarios
    AFTER INSERT OR UPDATE OR DELETE ON public.usuarios
    FOR EACH ROW
    EXECUTE FUNCTION public.registrar_auditoria();

-- Auditoría en productos (crear, actualizar, eliminar)
CREATE TRIGGER auditoria_productos
    AFTER INSERT OR UPDATE OR DELETE ON public.productos
    FOR EACH ROW
    EXECUTE FUNCTION public.registrar_auditoria();

-- ==============================================================================
-- FINALIZADO
-- ==============================================================================
-- La migración a sistema multitienda está completa.
-- Ahora cada dueño tiene su propia tienda con datos independientes.
-- Los empleados están asociados a un dueño específico.
-- El superadmin puede ver y gestionar todas las tiendas.

-- MarketMove Row Level Security (RLS) Policies
-- Ejecuta este script DESPUÉS de schema.sql

-- ============================================
-- HABILITAR RLS en todas las tablas
-- ============================================
ALTER TABLE public.usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.productos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ventas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gastos ENABLE ROW LEVEL SECURITY;

-- ============================================
-- POLÍTICAS: usuarios
-- ============================================

-- Los usuarios pueden ver su propio perfil
CREATE POLICY "Los usuarios pueden ver su propio perfil"
    ON public.usuarios FOR SELECT
    USING (auth.uid() = id);

-- Los superadmins pueden ver todos los usuarios
CREATE POLICY "Los superadmins pueden ver todos los usuarios"
    ON public.usuarios FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.usuarios
            WHERE id = auth.uid() AND rol = 'superadmin'
        )
    );

-- Los superadmins pueden insertar usuarios
CREATE POLICY "Los superadmins pueden crear usuarios"
    ON public.usuarios FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.usuarios
            WHERE id = auth.uid() AND rol = 'superadmin'
        )
    );

-- Los superadmins pueden actualizar usuarios
CREATE POLICY "Los superadmins pueden actualizar usuarios"
    ON public.usuarios FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.usuarios
            WHERE id = auth.uid() AND rol = 'superadmin'
        )
    );

-- Los usuarios pueden actualizar su propio perfil
CREATE POLICY "Los usuarios pueden actualizar su perfil"
    ON public.usuarios FOR UPDATE
    USING (auth.uid() = id);

-- ============================================
-- POLÍTICAS: categorias
-- ============================================

-- Todos pueden ver las categorías
CREATE POLICY "Todos pueden ver categorías"
    ON public.categorias FOR SELECT
    USING (auth.uid() IS NOT NULL);

-- Solo superadmins y dueños pueden crear categorías
CREATE POLICY "Superadmins y dueños pueden crear categorías"
    ON public.categorias FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.usuarios
            WHERE id = auth.uid() AND rol IN ('superadmin', 'dueno')
        )
    );

-- ============================================
-- POLÍTICAS: productos
-- ============================================

-- Todos los usuarios autenticados pueden ver productos activos
CREATE POLICY "Todos pueden ver productos activos"
    ON public.productos FOR SELECT
    USING (auth.uid() IS NOT NULL AND activo = TRUE);

-- Superadmins y dueños pueden crear productos
CREATE POLICY "Superadmins y dueños pueden crear productos"
    ON public.productos FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.usuarios
            WHERE id = auth.uid() AND rol IN ('superadmin', 'dueno')
        )
    );

-- Superadmins y dueños pueden actualizar productos
CREATE POLICY "Superadmins y dueños pueden actualizar productos"
    ON public.productos FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.usuarios
            WHERE id = auth.uid() AND rol IN ('superadmin', 'dueno')
        )
    );

-- Superadmins y dueños pueden eliminar productos
CREATE POLICY "Superadmins y dueños pueden eliminar productos"
    ON public.productos FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.usuarios
            WHERE id = auth.uid() AND rol IN ('superadmin', 'dueno')
        )
    );

-- ============================================
-- POLÍTICAS: ventas
-- ============================================

-- Todos los usuarios autenticados pueden ver ventas
CREATE POLICY "Todos pueden ver ventas"
    ON public.ventas FOR SELECT
    USING (auth.uid() IS NOT NULL);

-- Todos los usuarios autenticados pueden crear ventas
CREATE POLICY "Todos pueden crear ventas"
    ON public.ventas FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

-- Solo superadmins pueden eliminar ventas
CREATE POLICY "Solo superadmins pueden eliminar ventas"
    ON public.ventas FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.usuarios
            WHERE id = auth.uid() AND rol = 'superadmin'
        )
    );

-- ============================================
-- POLÍTICAS: gastos
-- ============================================

-- Todos los usuarios autenticados pueden ver gastos
CREATE POLICY "Todos pueden ver gastos"
    ON public.gastos FOR SELECT
    USING (auth.uid() IS NOT NULL);

-- Todos los usuarios autenticados pueden crear gastos
CREATE POLICY "Todos pueden crear gastos"
    ON public.gastos FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

-- Los usuarios pueden actualizar sus propios gastos
CREATE POLICY "Los usuarios pueden actualizar sus gastos"
    ON public.gastos FOR UPDATE
    USING (creado_por_id = auth.uid());

-- Superadmins pueden actualizar cualquier gasto
CREATE POLICY "Superadmins pueden actualizar gastos"
    ON public.gastos FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.usuarios
            WHERE id = auth.uid() AND rol = 'superadmin'
        )
    );

-- Los usuarios pueden eliminar sus propios gastos
CREATE POLICY "Los usuarios pueden eliminar sus gastos"
    ON public.gastos FOR DELETE
    USING (creado_por_id = auth.uid());

-- Superadmins pueden eliminar cualquier gasto
CREATE POLICY "Superadmins pueden eliminar gastos"
    ON public.gastos FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.usuarios
            WHERE id = auth.uid() AND rol = 'superadmin'
        )
    );

-- ============================================
-- POLÍTICAS: Storage (bucket imagenes)
-- ============================================

-- Todos pueden ver imágenes
CREATE POLICY "Todos pueden ver imágenes"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'imagenes');

-- Usuarios autenticados pueden subir imágenes
CREATE POLICY "Usuarios autenticados pueden subir imágenes"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'imagenes' AND
        auth.uid() IS NOT NULL
    );

-- Los usuarios pueden eliminar sus propias imágenes
CREATE POLICY "Los usuarios pueden eliminar sus imágenes"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'imagenes' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

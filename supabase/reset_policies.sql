-- ==============================================================================
-- SCRIPT MAESTRO DE REINICIO DE POLÍTICAS (RESET)
-- Ejecuta este script en Supabase para limpiar y regenerar TODA la seguridad.
-- ==============================================================================

-- 1. Función Helper (Seguridad)
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS text AS $$
BEGIN
  RETURN (SELECT rol FROM public.usuarios WHERE id = auth.uid());
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- LIMPIEZA TOTAL (DROP IF EXISTS)
-- ==============================================================================

-- Usuarios
DROP POLICY IF EXISTS "Los usuarios pueden ver su propio perfil" ON public.usuarios;
DROP POLICY IF EXISTS "Los superadmins pueden ver todos los usuarios" ON public.usuarios;
DROP POLICY IF EXISTS "Los superadmins pueden crear usuarios" ON public.usuarios;
DROP POLICY IF EXISTS "Los superadmins pueden actualizar usuarios" ON public.usuarios;
DROP POLICY IF EXISTS "Los usuarios pueden actualizar su perfil" ON public.usuarios;
DROP POLICY IF EXISTS "Permitir registro de usuarios" ON public.usuarios;
DROP POLICY IF EXISTS "Usuarios pueden crear su perfil" ON public.usuarios;

-- Categorías
DROP POLICY IF EXISTS "Todos pueden ver categorías" ON public.categorias;
DROP POLICY IF EXISTS "Superadmins y dueños pueden crear categorías" ON public.categorias;

-- Productos
DROP POLICY IF EXISTS "Todos pueden ver productos activos" ON public.productos;
DROP POLICY IF EXISTS "Superadmins y dueños pueden ver todos los productos" ON public.productos;
DROP POLICY IF EXISTS "Superadmins y dueños pueden crear productos" ON public.productos;
DROP POLICY IF EXISTS "Superadmins y dueños pueden actualizar productos" ON public.productos;
DROP POLICY IF EXISTS "Superadmins y dueños pueden eliminar productos" ON public.productos;

-- Ventas
DROP POLICY IF EXISTS "Todos pueden ver ventas" ON public.ventas;
DROP POLICY IF EXISTS "Todos pueden crear ventas" ON public.ventas;
DROP POLICY IF EXISTS "Solo superadmins pueden eliminar ventas" ON public.ventas;

-- Gastos
DROP POLICY IF EXISTS "Todos pueden ver gastos" ON public.gastos;
DROP POLICY IF EXISTS "Todos pueden crear gastos" ON public.gastos;
DROP POLICY IF EXISTS "Los usuarios pueden actualizar sus gastos" ON public.gastos;
DROP POLICY IF EXISTS "Superadmins pueden actualizar gastos" ON public.gastos;
DROP POLICY IF EXISTS "Los usuarios pueden eliminar sus gastos" ON public.gastos;
DROP POLICY IF EXISTS "Superadmins pueden eliminar gastos" ON public.gastos;

-- Storage
DROP POLICY IF EXISTS "Todos pueden ver imágenes" ON storage.objects;
DROP POLICY IF EXISTS "Usuarios autenticados pueden subir imágenes" ON storage.objects;
DROP POLICY IF EXISTS "Los usuarios pueden eliminar sus imágenes" ON storage.objects;

-- ==============================================================================
-- RECREACIÓN DE POLÍTICAS (FIXED)
-- ==============================================================================

-- ----------------- USUARIOS -----------------
-- Permite ver tu perfil
CREATE POLICY "Los usuarios pueden ver su propio perfil" 
ON public.usuarios FOR SELECT USING (auth.uid() = id);

-- Permite registro (insertar tu propio usuario) O que un superadmin cree usuarios
CREATE POLICY "Permitir registro de usuarios" 
ON public.usuarios FOR INSERT WITH CHECK (
    auth.uid() = id OR public.get_my_role() = 'superadmin'
);

-- Superadmins ven todo
CREATE POLICY "Los superadmins pueden ver todos los usuarios" 
ON public.usuarios FOR SELECT USING (public.get_my_role() = 'superadmin');

-- Superadmins actualizan todo
CREATE POLICY "Los superadmins pueden actualizar usuarios" 
ON public.usuarios FOR UPDATE USING (public.get_my_role() = 'superadmin');

-- Usuarios actualizan su perfil
CREATE POLICY "Los usuarios pueden actualizar su perfil" 
ON public.usuarios FOR UPDATE USING (auth.uid() = id);

-- ----------------- CATEGORÍAS -----------------
CREATE POLICY "Todos pueden ver categorías" 
ON public.categorias FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "Superadmins y dueños pueden crear categorías" 
ON public.categorias FOR INSERT WITH CHECK (public.get_my_role() IN ('superadmin', 'dueno'));

-- ----------------- PRODUCTOS -----------------
CREATE POLICY "Todos pueden ver productos activos" 
ON public.productos FOR SELECT USING (auth.uid() IS NOT NULL AND activo = TRUE);

CREATE POLICY "Superadmins y dueños pueden ver todos los productos" 
ON public.productos FOR SELECT USING (public.get_my_role() IN ('superadmin', 'dueno'));

CREATE POLICY "Superadmins y dueños pueden crear productos" 
ON public.productos FOR INSERT WITH CHECK (public.get_my_role() IN ('superadmin', 'dueno'));

CREATE POLICY "Superadmins y dueños pueden actualizar productos" 
ON public.productos FOR UPDATE USING (public.get_my_role() IN ('superadmin', 'dueno'));

CREATE POLICY "Superadmins y dueños pueden eliminar productos" 
ON public.productos FOR DELETE USING (public.get_my_role() IN ('superadmin', 'dueno'));

-- ----------------- VENTAS -----------------
CREATE POLICY "Todos pueden ver ventas" 
ON public.ventas FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "Todos pueden crear ventas" 
ON public.ventas FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Solo superadmins pueden eliminar ventas" 
ON public.ventas FOR DELETE USING (public.get_my_role() = 'superadmin');

-- ----------------- GASTOS -----------------
CREATE POLICY "Todos pueden ver gastos" 
ON public.gastos FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "Todos pueden crear gastos" 
ON public.gastos FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Los usuarios pueden actualizar sus gastos" 
ON public.gastos FOR UPDATE USING (creado_por_id = auth.uid());

CREATE POLICY "Superadmins pueden actualizar gastos" 
ON public.gastos FOR UPDATE USING (public.get_my_role() = 'superadmin');

CREATE POLICY "Los usuarios pueden eliminar sus gastos" 
ON public.gastos FOR DELETE USING (creado_por_id = auth.uid());

CREATE POLICY "Superadmins pueden eliminar gastos" 
ON public.gastos FOR DELETE USING (public.get_my_role() = 'superadmin');

-- ----------------- STORAGE -----------------
CREATE POLICY "Todos pueden ver imágenes" 
ON storage.objects FOR SELECT USING (bucket_id = 'imagenes');

CREATE POLICY "Usuarios autenticados pueden subir imágenes" 
ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'imagenes' AND auth.uid() IS NOT NULL);

CREATE POLICY "Los usuarios pueden eliminar sus imágenes" 
ON storage.objects FOR DELETE USING (bucket_id = 'imagenes' AND auth.uid()::text = (storage.foldername(name))[1]);

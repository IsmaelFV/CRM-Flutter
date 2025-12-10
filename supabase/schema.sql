-- MarketMove Database Schema
-- Ejecuta este script en el SQL Editor de Supabase

-- ============================================
-- TABLA: usuarios
-- ============================================
CREATE TABLE IF NOT EXISTS public.usuarios (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    telefono TEXT,
    nombre TEXT NOT NULL,
    apellido TEXT NOT NULL,
    rol TEXT NOT NULL DEFAULT 'empleado' CHECK (rol IN ('superadmin', 'dueno', 'empleado')),
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- ============================================
-- TABLA: categorias
-- ============================================
CREATE TABLE IF NOT EXISTS public.categorias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre TEXT NOT NULL UNIQUE,
    descripcion TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- TABLA: productos
-- ============================================
CREATE TABLE IF NOT EXISTS public.productos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre TEXT NOT NULL,
    precio DECIMAL(10, 2) NOT NULL CHECK (precio >= 0),
    stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    codigo_barras TEXT,
    categoria_id UUID REFERENCES public.categorias(id) ON DELETE SET NULL,
    categoria TEXT,
    descripcion TEXT,
    imagen_url TEXT,
    stock_minimo INTEGER DEFAULT 5 CHECK (stock_minimo >= 0),
    creado_por_id UUID NOT NULL REFERENCES public.usuarios(id) ON DELETE CASCADE,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- ============================================
-- TABLA: ventas
-- ============================================
CREATE TABLE IF NOT EXISTS public.ventas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    importe DECIMAL(10, 2) NOT NULL CHECK (importe >= 0),
    fecha TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    producto_id UUID NOT NULL REFERENCES public.productos(id) ON DELETE RESTRICT,
    producto_nombre TEXT,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    metodo_pago TEXT NOT NULL CHECK (metodo_pago IN ('efectivo', 'tarjeta', 'transferencia', 'bizum', 'otro')),
    comentarios TEXT,
    creado_por_id UUID NOT NULL REFERENCES public.usuarios(id) ON DELETE CASCADE,
    creado_por_nombre TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- TABLA: gastos
-- ============================================
CREATE TABLE IF NOT EXISTS public.gastos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    importe DECIMAL(10, 2) NOT NULL CHECK (importe >= 0),
    fecha TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    concepto TEXT NOT NULL,
    cantidad INTEGER,
    metodo_pago TEXT NOT NULL CHECK (metodo_pago IN ('efectivo', 'tarjeta', 'transferencia', 'bizum', 'otro')),
    comentarios TEXT,
    foto_url TEXT,
    categoria_gasto TEXT,
    creado_por_id UUID NOT NULL REFERENCES public.usuarios(id) ON DELETE CASCADE,
    creado_por_nombre TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- ============================================
-- ÍNDICES para mejorar el rendimiento
-- ============================================
CREATE INDEX IF NOT EXISTS idx_usuarios_email ON public.usuarios(email);
CREATE INDEX IF NOT EXISTS idx_usuarios_rol ON public.usuarios(rol);
CREATE INDEX IF NOT EXISTS idx_productos_nombre ON public.productos(nombre);
CREATE INDEX IF NOT EXISTS idx_productos_activo ON public.productos(activo);
CREATE INDEX IF NOT EXISTS idx_productos_stock ON public.productos(stock);
CREATE INDEX IF NOT EXISTS idx_ventas_fecha ON public.ventas(fecha DESC);
CREATE INDEX IF NOT EXISTS idx_ventas_producto ON public.ventas(producto_id);
CREATE INDEX IF NOT EXISTS idx_gastos_fecha ON public.gastos(fecha DESC);

-- ============================================
-- TRIGGERS para updated_at
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_usuarios_updated_at
    BEFORE UPDATE ON public.usuarios
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_productos_updated_at
    BEFORE UPDATE ON public.productos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_gastos_updated_at
    BEFORE UPDATE ON public.gastos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- FUNCIÓN para crear usuario automáticamente
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.usuarios (id, email, nombre, apellido, rol)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'nombre', 'Usuario'),
        COALESCE(NEW.raw_user_meta_data->>'apellido', 'Nuevo'),
        COALESCE(NEW.raw_user_meta_data->>'rol', 'empleado')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para crear usuario automáticamente al registrarse
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- STORAGE: Bucket para imágenes
-- ============================================
-- Ejecuta esto en el SQL Editor o crea el bucket manualmente en Storage
INSERT INTO storage.buckets (id, name, public)
VALUES ('imagenes', 'imagenes', true)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- Datos de ejemplo (opcional)
-- ============================================
-- Categorías de ejemplo
INSERT INTO public.categorias (nombre, descripcion) VALUES
    ('Alimentación', 'Productos alimenticios'),
    ('Bebidas', 'Bebidas y refrescos'),
    ('Limpieza', 'Productos de limpieza'),
    ('Otros', 'Otros productos')
ON CONFLICT (nombre) DO NOTHING;

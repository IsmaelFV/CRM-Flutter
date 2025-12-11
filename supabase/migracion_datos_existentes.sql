-- ==============================================================================
-- MIGRACIÓN DE DATOS EXISTENTES A SISTEMA MULTITIENDA
-- Este script debe ejecutarse DESPUÉS de migracion_multitienda.sql
-- Asigna todos los datos existentes a un dueño por defecto
-- ==============================================================================

-- ==============================================================================
-- PASO 0: DESHABILITAR TRIGGERS DE AUDITORÍA TEMPORALMENTE
-- ==============================================================================
-- Los triggers de auditoría fallan durante la migración porque no hay usuario autenticado
ALTER TABLE public.usuarios DISABLE TRIGGER auditoria_usuarios;
ALTER TABLE public.productos DISABLE TRIGGER auditoria_productos;

-- ==============================================================================
-- PASO 1: IDENTIFICAR O CREAR UN DUEÑO POR DEFECTO
-- ==============================================================================

-- Verificar si ya existe un usuario con rol 'dueno'
DO $$
DECLARE
    v_dueno_id UUID;
    v_dueno_count INTEGER;
BEGIN
    -- Contar cuántos dueños existen
    SELECT COUNT(*) INTO v_dueno_count
    FROM public.usuarios
    WHERE rol = 'dueno';
    
    -- Si no hay ningún dueño, promover al primer usuario a dueño
    IF v_dueno_count = 0 THEN
        -- Buscar el primer usuario (probablemente el que creaste primero)
        SELECT id INTO v_dueno_id
        FROM public.usuarios
        WHERE rol != 'superadmin'
        ORDER BY created_at ASC
        LIMIT 1;
        
        -- Si encontramos un usuario, promoverlo a dueño
        IF v_dueno_id IS NOT NULL THEN
            UPDATE public.usuarios
            SET rol = 'dueno'
            WHERE id = v_dueno_id;
            
            RAISE NOTICE 'Usuario % promovido a dueño', v_dueno_id;
        ELSE
            RAISE NOTICE 'No se encontraron usuarios para promover a dueño';
        END IF;
    ELSE
        RAISE NOTICE 'Ya existe(n) % dueño(s) en el sistema', v_dueno_count;
    END IF;
END $$;

-- ==============================================================================
-- PASO 2: OBTENER EL ID DEL PRIMER DUEÑO
-- ==============================================================================

-- Variable para almacenar el ID del dueño por defecto
DO $$
DECLARE
    v_dueno_default_id UUID;
BEGIN
    -- Obtener el primer dueño (el más antiguo)
    SELECT id INTO v_dueno_default_id
    FROM public.usuarios
    WHERE rol = 'dueno'
    ORDER BY created_at ASC
    LIMIT 1;
    
    -- Verificar que encontramos un dueño
    IF v_dueno_default_id IS NULL THEN
        RAISE EXCEPTION 'No se encontró ningún dueño en el sistema. Crea un usuario con rol dueno primero.';
    END IF;
    
    RAISE NOTICE 'Dueño por defecto seleccionado: %', v_dueno_default_id;
    
    -- ==============================================================================
    -- PASO 3: CREAR TIENDA PARA EL DUEÑO POR DEFECTO
    -- ==============================================================================
    
    -- Insertar tienda si no existe
    INSERT INTO public.tiendas (nombre, dueno_id, activa)
    VALUES ('Tienda Principal', v_dueno_default_id, true)
    ON CONFLICT (dueno_id) DO NOTHING;
    
    RAISE NOTICE 'Tienda creada para el dueño %', v_dueno_default_id;
    
    -- ==============================================================================
    -- PASO 4: ASIGNAR EMPLEADOS AL DUEÑO POR DEFECTO
    -- ==============================================================================
    
    -- Actualizar todos los empleados sin dueño asignado
    UPDATE public.usuarios
    SET dueno_id = v_dueno_default_id
    WHERE rol = 'empleado' AND dueno_id IS NULL;
    
    RAISE NOTICE 'Empleados asignados al dueño por defecto';
    
    -- ==============================================================================
    -- PASO 5: ASIGNAR PRODUCTOS AL DUEÑO POR DEFECTO
    -- ==============================================================================
    
    -- Actualizar todos los productos existentes sin dueño
    UPDATE public.productos
    SET dueno_id = v_dueno_default_id
    WHERE dueno_id IS NULL;
    
    RAISE NOTICE 'Productos asignados al dueño por defecto';
    
    -- ==============================================================================
    -- PASO 6: ASIGNAR VENTAS AL DUEÑO POR DEFECTO
    -- ==============================================================================
    
    -- Actualizar todas las ventas existentes sin dueño
    UPDATE public.ventas
    SET dueno_id = v_dueno_default_id
    WHERE dueno_id IS NULL;
    
    RAISE NOTICE 'Ventas asignadas al dueño por defecto';
    
    -- ==============================================================================
    -- PASO 7: ASIGNAR GASTOS AL DUEÑO POR DEFECTO
    -- ==============================================================================
    
    -- Actualizar todos los gastos existentes sin dueño
    UPDATE public.gastos
    SET dueno_id = v_dueno_default_id
    WHERE dueno_id IS NULL;
    
    RAISE NOTICE 'Gastos asignados al dueño por defecto';
    
    -- ==============================================================================
    -- PASO 8: VERIFICAR MIGRACIÓN
    -- ==============================================================================
    
    -- Mostrar resumen de la migración
    RAISE NOTICE '========================================';
    RAISE NOTICE 'RESUMEN DE MIGRACIÓN';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Dueño por defecto: %', v_dueno_default_id;
    RAISE NOTICE 'Empleados migrados: %', (SELECT COUNT(*) FROM public.usuarios WHERE dueno_id = v_dueno_default_id);
    RAISE NOTICE 'Productos migrados: %', (SELECT COUNT(*) FROM public.productos WHERE dueno_id = v_dueno_default_id);
    RAISE NOTICE 'Ventas migradas: %', (SELECT COUNT(*) FROM public.ventas WHERE dueno_id = v_dueno_default_id);
    RAISE NOTICE 'Gastos migrados: %', (SELECT COUNT(*) FROM public.gastos WHERE dueno_id = v_dueno_default_id);
    RAISE NOTICE '========================================';
END $$;

-- ==============================================================================
-- PASO 9: VERIFICAR QUE NO QUEDEN REGISTROS HUÉRFANOS
-- ==============================================================================

-- Verificar productos sin dueño
DO $$
DECLARE
    v_productos_huerfanos INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_productos_huerfanos
    FROM public.productos
    WHERE dueno_id IS NULL;
    
    IF v_productos_huerfanos > 0 THEN
        RAISE WARNING 'Atención: Hay % productos sin dueño asignado', v_productos_huerfanos;
    END IF;
END $$;

-- Verificar ventas sin dueño
DO $$
DECLARE
    v_ventas_huerfanas INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_ventas_huerfanas
    FROM public.ventas
    WHERE dueno_id IS NULL;
    
    IF v_ventas_huerfanas > 0 THEN
        RAISE WARNING 'Atención: Hay % ventas sin dueño asignado', v_ventas_huerfanas;
    END IF;
END $$;

-- Verificar gastos sin dueño
DO $$
DECLARE
    v_gastos_huerfanos INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_gastos_huerfanos
    FROM public.gastos
    WHERE dueno_id IS NULL;
    
    IF v_gastos_huerfanos > 0 THEN
        RAISE WARNING 'Atención: Hay % gastos sin dueño asignado', v_gastos_huerfanos;
    END IF;
END $$;

-- Verificar empleados sin dueño
DO $$
DECLARE
    v_empleados_huerfanos INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_empleados_huerfanos
    FROM public.usuarios
    WHERE rol = 'empleado' AND dueno_id IS NULL;
    
    IF v_empleados_huerfanos > 0 THEN
        RAISE WARNING 'Atención: Hay % empleados sin dueño asignado', v_empleados_huerfanos;
    END IF;
END $$;

-- ==============================================================================
-- PASO 10: REACTIVAR TRIGGERS DE AUDITORÍA
-- ==============================================================================
ALTER TABLE public.usuarios ENABLE TRIGGER auditoria_usuarios;
ALTER TABLE public.productos ENABLE TRIGGER auditoria_productos;

-- ==============================================================================
-- FINALIZADO
-- ==============================================================================
-- Todos los datos existentes han sido migrados al sistema multitienda.
-- Los triggers de auditoría han sido reactivados.
-- Ahora puedes proceder con la Fase 2: actualizar los modelos Dart.

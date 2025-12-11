-- ==============================================================================
-- FUNCIÓN PARA ELIMINAR USUARIO COMPLETAMENTE
-- Elimina el usuario de auth.users y public.usuarios
-- ==============================================================================

-- Crear función para eliminar usuario (requiere service_role)
CREATE OR REPLACE FUNCTION public.delete_user_completely(user_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  user_rol TEXT;
BEGIN
  -- Obtener el rol del usuario a eliminar
  SELECT rol INTO user_rol FROM public.usuarios WHERE id = user_id;
  
  -- Verificar permisos: solo superadmin o dueño (para empleados)
  IF public.get_my_role() = 'superadmin' THEN
    -- Superadmin puede eliminar a cualquiera
    
    -- Si es dueño, eliminar su tienda primero
    IF user_rol = 'dueno' THEN
      DELETE FROM public.tiendas WHERE dueno_id = user_id;
    END IF;
    
    DELETE FROM auth.users WHERE id = user_id;
    
  ELSIF public.get_my_role() = 'dueno' THEN
    -- Dueño solo puede eliminar empleados
    IF EXISTS (SELECT 1 FROM public.usuarios WHERE id = user_id AND rol = 'empleado') THEN
      DELETE FROM auth.users WHERE id = user_id;
    ELSE
      RAISE EXCEPTION 'No tienes permisos para eliminar este usuario';
    END IF;
  ELSE
    RAISE EXCEPTION 'No tienes permisos para eliminar usuarios';
  END IF;
END;
$$;

-- Dar permisos de ejecución
GRANT EXECUTE ON FUNCTION public.delete_user_completely(UUID) TO authenticated;

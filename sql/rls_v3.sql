-- =========================================================
-- Afinar permisos: separar "Auxiliar de inventario" de "Directivo"
-- Ejecutar DESPUES de rls_v2.sql (lo complementa, no lo reemplaza).
--
-- Regla general (sin cambios): Consulta solo puede leer.
-- Administrador, Auxiliar de inventario y Directivo pueden crear
-- bienes, movimientos, prestamos y levantamientos.
--
-- Dos acciones quedan reservadas a Administrador y Directivo:
--   1) Dar de baja un bien (cambiar su estado a 'baja').
--   2) Verificar un levantamiento de inventario.
-- =========================================================

-- ---------------------------------------------------------
-- 1) bienes: un Auxiliar puede crear/editar un bien y cambiarle
--    el estado a disponible/mantenimiento/danado, pero no darlo
--    de baja. Se usa un trigger (no solo una politica RLS) porque
--    hace falta comparar el estado ANTES y DESPUES del cambio:
--    si el bien ya estaba "de baja" y un Auxiliar solo corrige la
--    descripcion, eso no cuenta como "dar de baja" y se debe
--    permitir igual.
-- ---------------------------------------------------------

CREATE OR REPLACE FUNCTION bienes_validar_baja()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.estado = 'baja' AND OLD.estado IS DISTINCT FROM 'baja' THEN
    IF current_rol_nombre() NOT IN ('Administrador', 'Directivo') THEN
      RAISE EXCEPTION 'Tu rol no tiene permiso para dar de baja un bien.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_bienes_validar_baja ON bienes;
CREATE TRIGGER trg_bienes_validar_baja
  BEFORE UPDATE ON bienes
  FOR EACH ROW
  EXECUTE FUNCTION bienes_validar_baja();

-- Un bien nuevo tambien podria crearse directamente con estado = 'baja'
-- (sin pasar por el trigger de UPDATE, porque es un INSERT). Se refuerza
-- en la politica de creacion:

DROP POLICY IF EXISTS "crear_no_consulta" ON bienes;
CREATE POLICY "crear_bienes" ON bienes FOR INSERT TO authenticated
  WITH CHECK (
    current_rol_nombre() IS DISTINCT FROM 'Consulta'
    AND (estado IS DISTINCT FROM 'baja' OR current_rol_nombre() IN ('Administrador', 'Directivo'))
  );

-- ---------------------------------------------------------
-- 2) levantamientos_inventario: el unico UPDATE que hace el sistema
--    sobre esta tabla es "marcar verificado", asi que restringir todo
--    UPDATE a Administrador/Directivo ya cubre esa regla.
-- ---------------------------------------------------------

DROP POLICY IF EXISTS "editar_no_consulta" ON levantamientos_inventario;
CREATE POLICY "verificar_levantamiento" ON levantamientos_inventario FOR UPDATE TO authenticated
  USING (current_rol_nombre() IN ('Administrador', 'Directivo'))
  WITH CHECK (current_rol_nombre() IN ('Administrador', 'Directivo'));

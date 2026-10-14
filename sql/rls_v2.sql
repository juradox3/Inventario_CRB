-- =========================================================
-- Permisos por rol (reemplaza la regla amplia de rls.sql)
-- Regla: todos los usuarios logueados pueden VER todo.
-- Solo "Consulta" queda sin permiso de crear/editar/eliminar.
-- "usuarios" y "roles" tienen reglas aparte (solo Administrador
-- puede gestionarlos).
-- =========================================================

-- Funcion de apoyo: devuelve el nombre del rol del usuario logueado,
-- comparando su correo (del token de sesion) contra la tabla usuarios.
-- SECURITY DEFINER para poder leer usuarios/roles sin chocar con sus
-- propias politicas RLS.
CREATE OR REPLACE FUNCTION current_rol_nombre()
RETURNS TEXT
LANGUAGE SQL
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT r.nombre
  FROM usuarios u
  JOIN roles r ON r.id = u.rol_id
  WHERE u.correo = (auth.jwt() ->> 'email')
  LIMIT 1;
$$;

-- =========================================================
-- Quitar las politicas amplias anteriores
-- =========================================================

DROP POLICY IF EXISTS "autenticados_acceso_total" ON ubicaciones;
DROP POLICY IF EXISTS "autenticados_acceso_total" ON categorias;
DROP POLICY IF EXISTS "autenticados_acceso_total" ON roles;
DROP POLICY IF EXISTS "autenticados_acceso_total" ON personas;
DROP POLICY IF EXISTS "autenticados_acceso_total" ON usuarios;
DROP POLICY IF EXISTS "autenticados_acceso_total" ON bienes;
DROP POLICY IF EXISTS "autenticados_acceso_total" ON movimientos;
DROP POLICY IF EXISTS "autenticados_acceso_total" ON prestamos;
DROP POLICY IF EXISTS "autenticados_acceso_total" ON levantamientos_inventario;

-- =========================================================
-- Tablas operativas: ubicaciones, categorias, personas, bienes,
-- movimientos, prestamos, levantamientos_inventario
-- Ver: todos. Crear/editar/eliminar: todos menos Consulta.
-- =========================================================

DO $$
DECLARE
  t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY['ubicaciones','categorias','personas','bienes','movimientos','prestamos','levantamientos_inventario']
  LOOP
    EXECUTE format('CREATE POLICY "ver_todos" ON %I FOR SELECT TO authenticated USING (true)', t);
    EXECUTE format('CREATE POLICY "crear_no_consulta" ON %I FOR INSERT TO authenticated WITH CHECK (current_rol_nombre() IS DISTINCT FROM %L)', t, 'Consulta');
    EXECUTE format('CREATE POLICY "editar_no_consulta" ON %I FOR UPDATE TO authenticated USING (current_rol_nombre() IS DISTINCT FROM %L) WITH CHECK (current_rol_nombre() IS DISTINCT FROM %L)', t, 'Consulta', 'Consulta');
    EXECUTE format('CREATE POLICY "eliminar_no_consulta" ON %I FOR DELETE TO authenticated USING (current_rol_nombre() IS DISTINCT FROM %L)', t, 'Consulta');
  END LOOP;
END $$;

-- =========================================================
-- roles: todos pueden verlo (se usa en varios formularios),
-- solo Administrador lo puede modificar.
-- =========================================================

CREATE POLICY "ver_todos" ON roles FOR SELECT TO authenticated USING (true);
CREATE POLICY "solo_admin_escribe" ON roles FOR INSERT TO authenticated WITH CHECK (current_rol_nombre() = 'Administrador');
CREATE POLICY "solo_admin_edita" ON roles FOR UPDATE TO authenticated USING (current_rol_nombre() = 'Administrador') WITH CHECK (current_rol_nombre() = 'Administrador');
CREATE POLICY "solo_admin_elimina" ON roles FOR DELETE TO authenticated USING (current_rol_nombre() = 'Administrador');

-- =========================================================
-- usuarios: visible para todos (se usa para mostrar "quien hizo
-- este movimiento/prestamo" en el historial de cualquier rol).
-- Un usuario nuevo se puede crear su propia fila (auto-registro);
-- solo Administrador puede cambiar roles despues.
-- =========================================================

CREATE POLICY "ver_todos" ON usuarios FOR SELECT TO authenticated USING (true);

CREATE POLICY "crear_propio_o_admin" ON usuarios FOR INSERT TO authenticated
  WITH CHECK (correo = (auth.jwt() ->> 'email') OR current_rol_nombre() = 'Administrador');

CREATE POLICY "solo_admin_edita_usuarios" ON usuarios FOR UPDATE TO authenticated
  USING (current_rol_nombre() = 'Administrador') WITH CHECK (current_rol_nombre() = 'Administrador');

CREATE POLICY "solo_admin_elimina_usuarios" ON usuarios FOR DELETE TO authenticated
  USING (current_rol_nombre() = 'Administrador');

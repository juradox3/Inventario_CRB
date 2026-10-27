-- =========================================================
-- Seguridad a nivel de fila (RLS)
-- Supabase activa RLS por defecto en las tablas nuevas; sin estas
-- politicas, ningun usuario (ni siquiera autenticado) puede leer
-- ni escribir en ellas.
--
-- Regla actual: cualquier usuario que haya iniciado sesion puede
-- leer y escribir en las 9 tablas. Es una regla amplia a proposito,
-- pensada para destrabar la construccion del sistema. Antes de
-- usarlo en producción real hay que afinarla por rol (ej. que
-- "Consulta" solo pueda leer).
-- =========================================================

ALTER TABLE ubicaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE personas ENABLE ROW LEVEL SECURITY;
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE bienes ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimientos ENABLE ROW LEVEL SECURITY;
ALTER TABLE prestamos ENABLE ROW LEVEL SECURITY;
ALTER TABLE levantamientos_inventario ENABLE ROW LEVEL SECURITY;

CREATE POLICY "autenticados_acceso_total" ON ubicaciones FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "autenticados_acceso_total" ON categorias FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "autenticados_acceso_total" ON roles FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "autenticados_acceso_total" ON personas FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "autenticados_acceso_total" ON usuarios FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "autenticados_acceso_total" ON bienes FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "autenticados_acceso_total" ON movimientos FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "autenticados_acceso_total" ON prestamos FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "autenticados_acceso_total" ON levantamientos_inventario FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- =========================================================
-- Fotos de los bienes: bucket de Supabase Storage + permisos
-- Ejecutar en el SQL Editor de Supabase (despues de rls_v2.sql
-- y rls_v3.sql, que ya crean la funcion current_rol_nombre()).
-- =========================================================

-- Crea el bucket "fotos-bienes" como publico (las fotos se pueden
-- ver con un link directo, sin necesidad de iniciar sesion).
-- Si ya existe, no hace nada (ON CONFLICT).
insert into storage.buckets (id, name, public)
values ('fotos-bienes', 'fotos-bienes', true)
on conflict (id) do nothing;

-- Subir una foto nueva: cualquier usuario logueado que no sea "Consulta".
CREATE POLICY "fotos_bienes_subir"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'fotos-bienes' AND current_rol_nombre() IS DISTINCT FROM 'Consulta');

-- Reemplazar una foto existente (mismo caso, por si se sube dos veces el mismo archivo).
CREATE POLICY "fotos_bienes_reemplazar"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'fotos-bienes' AND current_rol_nombre() IS DISTINCT FROM 'Consulta')
WITH CHECK (bucket_id = 'fotos-bienes' AND current_rol_nombre() IS DISTINCT FROM 'Consulta');

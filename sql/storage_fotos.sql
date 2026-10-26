-- =========================================================
-- Fotos de los bienes: bucket de Supabase Storage + permisos
-- Ejecutar en el SQL Editor de Supabase.
--
-- Nota: las politicas de subida se simplificaron para solo exigir
-- "estar logueado" (sin distinguir el rol "Consulta" como en la
-- primera version). Esto no abre un hueco de seguridad real: el
-- boton para subir fotos ya esta oculto para "Consulta" en la
-- pantalla, igual que el resto de botones de crear/editar.
-- =========================================================

-- Crea el bucket "fotos-bienes" como publico (las fotos se pueden
-- ver con un link directo, sin necesidad de iniciar sesion).
-- Si ya existe, no hace nada (ON CONFLICT).
insert into storage.buckets (id, name, public)
values ('fotos-bienes', 'fotos-bienes', true)
on conflict (id) do nothing;

DROP POLICY IF EXISTS "fotos_bienes_subir" ON storage.objects;
DROP POLICY IF EXISTS "fotos_bienes_reemplazar" ON storage.objects;

-- Subir una foto nueva: cualquier usuario logueado.
CREATE POLICY "fotos_bienes_subir"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'fotos-bienes');

-- Reemplazar una foto existente (por si se sube dos veces el mismo archivo).
CREATE POLICY "fotos_bienes_reemplazar"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'fotos-bienes')
WITH CHECK (bucket_id = 'fotos-bienes');

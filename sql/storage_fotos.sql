-- =========================================================
-- Fotos de los bienes: bucket de Supabase Storage + permisos
-- Ejecutar en el SQL Editor de Supabase.
--
-- Historial de ajustes (dejar este rastro ayuda si hay que
-- depurar de nuevo):
-- 1) Politicas de INSERT/UPDATE solamente -> fallaba con
--    "new row violates row-level security policy" incluso con
--    permisos correctos, porque el cliente subia con
--    upsert:true, que internamente necesita poder CONSULTAR
--    (SELECT) si el archivo ya existe. Sin politica de SELECT,
--    esa consulta interna fallaba y el error salia disfrazado
--    de error de insercion.
-- 2) Se agrega la politica de SELECT que faltaba, y ademas en
--    el codigo se quito el upsert:true (no hace falta, cada
--    foto ya se guarda con un nombre unico).
-- =========================================================

-- Crea el bucket "fotos-bienes" como publico (las fotos se pueden
-- ver con un link directo, sin necesidad de iniciar sesion).
-- Si ya existe, no hace nada (ON CONFLICT).
insert into storage.buckets (id, name, public)
values ('fotos-bienes', 'fotos-bienes', true)
on conflict (id) do nothing;

DROP POLICY IF EXISTS "fotos_bienes_subir" ON storage.objects;
DROP POLICY IF EXISTS "fotos_bienes_reemplazar" ON storage.objects;
DROP POLICY IF EXISTS "fotos_bienes_ver" ON storage.objects;

-- Leer/consultar los archivos del bucket (necesario incluso para
-- subir, por el chequeo interno de upsert/duplicados).
CREATE POLICY "fotos_bienes_ver"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'fotos-bienes');

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

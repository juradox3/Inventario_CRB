-- =========================================================
-- Datos de compra: proveedor, quien compro, foto de la factura.
-- Ejecutar en el SQL Editor de Supabase. Usa ADD COLUMN IF NOT EXISTS
-- por si ya se corrio antes.
-- =========================================================

ALTER TABLE bienes ADD COLUMN IF NOT EXISTS proveedor VARCHAR(150);
ALTER TABLE bienes ADD COLUMN IF NOT EXISTS comprado_por VARCHAR(150);
ALTER TABLE bienes ADD COLUMN IF NOT EXISTS factura_foto_url TEXT;

-- Las fotos de factura se guardan en el mismo bucket "fotos-bienes"
-- (carpeta "facturas/"), asi que no hace falta crear otro bucket ni
-- otras politicas: las de sql/storage_fotos.sql ya cubren todo el bucket.

-- ============================================================================
--  Kirolive · Columna para los EXTRAS de cada actividad
-- ----------------------------------------------------------------------------
--  Ejecuta este script en Supabase → SQL Editor (después de los anteriores).
--
--  Al enriquecer una actividad, además del detalle pedimos a Strava el perfil
--  de altimetría (streams) y las zonas de FC/potencia, y los guardamos dentro
--  de `raw` como `kirolive_alt` y `kirolive_zones`.
--
--  `extras` marca que YA intentamos traer esos datos (haya o no), para no
--  volver a pedirlos en cada sincronización. Las actividades ya detalladas de
--  antes quedan con extras=false, así el siguiente backfill las completa.
-- ============================================================================

alter table public.activities
  add column if not exists extras boolean not null default false;

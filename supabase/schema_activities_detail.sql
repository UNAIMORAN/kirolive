-- ============================================================================
--  Kirolive · Columnas extra para el detalle de actividad
-- ----------------------------------------------------------------------------
--  Ejecuta este script en Supabase → SQL Editor (después de schema_strava.sql).
--
--  Las actividades nuevas se sincronizan con el DETALLE completo de Strava.
--  El JSON íntegro se guarda en `raw`; estas columnas son atajos cómodos de
--  los campos más útiles para mostrar y para que la IA los lea fácil.
--
--  `detailed` marca si la fila tiene el detalle completo (true) o solo el
--  resumen (false, las del backfill inicial).
-- ============================================================================

alter table public.activities
  add column if not exists description     text,
  add column if not exists suffer_score    double precision, -- esfuerzo relativo
  add column if not exists average_cadence double precision,
  add column if not exists detailed        boolean not null default false;

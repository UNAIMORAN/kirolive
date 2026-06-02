-- ============================================================================
--  Kirolive · Esquema de base de datos para la integración con Strava
-- ============================================================================
--  Ejecuta este script en Supabase → SQL Editor.
--
--  Crea 3 tablas:
--    1) strava_accounts  -> vincula cada usuario con su cuenta de Strava
--                           y guarda sus tokens OAuth (los escribe la Edge
--                           Function, nunca la app).
--    2) activities       -> caché de las actividades descargadas de Strava.
--    3) insights         -> conclusiones generadas por la IA (tendencias y
--                           recomendaciones).
--
--  Todas tienen RLS (seguridad por fila): cada usuario solo accede a lo suyo.
--  Las Edge Functions usan la "service role key", que se salta RLS para
--  poder sincronizar y escribir en nombre del usuario.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1) Cuentas de Strava vinculadas
-- ----------------------------------------------------------------------------
create table if not exists public.strava_accounts (
  user_id       uuid primary key references auth.users(id) on delete cascade,
  athlete_id    bigint not null,
  username      text,
  firstname     text,
  lastname      text,
  profile       text,                    -- URL del avatar en Strava
  access_token  text not null,           -- token de acceso (caduca)
  refresh_token text not null,           -- token para renovar el acceso
  expires_at    timestamptz not null,    -- cuándo caduca el access_token
  scope         text,                    -- permisos concedidos
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

alter table public.strava_accounts enable row level security;

-- El usuario puede ver/gestionar su propia vinculación.
create policy "cuenta: ver"        on public.strava_accounts for select using (auth.uid() = user_id);
create policy "cuenta: crear"      on public.strava_accounts for insert with check (auth.uid() = user_id);
create policy "cuenta: actualizar" on public.strava_accounts for update using (auth.uid() = user_id);
create policy "cuenta: borrar"     on public.strava_accounts for delete using (auth.uid() = user_id);


-- ----------------------------------------------------------------------------
-- 2) Actividades (caché de lo que devuelve Strava)
-- ----------------------------------------------------------------------------
create table if not exists public.activities (
  id                      bigint primary key,   -- id de la actividad en Strava (único global)
  user_id                 uuid not null references auth.users(id) on delete cascade,
  name                    text,
  sport_type              text,                 -- Run, Ride, Swim, ...
  start_date              timestamptz,
  distance_m              double precision,     -- metros
  moving_time_s           integer,              -- segundos en movimiento
  elapsed_time_s          integer,              -- segundos totales
  total_elevation_gain_m  double precision,     -- desnivel positivo (m)
  average_speed_ms        double precision,     -- m/s
  max_speed_ms            double precision,     -- m/s
  average_heartrate       double precision,     -- ppm
  max_heartrate           double precision,     -- ppm
  average_watts           double precision,     -- potencia media (ciclismo)
  calories                double precision,
  raw                     jsonb,                -- payload completo de Strava por si hace falta
  created_at              timestamptz not null default now()
);

create index if not exists activities_user_date_idx
  on public.activities (user_id, start_date desc);

alter table public.activities enable row level security;

create policy "actividad: ver"        on public.activities for select using (auth.uid() = user_id);
create policy "actividad: crear"      on public.activities for insert with check (auth.uid() = user_id);
create policy "actividad: actualizar" on public.activities for update using (auth.uid() = user_id);
create policy "actividad: borrar"     on public.activities for delete using (auth.uid() = user_id);


-- ----------------------------------------------------------------------------
-- 3) Conclusiones de la IA
-- ----------------------------------------------------------------------------
create table if not exists public.insights (
  id           bigint generated always as identity primary key,
  user_id      uuid not null references auth.users(id) on delete cascade,
  kind         text not null,            -- 'trend' (tendencia) | 'recommendation' (recomendación)
  period_start date,                     -- rango analizado (opcional)
  period_end   date,
  content      text not null,            -- el texto que genera la IA
  model        text,                     -- qué modelo lo generó
  created_at   timestamptz not null default now()
);

create index if not exists insights_user_date_idx
  on public.insights (user_id, created_at desc);

alter table public.insights enable row level security;

create policy "insight: ver"    on public.insights for select using (auth.uid() = user_id);
create policy "insight: crear"  on public.insights for insert with check (auth.uid() = user_id);
create policy "insight: borrar" on public.insights for delete using (auth.uid() = user_id);

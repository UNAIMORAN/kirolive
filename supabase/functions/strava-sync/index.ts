// ============================================================================
//  Edge Function: strava-sync
// ----------------------------------------------------------------------------
//  Descarga las actividades del usuario y las guarda en `activities`.
//
//  Dos modos automáticos:
//    • BACKFILL (primera vez, o si se pide full): trae TODAS las actividades
//      paginando hasta el final. Solo el resumen (rápido y barato).
//    • INCREMENTAL (siguientes veces): trae solo lo NUEVO (parámetro `after`)
//      y, como son pocas, pide el DETALLE completo de cada una (calorías,
//      descripción, splits, esfuerzo, cadencia, vueltas...) más los EXTRAS
//      (altimetría vía streams, zonas de FC/potencia y la meteo del momento
//      vía Open-Meteo) y los guarda en raw como kirolive_alt / kirolive_zones
//      / kirolive_weather.
//
//  Detalle limitado a ENRICH_LIMIT por ejecución para no agotar el límite de
//  Strava (200 req/15 min, 2000/día).
//
//  Llamada por la app con la sesión del usuario → deja "Verify JWT" ACTIVADO.
//  Acepta body opcional { "full": true } para forzar un backfill completo.
//
//  Secrets necesarios: STRAVA_CLIENT_ID, STRAVA_CLIENT_SECRET.
// ============================================================================

import { createClient } from "jsr:@supabase/supabase-js@2";

const STRAVA_CLIENT_ID = Deno.env.get("STRAVA_CLIENT_ID")!;
const STRAVA_CLIENT_SECRET = Deno.env.get("STRAVA_CLIENT_SECRET")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const ENRICH_LIMIT = 40; // máx. de detalles por ejecución
const API = "https://www.strava.com/api/v3";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "content-type": "application/json" },
  });
}

// Reduce los streams de altitud a ~200 puntos [distancia_m, altitud_m] para el
// perfil de altimetría, manteniendo `raw` pequeño. Devuelve null si no hay GPS.
function downsampleAltitude(streams: any): { d: number[]; a: number[] } | null {
  const alt = streams?.altitude?.data;
  const dist = streams?.distance?.data;
  if (!Array.isArray(alt) || alt.length < 2) return null;
  const n = alt.length;
  const step = Math.max(1, Math.floor(n / 200));
  const d: number[] = [];
  const a: number[] = [];
  for (let i = 0; i < n; i += step) {
    a.push(Math.round(alt[i]));
    d.push(Array.isArray(dist) ? Math.round(dist[i]) : i);
  }
  // Asegura incluir el último punto.
  if ((n - 1) % step !== 0) {
    a.push(Math.round(alt[n - 1]));
    d.push(Array.isArray(dist) ? Math.round(dist[n - 1]) : n - 1);
  }
  return { d, a };
}

// Tiempo que hacía en el lugar/momento de la actividad (Open-Meteo, histórico
// de alta resolución; gratis y sin clave). Devuelve null si no hay GPS/fecha o
// si no hay datos para esa hora. Elige la hora UTC de inicio de la actividad.
async function fetchWeather(a: Record<string, any>): Promise<Record<string, any> | null> {
  const ll = a.start_latlng;
  if (!Array.isArray(ll) || ll.length < 2 || !a.start_date) return null;
  const start = new Date(a.start_date);
  if (isNaN(start.getTime())) return null;

  const day = start.toISOString().slice(0, 10); // YYYY-MM-DD (UTC)
  const hourKey = start.toISOString().slice(0, 13); // YYYY-MM-DDTHH (UTC)
  const url = "https://historical-forecast-api.open-meteo.com/v1/forecast" +
    `?latitude=${ll[0]}&longitude=${ll[1]}` +
    `&start_date=${day}&end_date=${day}&timezone=UTC` +
    "&hourly=temperature_2m,relative_humidity_2m,precipitation," +
    "weather_code,wind_speed_10m,wind_direction_10m";

  const r = await fetch(url);
  if (!r.ok) return null;
  const w = await r.json();
  const times: string[] = w?.hourly?.time ?? [];
  if (!Array.isArray(times) || times.length === 0) return null;

  let idx = times.findIndex((t) => t.slice(0, 13) === hourKey);
  if (idx < 0) idx = 0; // si no cuadra la hora exacta, usa la primera
  const h = w.hourly;
  const pick = (arr: any) => (Array.isArray(arr) && arr[idx] != null ? arr[idx] : null);

  return {
    temp: pick(h.temperature_2m),
    humidity: pick(h.relative_humidity_2m),
    precip: pick(h.precipitation),
    wind: pick(h.wind_speed_10m),
    wind_dir: pick(h.wind_direction_10m),
    code: pick(h.weather_code),
  };
}

// Campos de resumen (los que vienen en la lista de actividades).
function summaryRow(userId: string, a: Record<string, any>) {
  return {
    id: a.id,
    user_id: userId,
    name: a.name,
    sport_type: a.sport_type ?? a.type,
    start_date: a.start_date,
    distance_m: a.distance,
    moving_time_s: a.moving_time,
    elapsed_time_s: a.elapsed_time,
    total_elevation_gain_m: a.total_elevation_gain,
    average_speed_ms: a.average_speed,
    max_speed_ms: a.max_speed,
    average_heartrate: a.average_heartrate ?? null,
    max_heartrate: a.max_heartrate ?? null,
    average_watts: a.average_watts ?? null,
    raw: a,
    // OJO: no incluimos calories/description/etc. para no pisar el detalle ya
    // guardado de una actividad en futuras sincronizaciones de resumen.
  };
}

// Detalle completo (incluye lo del resumen + extras).
function detailRow(userId: string, a: Record<string, any>) {
  return {
    ...summaryRow(userId, a),
    calories: a.calories ?? null,
    description: a.description ?? null,
    suffer_score: a.suffer_score ?? null,
    average_cadence: a.average_cadence ?? null,
    detailed: true,
    extras: true, // ya intentamos traer altimetría + zonas (haya datos o no)
    raw: a, // JSON de detalle íntegro (+ kirolive_alt / kirolive_zones)
  };
}

async function refreshIfNeeded(admin: any, acc: any): Promise<string | null> {
  if (new Date(acc.expires_at).getTime() >= Date.now() + 60_000) {
    return acc.access_token;
  }
  const r = await fetch("https://www.strava.com/oauth/token", {
    method: "POST",
    headers: { "content-type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: STRAVA_CLIENT_ID,
      client_secret: STRAVA_CLIENT_SECRET,
      grant_type: "refresh_token",
      refresh_token: acc.refresh_token,
    }),
  });
  if (!r.ok) return null;
  const nt = await r.json();
  await admin
    .from("strava_accounts")
    .update({
      access_token: nt.access_token,
      refresh_token: nt.refresh_token,
      expires_at: new Date(nt.expires_at * 1000).toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq("user_id", acc.user_id);
  return nt.access_token;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });

  const admin = createClient(SUPABASE_URL, SERVICE_ROLE);

  // Usuario por su JWT.
  const jwt = (req.headers.get("Authorization") ?? "").replace("Bearer ", "");
  const { data: userData, error: userErr } = await admin.auth.getUser(jwt);
  if (userErr || !userData.user) return json({ error: "no_auth" }, 401);
  const userId = userData.user.id;

  // Cuenta de Strava + token válido.
  const { data: acc } = await admin
    .from("strava_accounts")
    .select("*")
    .eq("user_id", userId)
    .maybeSingle();
  if (!acc) return json({ error: "not_connected" }, 400);

  const accessToken = await refreshIfNeeded(admin, acc);
  if (!accessToken) return json({ error: "refresh_failed" }, 502);

  // ¿Backfill o incremental?
  let full = false;
  if (req.method === "POST") {
    const body = await req.json().catch(() => null);
    if (body && body.full === true) full = true;
  }
  const { data: latest } = await admin
    .from("activities")
    .select("start_date")
    .eq("user_id", userId)
    .order("start_date", { ascending: false })
    .limit(1)
    .maybeSingle();

  const isBackfill = full || !latest;

  // Parámetro `after` para el incremental (un poco antes del último que tenemos).
  let after: number | undefined;
  if (!isBackfill && latest) {
    after = Math.floor(new Date(latest.start_date).getTime() / 1000) - 2;
  }

  // Descargamos los resúmenes (paginando).
  const summaries: Record<string, any>[] = [];
  for (let page = 1; page <= 50; page++) {
    let url = `${API}/athlete/activities?per_page=200&page=${page}`;
    if (after) url += `&after=${after}`;
    const res = await fetch(url, { headers: { Authorization: `Bearer ${accessToken}` } });
    if (!res.ok) return json({ error: `strava_${res.status}` }, 502);
    const acts = await res.json();
    if (!Array.isArray(acts) || acts.length === 0) break;
    summaries.push(...acts);
    if (acts.length < 200) break;
  }

  // Guardamos los resúmenes.
  if (summaries.length > 0) {
    const { error } = await admin
      .from("activities")
      .upsert(summaries.map((a) => summaryRow(userId, a)));
    if (error) return json({ error: "db_save_failed", detail: error.message }, 500);
  }

  // ¿Qué actividades enriquecemos con su detalle completo?
  //   • Incremental: las nuevas que acabamos de traer.
  //   • Backfill (re-sincronizar todo): un lote de las que aún no tienen
  //     detalle, empezando por las más recientes (así, pulsando varias veces,
  //     se va completando todo el historial sin pasarse del límite de Strava).
  let toEnrichIds: number[];
  if (isBackfill) {
    const { data: pending } = await admin
      .from("activities")
      .select("id")
      .eq("user_id", userId)
      .or("detailed.eq.false,extras.eq.false") // falta detalle O faltan los extras
      .order("start_date", { ascending: false })
      .limit(ENRICH_LIMIT);
    toEnrichIds = (pending ?? []).map((r: any) => r.id);
  } else {
    toEnrichIds = summaries.slice(0, ENRICH_LIMIT).map((a) => a.id);
  }

  let enriched = 0;
  for (const id of toEnrichIds) {
    const res = await fetch(`${API}/activities/${id}?include_all_efforts=false`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    if (res.status === 429) break; // límite de Strava: paramos por hoy
    if (!res.ok) continue;
    const detail = await res.json();

    // Extras (no bloquean si fallan): perfil de altimetría + zonas FC/potencia.
    const altRes = await fetch(
      `${API}/activities/${id}/streams?keys=altitude,distance&key_by_type=true`,
      { headers: { Authorization: `Bearer ${accessToken}` } },
    );
    if (altRes.status === 429) break;
    if (altRes.ok) {
      const alt = downsampleAltitude(await altRes.json());
      if (alt) detail.kirolive_alt = alt;
    }

    const zRes = await fetch(`${API}/activities/${id}/zones`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    if (zRes.status === 429) break;
    if (zRes.ok) {
      const zones = await zRes.json();
      if (Array.isArray(zones) && zones.length > 0) detail.kirolive_zones = zones;
    }

    // Meteo (API externa, opcional): no rompe el enriquecimiento si falla.
    try {
      const weather = await fetchWeather(detail);
      if (weather) detail.kirolive_weather = weather;
    } catch (_) { /* clima no disponible */ }

    const { error } = await admin.from("activities").upsert(detailRow(userId, detail));
    if (!error) enriched++;
  }

  // Cuántas quedan sin detalle, para que la app pueda avisar.
  const { count: remaining } = await admin
    .from("activities")
    .select("id", { count: "exact", head: true })
    .eq("user_id", userId)
    .eq("detailed", false);

  return json({
    mode: isBackfill ? "backfill" : "incremental",
    synced: summaries.length,
    enriched,
    remaining: remaining ?? 0,
  });
});

// ============================================================================
//  Edge Function: strava-callback
// ----------------------------------------------------------------------------
//  Es la URL a la que Strava redirige tras el login (el "redirect_uri").
//  Recibe el ?code= de Strava, lo canjea por los tokens usando el CLIENT_SECRET
//  (que vive aquí, nunca en la app), y guarda la cuenta en `strava_accounts`.
//  Luego devuelve al usuario a la app.
//
//  El usuario se identifica con el parámetro `state`, que la app rellena con:
//      base64( JSON.stringify({ jwt, ret }) )
//    - jwt: el access_token de Supabase del usuario que está logueado.
//    - ret: a dónde volver tras conectar (URL de la web o deep link de la app).
//
//  IMPORTANTE al desplegar: desactiva "Verify JWT" en esta función, porque
//  Strava la llama sin cabecera Authorization.
//
//  Secrets necesarios (Edge Functions → Secrets):
//    - STRAVA_CLIENT_ID
//    - STRAVA_CLIENT_SECRET
//  (SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY los inyecta Supabase solo.)
// ============================================================================

import { createClient } from "jsr:@supabase/supabase-js@2";

const STRAVA_CLIENT_ID = Deno.env.get("STRAVA_CLIENT_ID")!;
const STRAVA_CLIENT_SECRET = Deno.env.get("STRAVA_CLIENT_SECRET")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

// Devuelve al usuario a `ret` (web o deep link), añadiendo ?strava=ok|error.
function backTo(ret: string, status: "ok" | "error", detail?: string): Response {
  const sep = ret.includes("?") ? "&" : "?";
  let location = `${ret}${sep}strava=${status}`;
  if (detail) location += `&detail=${encodeURIComponent(detail)}`;
  return new Response(null, { status: 302, headers: { Location: location } });
}

// Página simple por si algo va mal antes de saber a dónde volver.
function errorPage(msg: string): Response {
  return new Response(
    `<html><body style="font-family:sans-serif;padding:2rem">
       <h2>No se pudo conectar con Strava</h2><p>${msg}</p>
       <p>Puedes cerrar esta ventana y volver a la app.</p>
     </body></html>`,
    { status: 400, headers: { "content-type": "text/html; charset=utf-8" } },
  );
}

Deno.serve(async (req) => {
  const url = new URL(req.url);
  const code = url.searchParams.get("code");
  const stateRaw = url.searchParams.get("state");
  const oauthError = url.searchParams.get("error"); // p.ej. "access_denied"
  const scope = url.searchParams.get("scope") ?? "";

  // Decodifica el state para saber a dónde volver y quién es el usuario.
  let jwt = "";
  let ret = "";
  try {
    const decoded = JSON.parse(atob(stateRaw ?? ""));
    jwt = decoded.jwt ?? "";
    ret = decoded.ret ?? "";
  } catch {
    return errorPage("Parámetro 'state' inválido.");
  }
  if (!ret) return errorPage("Falta la URL de retorno.");

  // El usuario canceló en la pantalla de Strava.
  if (oauthError) return backTo(ret, "error", oauthError);
  if (!code) return backTo(ret, "error", "missing_code");

  const admin = createClient(SUPABASE_URL, SERVICE_ROLE);

  // 1) Verifica el JWT de Supabase → averigua qué usuario es.
  const { data: userData, error: userErr } = await admin.auth.getUser(jwt);
  if (userErr || !userData.user) return backTo(ret, "error", "invalid_session");
  const userId = userData.user.id;

  // 2) Canjea el code por los tokens de Strava.
  const tokenRes = await fetch("https://www.strava.com/oauth/token", {
    method: "POST",
    headers: { "content-type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: STRAVA_CLIENT_ID,
      client_secret: STRAVA_CLIENT_SECRET,
      code,
      grant_type: "authorization_code",
    }),
  });

  if (!tokenRes.ok) {
    return backTo(ret, "error", `strava_token_${tokenRes.status}`);
  }
  const t = await tokenRes.json();
  const athlete = t.athlete ?? {};

  // 3) Guarda (o actualiza) la cuenta de Strava de este usuario.
  const { error: upsertErr } = await admin.from("strava_accounts").upsert({
    user_id: userId,
    athlete_id: athlete.id,
    username: athlete.username ?? null,
    firstname: athlete.firstname ?? null,
    lastname: athlete.lastname ?? null,
    profile: athlete.profile ?? null,
    access_token: t.access_token,
    refresh_token: t.refresh_token,
    expires_at: new Date(t.expires_at * 1000).toISOString(),
    scope,
    updated_at: new Date().toISOString(),
  });

  if (upsertErr) return backTo(ret, "error", "db_save_failed");

  // 4) Vuelve a la app.
  return backTo(ret, "ok");
});

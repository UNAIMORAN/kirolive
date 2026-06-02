// PLANTILLA de credenciales de Supabase.
//
// Este archivo SÍ se sube a git como ejemplo. El archivo real con tus claves
// (lib/supabase_config.dart) está en .gitignore y NO se sube.
//
// Para configurar el proyecto tras clonarlo:
//   1. Copia este archivo y renómbralo a "supabase_config.dart".
//   2. Entra a https://supabase.com -> tu proyecto -> Project Settings -> API.
//   3. Pega tu Project URL y tu Publishable key (sb_publishable_...) abajo.
//
// Importante: usa SIEMPRE la clave pública (sb_publishable_...), nunca la
// secreta (sb_secret_...), en una app cliente.
const String supabaseUrl = 'https://TU-PROYECTO.supabase.co';
const String supabaseAnonKey = 'TU-CLAVE-sb_publishable_...';

// --- Strava (estos valores NO son secretos, pueden ir en la app) ---
// Client ID de tu aplicación en https://www.strava.com/settings/api
const String stravaClientId = 'TU-CLIENT-ID';
// URL de la Edge Function que recibe el callback de Strava.
const String stravaCallbackUrl =
    'https://TU-PROYECTO.supabase.co/functions/v1/strava-callback';

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTagline => 'Deporte en vivo · progreso real';

  @override
  String get language => 'Idioma';

  @override
  String get email => 'Email';

  @override
  String get password => 'Contraseña';

  @override
  String get signIn => 'Entrar';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get orWord => 'o';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get checkEmailConfirm => 'Revisa tu correo para confirmar la cuenta.';

  @override
  String get errorUnexpected => 'Ocurrió un error inesperado.';

  @override
  String get errorGoogleSignIn => 'No se pudo iniciar sesión con Google.';

  @override
  String get searchWorkoutsHint => 'Buscar entrenos…';

  @override
  String get stravaConnected => 'Strava conectado.';

  @override
  String stravaConnectError(String detail) {
    return 'No se pudo conectar Strava ($detail).';
  }

  @override
  String get stravaConnectStartFailed =>
      'No se pudo iniciar la conexión con Strava.';

  @override
  String get menuDisconnectStrava => 'Desvincular Strava';

  @override
  String get menuLogout => 'Cerrar sesión';

  @override
  String get headlineConnectTitle => 'Conecta para empezar';

  @override
  String get headlineConnectBody =>
      'Vincula tu cuenta de Strava para que tu entrenador empiece a analizar tus entrenamientos. Solo leemos tus actividades.';

  @override
  String get connectStrava => 'Conectar con Strava';

  @override
  String get headlineSyncTitle => 'Sincroniza tus entrenos';

  @override
  String get headlineSyncBody =>
      'Aún no has descargado tus actividades. Sincronízalas para que tu entrenador pueda analizarlas.';

  @override
  String get goSync => 'Ir a sincronizar';

  @override
  String get headlineProgressTitle => 'Vas en progreso';

  @override
  String headlineProgressBody(int pct) {
    return 'Tu volumen este mes sube un $pct% respecto al anterior. Buen ritmo.';
  }

  @override
  String get headlineEasierTitle => 'Semana más suave';

  @override
  String headlineEasierBody(int pct) {
    return 'Tu volumen baja un $pct% respecto al mes pasado. Puede ser descarga o descanso.';
  }

  @override
  String get headlineStableTitle => 'Te mantienes estable';

  @override
  String get headlineStableBody =>
      'Tu volumen es similar al del mes pasado. Constancia.';

  @override
  String get headlineBaseTitle => 'Construyendo tu base';

  @override
  String get headlineBaseBody =>
      'Sigue registrando entrenamientos para ver tu progresión mes a mes.';

  @override
  String get lastWorkout => 'Último entreno';

  @override
  String get activities => 'Actividades';

  @override
  String get syncYourWorkouts => 'Sincroniza tus entrenamientos';

  @override
  String activitiesSynced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sincronizadas',
      one: '1 sincronizada',
    );
    return '$_temp0';
  }

  @override
  String get statDistance => 'Distancia';

  @override
  String get statTime => 'Tiempo';

  @override
  String get statPace => 'Ritmo';

  @override
  String get statSpeed => 'Velocidad';

  @override
  String get activityFallback => 'Actividad';

  @override
  String get searchHintFull => 'Buscar: nombre, deporte, lugar, mes…';

  @override
  String noResults(String query) {
    return 'Sin resultados para \"$query\".';
  }

  @override
  String get summaryActivitiesLabel => 'actividades';

  @override
  String get summaryTotalDistance => 'distancia total';

  @override
  String get syncNow => 'Sincronizar ahora';

  @override
  String get emptyActivities =>
      'Aún no hay actividades.\nSincroniza para descargarlas de Strava.';

  @override
  String get resyncAll => 'Re-sincronizar todo';

  @override
  String get resyncAllSubtitle => 'Recarga y completa el detalle del historial';

  @override
  String get syncingWithStrava => 'Sincronizando con Strava…';

  @override
  String get loadActivitiesFailed => 'No se pudieron cargar las actividades.';

  @override
  String get preparingData => 'Preparando tus datos…';

  @override
  String get syncUpToDate => 'Ya estás al día.';

  @override
  String syncDetailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count con detalle',
      one: '1 con detalle',
    );
    return '$_temp0';
  }

  @override
  String syncRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'quedan $count por enriquecer',
      one: 'queda 1 por enriquecer',
    );
    return '$_temp0';
  }

  @override
  String get detailTitle => 'Detalle';

  @override
  String get sectionElevationProfile => 'Perfil de altimetría';

  @override
  String get sectionWeather => 'Meteo';

  @override
  String get sectionSplits => 'Parciales por km';

  @override
  String get sectionZones => 'Tiempo en zonas';

  @override
  String get metricDistance => 'Distancia';

  @override
  String get metricMovingTime => 'Tiempo en movimiento';

  @override
  String get metricTotalTime => 'Tiempo total';

  @override
  String get metricAvgPace => 'Ritmo medio';

  @override
  String get metricAvgSpeed => 'Velocidad media';

  @override
  String get metricMaxPace => 'Ritmo máx';

  @override
  String get metricMaxSpeed => 'Velocidad máx';

  @override
  String get metricElevGain => 'Desnivel positivo';

  @override
  String get metricMaxAlt => 'Altitud máx';

  @override
  String get metricMinAlt => 'Altitud mín';

  @override
  String get metricAvgHr => 'FC media';

  @override
  String get metricMaxHr => 'FC máxima';

  @override
  String get metricAvgPower => 'Potencia media';

  @override
  String get metricNormPower => 'Potencia normalizada';

  @override
  String get metricMaxPower => 'Potencia máx';

  @override
  String get metricWork => 'Trabajo';

  @override
  String get metricCalories => 'Calorías';

  @override
  String get metricCadence => 'Cadencia';

  @override
  String get metricEffort => 'Esfuerzo';

  @override
  String get metricTemperature => 'Temperatura';

  @override
  String get metricDevice => 'Dispositivo';

  @override
  String get metricGear => 'Material';

  @override
  String get metricElevation => 'Desnivel';

  @override
  String get comparison => 'Comparativa';

  @override
  String get periodWeek => 'Semana';

  @override
  String get periodMonth => 'Mes';

  @override
  String get evolution => 'Evolución';

  @override
  String get noPreviousData => 'sin datos previos';

  @override
  String get vsPrevWeek => 'vs sem. ant.';

  @override
  String get vsPrevMonth => 'vs mes ant.';

  @override
  String get sportAll => 'Todos';

  @override
  String get sportRun => 'Carrera';

  @override
  String get sportTrail => 'Trail';

  @override
  String get sportRide => 'Ciclismo';

  @override
  String get sportSwim => 'Natación';

  @override
  String get sportWalk => 'Caminata';

  @override
  String get sportHike => 'Senderismo';

  @override
  String get sportWorkout => 'Entrenamiento';

  @override
  String get comparatorTitle => 'Comparador';

  @override
  String get tabHeadToHead => 'Cara a cara';

  @override
  String get tabSameRoute => 'Mismo recorrido';

  @override
  String get tabPeriods => 'Periodos';

  @override
  String get pickTwoHint =>
      'Elige dos actividades para compararlas en todas sus métricas.';

  @override
  String get pickActivity => 'Elegir actividad';

  @override
  String get routesEmpty =>
      'Aún no detectamos rutas repetidas.\nNecesitamos al menos 2 salidas con el mismo inicio, fin y distancia.';

  @override
  String routeOutings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count salidas',
      one: '1 salida',
    );
    return '$_temp0';
  }

  @override
  String routeBest(String time) {
    return 'mejor $time';
  }

  @override
  String get routeTitle => 'Recorrido';

  @override
  String get statBest => 'Mejor';

  @override
  String get statAvg => 'Media';

  @override
  String get statImprovement => 'Mejora';

  @override
  String get yourAttempts => 'Tus intentos (por tiempo)';

  @override
  String get record => 'récord';

  @override
  String get periodThisWeek => 'Esta semana';

  @override
  String get periodPrevWeek => 'Semana ant.';

  @override
  String get periodThisMonth => 'Este mes';

  @override
  String get periodPrevMonth => 'Mes ant.';

  @override
  String get periodLast30 => 'Últimos 30d';

  @override
  String get periodPrev30 => '30d previos';

  @override
  String get seg30d => '30 días';

  @override
  String get segYear => 'Año';

  @override
  String get kudos => 'Kudos';

  @override
  String get weatherClear => 'Despejado';

  @override
  String get weatherMostlyClear => 'Mayormente despejado';

  @override
  String get weatherPartlyCloudy => 'Parcialmente nublado';

  @override
  String get weatherCloudy => 'Nublado';

  @override
  String get weatherFog => 'Niebla';

  @override
  String get weatherDrizzle => 'Llovizna';

  @override
  String get weatherFreezingDrizzle => 'Llovizna helada';

  @override
  String get weatherRain => 'Lluvia';

  @override
  String get weatherFreezingRain => 'Lluvia helada';

  @override
  String get weatherSnow => 'Nieve';

  @override
  String get weatherShowers => 'Chubascos';

  @override
  String get weatherSnowShowers => 'Chubascos de nieve';

  @override
  String get weatherThunderstorm => 'Tormenta';

  @override
  String get weatherThunderstormHail => 'Tormenta con granizo';

  @override
  String get weatherUnknown => 'Meteo';

  @override
  String get compassDirs => 'N,NE,E,SE,S,SO,O,NO';

  @override
  String get zonesHr => 'Zonas de frecuencia cardiaca';

  @override
  String get zonesPower => 'Zonas de potencia';

  @override
  String get zonesGeneric => 'Zonas';

  @override
  String get mapboxTokenHint =>
      'Añade un token de Mapbox (lib/env.dart) para ver el mapa';
}

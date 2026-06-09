import '../strava/format.dart';
import '../strava/stats.dart';
import 'app_localizations.dart';

/// Helpers que traducen valores de la "capa de datos" (deportes, métricas) a
/// texto del idioma activo. Se mantienen aquí para no acoplar la lógica
/// (format.dart / stats.dart / compare.dart) a las traducciones.

/// Nombre localizado del deporte a partir del `sport_type` de Strava.
String sportName(AppLocalizations l, String? type) {
  switch (Fmt.sportKey(type)) {
    case 'run':
      return l.sportRun;
    case 'trail':
      return l.sportTrail;
    case 'ride':
      return l.sportRide;
    case 'swim':
      return l.sportSwim;
    case 'walk':
      return l.sportWalk;
    case 'hike':
      return l.sportHike;
    case 'workout':
      return l.sportWorkout;
    default:
      return type ?? l.activityFallback;
  }
}

/// Etiqueta localizada de una métrica de evolución (dashboard).
String metricLabel(AppLocalizations l, Metric m) {
  switch (m) {
    case Metric.distance:
      return l.statDistance;
    case Metric.time:
      return l.statTime;
    case Metric.elevation:
      return l.metricElevation;
    case Metric.heartrate:
      return l.metricAvgHr;
  }
}

/// Etiqueta localizada de una métrica del comparador (clave en compare.dart).
String compareMetricLabel(AppLocalizations l, String key) {
  switch (key) {
    case 'metricDistance':
      return l.metricDistance;
    case 'metricMovingTime':
      return l.metricMovingTime;
    case 'metricTotalTime':
      return l.metricTotalTime;
    case 'metricAvgSpeed':
      return l.metricAvgSpeed;
    case 'metricMaxSpeed':
      return l.metricMaxSpeed;
    case 'metricElevation':
      return l.metricElevation;
    case 'metricAvgHr':
      return l.metricAvgHr;
    case 'metricMaxHr':
      return l.metricMaxHr;
    case 'metricAvgPower':
      return l.metricAvgPower;
    case 'metricCadence':
      return l.metricCadence;
    case 'metricCalories':
      return l.metricCalories;
    case 'metricEffort':
      return l.metricEffort;
    case 'metricTemperature':
      return l.metricTemperature;
    case 'kudos':
      return l.kudos;
    default:
      return key;
  }
}

/// Condición meteorológica localizada a partir del código WMO de Open-Meteo.
String weatherLabel(AppLocalizations l, int? code) {
  switch (code) {
    case 0:
      return l.weatherClear;
    case 1:
      return l.weatherMostlyClear;
    case 2:
      return l.weatherPartlyCloudy;
    case 3:
      return l.weatherCloudy;
    case 45:
    case 48:
      return l.weatherFog;
    case 51:
    case 53:
    case 55:
      return l.weatherDrizzle;
    case 56:
    case 57:
      return l.weatherFreezingDrizzle;
    case 61:
    case 63:
    case 65:
      return l.weatherRain;
    case 66:
    case 67:
      return l.weatherFreezingRain;
    case 71:
    case 73:
    case 75:
    case 77:
      return l.weatherSnow;
    case 80:
    case 81:
    case 82:
      return l.weatherShowers;
    case 85:
    case 86:
      return l.weatherSnowShowers;
    case 95:
      return l.weatherThunderstorm;
    case 96:
    case 99:
      return l.weatherThunderstormHail;
    default:
      return l.weatherUnknown;
  }
}

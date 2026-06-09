// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTagline => 'Live sport · real progress';

  @override
  String get language => 'Language';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get orWord => 'or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get checkEmailConfirm => 'Check your email to confirm your account.';

  @override
  String get errorUnexpected => 'An unexpected error occurred.';

  @override
  String get errorGoogleSignIn => 'Couldn\'t sign in with Google.';

  @override
  String get searchWorkoutsHint => 'Search workouts…';

  @override
  String get stravaConnected => 'Strava connected.';

  @override
  String stravaConnectError(String detail) {
    return 'Couldn\'t connect Strava ($detail).';
  }

  @override
  String get stravaConnectStartFailed =>
      'Couldn\'t start the Strava connection.';

  @override
  String get menuDisconnectStrava => 'Disconnect Strava';

  @override
  String get menuLogout => 'Log out';

  @override
  String get headlineConnectTitle => 'Connect to get started';

  @override
  String get headlineConnectBody =>
      'Link your Strava account so your coach can start analysing your workouts. We only read your activities.';

  @override
  String get connectStrava => 'Connect with Strava';

  @override
  String get headlineSyncTitle => 'Sync your workouts';

  @override
  String get headlineSyncBody =>
      'You haven\'t downloaded your activities yet. Sync them so your coach can analyse them.';

  @override
  String get goSync => 'Go to sync';

  @override
  String get headlineProgressTitle => 'You\'re making progress';

  @override
  String headlineProgressBody(int pct) {
    return 'Your volume this month is up $pct% from last month. Good pace.';
  }

  @override
  String get headlineEasierTitle => 'An easier week';

  @override
  String headlineEasierBody(int pct) {
    return 'Your volume is down $pct% from last month. It may be a taper or rest.';
  }

  @override
  String get headlineStableTitle => 'You\'re staying steady';

  @override
  String get headlineStableBody =>
      'Your volume is similar to last month. Consistency.';

  @override
  String get headlineBaseTitle => 'Building your base';

  @override
  String get headlineBaseBody =>
      'Keep logging workouts to see your month-over-month progression.';

  @override
  String get lastWorkout => 'Latest workout';

  @override
  String get activities => 'Activities';

  @override
  String get syncYourWorkouts => 'Sync your workouts';

  @override
  String activitiesSynced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count synced',
      one: '1 synced',
    );
    return '$_temp0';
  }

  @override
  String get statDistance => 'Distance';

  @override
  String get statTime => 'Time';

  @override
  String get statPace => 'Pace';

  @override
  String get statSpeed => 'Speed';

  @override
  String get activityFallback => 'Activity';

  @override
  String get searchHintFull => 'Search: name, sport, place, month…';

  @override
  String noResults(String query) {
    return 'No results for \"$query\".';
  }

  @override
  String get summaryActivitiesLabel => 'activities';

  @override
  String get summaryTotalDistance => 'total distance';

  @override
  String get syncNow => 'Sync now';

  @override
  String get emptyActivities =>
      'No activities yet.\nSync to download them from Strava.';

  @override
  String get resyncAll => 'Re-sync everything';

  @override
  String get resyncAllSubtitle => 'Reload and complete the history detail';

  @override
  String get syncingWithStrava => 'Syncing with Strava…';

  @override
  String get loadActivitiesFailed => 'Couldn\'t load activities.';

  @override
  String get preparingData => 'Preparing your data…';

  @override
  String get syncUpToDate => 'You\'re all caught up.';

  @override
  String syncDetailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count with detail',
      one: '1 with detail',
    );
    return '$_temp0';
  }

  @override
  String syncRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count left to enrich',
      one: '1 left to enrich',
    );
    return '$_temp0';
  }

  @override
  String get detailTitle => 'Detail';

  @override
  String get sectionElevationProfile => 'Elevation profile';

  @override
  String get sectionWeather => 'Weather';

  @override
  String get sectionSplits => 'Splits per km';

  @override
  String get sectionZones => 'Time in zones';

  @override
  String get metricDistance => 'Distance';

  @override
  String get metricMovingTime => 'Moving time';

  @override
  String get metricTotalTime => 'Total time';

  @override
  String get metricAvgPace => 'Avg pace';

  @override
  String get metricAvgSpeed => 'Avg speed';

  @override
  String get metricMaxPace => 'Max pace';

  @override
  String get metricMaxSpeed => 'Max speed';

  @override
  String get metricElevGain => 'Elevation gain';

  @override
  String get metricMaxAlt => 'Max altitude';

  @override
  String get metricMinAlt => 'Min altitude';

  @override
  String get metricAvgHr => 'Avg HR';

  @override
  String get metricMaxHr => 'Max HR';

  @override
  String get metricAvgPower => 'Avg power';

  @override
  String get metricNormPower => 'Normalized power';

  @override
  String get metricMaxPower => 'Max power';

  @override
  String get metricWork => 'Work';

  @override
  String get metricCalories => 'Calories';

  @override
  String get metricCadence => 'Cadence';

  @override
  String get metricEffort => 'Effort';

  @override
  String get metricTemperature => 'Temperature';

  @override
  String get metricDevice => 'Device';

  @override
  String get metricGear => 'Gear';

  @override
  String get metricElevation => 'Elevation';

  @override
  String get comparison => 'Comparison';

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get evolution => 'Evolution';

  @override
  String get noPreviousData => 'no previous data';

  @override
  String get vsPrevWeek => 'vs prev. week';

  @override
  String get vsPrevMonth => 'vs prev. month';

  @override
  String get sportAll => 'All';

  @override
  String get sportRun => 'Running';

  @override
  String get sportTrail => 'Trail';

  @override
  String get sportRide => 'Cycling';

  @override
  String get sportSwim => 'Swimming';

  @override
  String get sportWalk => 'Walking';

  @override
  String get sportHike => 'Hiking';

  @override
  String get sportWorkout => 'Workout';

  @override
  String get comparatorTitle => 'Comparator';

  @override
  String get tabHeadToHead => 'Head to head';

  @override
  String get tabSameRoute => 'Same route';

  @override
  String get tabPeriods => 'Periods';

  @override
  String get pickTwoHint =>
      'Pick two activities to compare them across all metrics.';

  @override
  String get pickActivity => 'Pick activity';

  @override
  String get routesEmpty =>
      'We haven\'t detected repeated routes yet.\nWe need at least 2 outings with the same start, finish and distance.';

  @override
  String routeOutings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outings',
      one: '1 outing',
    );
    return '$_temp0';
  }

  @override
  String routeBest(String time) {
    return 'best $time';
  }

  @override
  String get routeTitle => 'Route';

  @override
  String get statBest => 'Best';

  @override
  String get statAvg => 'Avg';

  @override
  String get statImprovement => 'Improvement';

  @override
  String get yourAttempts => 'Your attempts (by time)';

  @override
  String get record => 'record';

  @override
  String get periodThisWeek => 'This week';

  @override
  String get periodPrevWeek => 'Prev. week';

  @override
  String get periodThisMonth => 'This month';

  @override
  String get periodPrevMonth => 'Prev. month';

  @override
  String get periodLast30 => 'Last 30d';

  @override
  String get periodPrev30 => 'Prev. 30d';

  @override
  String get seg30d => '30 days';

  @override
  String get segYear => 'Year';

  @override
  String get kudos => 'Kudos';

  @override
  String get weatherClear => 'Clear';

  @override
  String get weatherMostlyClear => 'Mostly clear';

  @override
  String get weatherPartlyCloudy => 'Partly cloudy';

  @override
  String get weatherCloudy => 'Cloudy';

  @override
  String get weatherFog => 'Fog';

  @override
  String get weatherDrizzle => 'Drizzle';

  @override
  String get weatherFreezingDrizzle => 'Freezing drizzle';

  @override
  String get weatherRain => 'Rain';

  @override
  String get weatherFreezingRain => 'Freezing rain';

  @override
  String get weatherSnow => 'Snow';

  @override
  String get weatherShowers => 'Showers';

  @override
  String get weatherSnowShowers => 'Snow showers';

  @override
  String get weatherThunderstorm => 'Thunderstorm';

  @override
  String get weatherThunderstormHail => 'Thunderstorm with hail';

  @override
  String get weatherUnknown => 'Weather';

  @override
  String get compassDirs => 'N,NE,E,SE,S,SW,W,NW';

  @override
  String get zonesHr => 'Heart rate zones';

  @override
  String get zonesPower => 'Power zones';

  @override
  String get zonesGeneric => 'Zones';

  @override
  String get mapboxTokenHint =>
      'Add a Mapbox token (lib/env.dart) to see the map';
}

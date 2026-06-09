// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Basque (`eu`).
class AppLocalizationsEu extends AppLocalizations {
  AppLocalizationsEu([String locale = 'eu']) : super(locale);

  @override
  String get appTagline => 'Kirola zuzenean · benetako aurrerapena';

  @override
  String get language => 'Hizkuntza';

  @override
  String get email => 'Emaila';

  @override
  String get password => 'Pasahitza';

  @override
  String get signIn => 'Sartu';

  @override
  String get createAccount => 'Kontua sortu';

  @override
  String get orWord => 'edo';

  @override
  String get continueWithGoogle => 'Jarraitu Google-rekin';

  @override
  String get checkEmailConfirm =>
      'Begiratu zure posta elektronikoa kontua berresteko.';

  @override
  String get errorUnexpected => 'Ustekabeko errore bat gertatu da.';

  @override
  String get errorGoogleSignIn => 'Ezin izan da Google-rekin saioa hasi.';

  @override
  String get searchWorkoutsHint => 'Bilatu entrenamenduak…';

  @override
  String get stravaConnected => 'Strava konektatuta.';

  @override
  String stravaConnectError(String detail) {
    return 'Ezin izan da Strava konektatu ($detail).';
  }

  @override
  String get stravaConnectStartFailed =>
      'Ezin izan da Stravarekiko konexioa hasi.';

  @override
  String get menuDisconnectStrava => 'Strava deskonektatu';

  @override
  String get menuLogout => 'Saioa itxi';

  @override
  String get headlineConnectTitle => 'Konektatu hasteko';

  @override
  String get headlineConnectBody =>
      'Lotu zure Strava kontua zure entrenatzaileak zure entrenamenduak aztertzen has dadin. Zure jarduerak soilik irakurtzen ditugu.';

  @override
  String get connectStrava => 'Stravarekin konektatu';

  @override
  String get headlineSyncTitle => 'Sinkronizatu zure entrenamenduak';

  @override
  String get headlineSyncBody =>
      'Oraindik ez dituzu zure jarduerak deskargatu. Sinkronizatu itzazu zure entrenatzaileak azter ditzan.';

  @override
  String get goSync => 'Joan sinkronizatzera';

  @override
  String get headlineProgressTitle => 'Aurrera zoaz';

  @override
  String headlineProgressBody(int pct) {
    return 'Hilabete honetako bolumena %$pct igo da aurreko hilabetearen aldean. Erritmo ona.';
  }

  @override
  String get headlineEasierTitle => 'Aste lasaiagoa';

  @override
  String headlineEasierBody(int pct) {
    return 'Zure bolumena %$pct jaitsi da aurreko hilabetearen aldean. Deskarga edo atsedena izan daiteke.';
  }

  @override
  String get headlineStableTitle => 'Egonkor zaude';

  @override
  String get headlineStableBody =>
      'Zure bolumena aurreko hilabetekoaren antzekoa da. Konstantzia.';

  @override
  String get headlineBaseTitle => 'Zure oinarria eraikitzen';

  @override
  String get headlineBaseBody =>
      'Jarraitu entrenamenduak erregistratzen hilabetez hilabeteko bilakaera ikusteko.';

  @override
  String get lastWorkout => 'Azken entrenamendua';

  @override
  String get activities => 'Jarduerak';

  @override
  String get syncYourWorkouts => 'Sinkronizatu zure entrenamenduak';

  @override
  String activitiesSynced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sinkronizatuta',
    );
    return '$_temp0';
  }

  @override
  String get statDistance => 'Distantzia';

  @override
  String get statTime => 'Denbora';

  @override
  String get statPace => 'Erritmoa';

  @override
  String get statSpeed => 'Abiadura';

  @override
  String get activityFallback => 'Jarduera';

  @override
  String get searchHintFull => 'Bilatu: izena, kirola, lekua, hilabetea…';

  @override
  String noResults(String query) {
    return 'Ez dago emaitzarik \"$query\" bilaketarako.';
  }

  @override
  String get summaryActivitiesLabel => 'jarduera';

  @override
  String get summaryTotalDistance => 'distantzia osoa';

  @override
  String get syncNow => 'Sinkronizatu orain';

  @override
  String get emptyActivities =>
      'Oraindik ez dago jarduerarik.\nSinkronizatu Stravatik deskargatzeko.';

  @override
  String get resyncAll => 'Dena birsinkronizatu';

  @override
  String get resyncAllSubtitle =>
      'Birkargatu eta osatu historialaren xehetasunak';

  @override
  String get syncingWithStrava => 'Stravarekin sinkronizatzen…';

  @override
  String get loadActivitiesFailed => 'Ezin izan dira jarduerak kargatu.';

  @override
  String get preparingData => 'Zure datuak prestatzen…';

  @override
  String get syncUpToDate => 'Egunean zaude.';

  @override
  String syncDetailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count xehetasunekin',
    );
    return '$_temp0';
  }

  @override
  String syncRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aberasteke geratzen dira',
    );
    return '$_temp0';
  }

  @override
  String get detailTitle => 'Xehetasunak';

  @override
  String get sectionElevationProfile => 'Altuera-profila';

  @override
  String get sectionWeather => 'Eguraldia';

  @override
  String get sectionSplits => 'Zatiak km-ko';

  @override
  String get sectionZones => 'Denbora guneka';

  @override
  String get metricDistance => 'Distantzia';

  @override
  String get metricMovingTime => 'Mugimendu-denbora';

  @override
  String get metricTotalTime => 'Denbora osoa';

  @override
  String get metricAvgPace => 'Batez besteko erritmoa';

  @override
  String get metricAvgSpeed => 'Batez besteko abiadura';

  @override
  String get metricMaxPace => 'Erritmo maximoa';

  @override
  String get metricMaxSpeed => 'Abiadura maximoa';

  @override
  String get metricElevGain => 'Desnibel positiboa';

  @override
  String get metricMaxAlt => 'Altitude maximoa';

  @override
  String get metricMinAlt => 'Altitude minimoa';

  @override
  String get metricAvgHr => 'Batez besteko BM';

  @override
  String get metricMaxHr => 'BM maximoa';

  @override
  String get metricAvgPower => 'Batez besteko potentzia';

  @override
  String get metricNormPower => 'Potentzia normalizatua';

  @override
  String get metricMaxPower => 'Potentzia maximoa';

  @override
  String get metricWork => 'Lana';

  @override
  String get metricCalories => 'Kaloriak';

  @override
  String get metricCadence => 'Kadentzia';

  @override
  String get metricEffort => 'Ahalegina';

  @override
  String get metricTemperature => 'Tenperatura';

  @override
  String get metricDevice => 'Gailua';

  @override
  String get metricGear => 'Materiala';

  @override
  String get metricElevation => 'Desnibela';

  @override
  String get comparison => 'Konparaketa';

  @override
  String get periodWeek => 'Astea';

  @override
  String get periodMonth => 'Hilabetea';

  @override
  String get evolution => 'Bilakaera';

  @override
  String get noPreviousData => 'aurreko daturik ez';

  @override
  String get vsPrevWeek => 'aurreko astearekiko';

  @override
  String get vsPrevMonth => 'aurreko hilabetearekiko';

  @override
  String get sportAll => 'Denak';

  @override
  String get sportRun => 'Korrika';

  @override
  String get sportTrail => 'Trail';

  @override
  String get sportRide => 'Txirrindularitza';

  @override
  String get sportSwim => 'Igeriketa';

  @override
  String get sportWalk => 'Ibilaldia';

  @override
  String get sportHike => 'Mendi-ibilaldia';

  @override
  String get sportWorkout => 'Entrenamendua';

  @override
  String get comparatorTitle => 'Konparatzailea';

  @override
  String get tabHeadToHead => 'Aurrez aurre';

  @override
  String get tabSameRoute => 'Ibilbide bera';

  @override
  String get tabPeriods => 'Aldiak';

  @override
  String get pickTwoHint =>
      'Aukeratu bi jarduera neurri guztietan konparatzeko.';

  @override
  String get pickActivity => 'Aukeratu jarduera';

  @override
  String get routesEmpty =>
      'Oraindik ez dugu ibilbide errepikaturik antzeman.\nGutxienez 2 irteera behar ditugu hasiera, amaiera eta distantzia berarekin.';

  @override
  String routeOutings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count irteera',
    );
    return '$_temp0';
  }

  @override
  String routeBest(String time) {
    return 'onena $time';
  }

  @override
  String get routeTitle => 'Ibilbidea';

  @override
  String get statBest => 'Onena';

  @override
  String get statAvg => 'Batez beste';

  @override
  String get statImprovement => 'Hobekuntza';

  @override
  String get yourAttempts => 'Zure saiakerak (denboraren arabera)';

  @override
  String get record => 'errekorra';

  @override
  String get periodThisWeek => 'Aste hau';

  @override
  String get periodPrevWeek => 'Aurreko astea';

  @override
  String get periodThisMonth => 'Hilabete hau';

  @override
  String get periodPrevMonth => 'Aurreko hilabetea';

  @override
  String get periodLast30 => 'Azken 30 egun';

  @override
  String get periodPrev30 => 'Aurreko 30 egun';

  @override
  String get seg30d => '30 egun';

  @override
  String get segYear => 'Urtea';

  @override
  String get kudos => 'Kudos';

  @override
  String get weatherClear => 'Oskarbi';

  @override
  String get weatherMostlyClear => 'Gehienbat oskarbi';

  @override
  String get weatherPartlyCloudy => 'Partzialki lainotuta';

  @override
  String get weatherCloudy => 'Lainotuta';

  @override
  String get weatherFog => 'Lainoa';

  @override
  String get weatherDrizzle => 'Zirimiria';

  @override
  String get weatherFreezingDrizzle => 'Zirimiri izoztua';

  @override
  String get weatherRain => 'Euria';

  @override
  String get weatherFreezingRain => 'Euri izoztua';

  @override
  String get weatherSnow => 'Elurra';

  @override
  String get weatherShowers => 'Zaparradak';

  @override
  String get weatherSnowShowers => 'Elur-zaparradak';

  @override
  String get weatherThunderstorm => 'Ekaitza';

  @override
  String get weatherThunderstormHail => 'Ekaitza txingorrarekin';

  @override
  String get weatherUnknown => 'Eguraldia';

  @override
  String get compassDirs => 'I,IE,E,HE,H,HM,M,IM';

  @override
  String get zonesHr => 'Bihotz-maiztasun guneak';

  @override
  String get zonesPower => 'Potentzia guneak';

  @override
  String get zonesGeneric => 'Guneak';

  @override
  String get mapboxTokenHint =>
      'Gehitu Mapbox token bat (lib/env.dart) mapa ikusteko';
}

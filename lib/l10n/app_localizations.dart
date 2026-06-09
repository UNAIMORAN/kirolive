import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_eu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('eu'),
  ];

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Live sport · real progress'**
  String get appTagline;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @orWord.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orWord;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @checkEmailConfirm.
  ///
  /// In en, this message translates to:
  /// **'Check your email to confirm your account.'**
  String get checkEmailConfirm;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get errorUnexpected;

  /// No description provided for @errorGoogleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign in with Google.'**
  String get errorGoogleSignIn;

  /// No description provided for @searchWorkoutsHint.
  ///
  /// In en, this message translates to:
  /// **'Search workouts…'**
  String get searchWorkoutsHint;

  /// No description provided for @stravaConnected.
  ///
  /// In en, this message translates to:
  /// **'Strava connected.'**
  String get stravaConnected;

  /// No description provided for @stravaConnectError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t connect Strava ({detail}).'**
  String stravaConnectError(String detail);

  /// No description provided for @stravaConnectStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start the Strava connection.'**
  String get stravaConnectStartFailed;

  /// No description provided for @menuDisconnectStrava.
  ///
  /// In en, this message translates to:
  /// **'Disconnect Strava'**
  String get menuDisconnectStrava;

  /// No description provided for @menuLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get menuLogout;

  /// No description provided for @headlineConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect to get started'**
  String get headlineConnectTitle;

  /// No description provided for @headlineConnectBody.
  ///
  /// In en, this message translates to:
  /// **'Link your Strava account so your coach can start analysing your workouts. We only read your activities.'**
  String get headlineConnectBody;

  /// No description provided for @connectStrava.
  ///
  /// In en, this message translates to:
  /// **'Connect with Strava'**
  String get connectStrava;

  /// No description provided for @headlineSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync your workouts'**
  String get headlineSyncTitle;

  /// No description provided for @headlineSyncBody.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t downloaded your activities yet. Sync them so your coach can analyse them.'**
  String get headlineSyncBody;

  /// No description provided for @goSync.
  ///
  /// In en, this message translates to:
  /// **'Go to sync'**
  String get goSync;

  /// No description provided for @headlineProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re making progress'**
  String get headlineProgressTitle;

  /// No description provided for @headlineProgressBody.
  ///
  /// In en, this message translates to:
  /// **'Your volume this month is up {pct}% from last month. Good pace.'**
  String headlineProgressBody(int pct);

  /// No description provided for @headlineEasierTitle.
  ///
  /// In en, this message translates to:
  /// **'An easier week'**
  String get headlineEasierTitle;

  /// No description provided for @headlineEasierBody.
  ///
  /// In en, this message translates to:
  /// **'Your volume is down {pct}% from last month. It may be a taper or rest.'**
  String headlineEasierBody(int pct);

  /// No description provided for @headlineStableTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re staying steady'**
  String get headlineStableTitle;

  /// No description provided for @headlineStableBody.
  ///
  /// In en, this message translates to:
  /// **'Your volume is similar to last month. Consistency.'**
  String get headlineStableBody;

  /// No description provided for @headlineBaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Building your base'**
  String get headlineBaseTitle;

  /// No description provided for @headlineBaseBody.
  ///
  /// In en, this message translates to:
  /// **'Keep logging workouts to see your month-over-month progression.'**
  String get headlineBaseBody;

  /// No description provided for @lastWorkout.
  ///
  /// In en, this message translates to:
  /// **'Latest workout'**
  String get lastWorkout;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// No description provided for @syncYourWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Sync your workouts'**
  String get syncYourWorkouts;

  /// No description provided for @activitiesSynced.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 synced} other{{count} synced}}'**
  String activitiesSynced(int count);

  /// No description provided for @statDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get statDistance;

  /// No description provided for @statTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get statTime;

  /// No description provided for @statPace.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get statPace;

  /// No description provided for @statSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get statSpeed;

  /// No description provided for @activityFallback.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityFallback;

  /// No description provided for @searchHintFull.
  ///
  /// In en, this message translates to:
  /// **'Search: name, sport, place, month…'**
  String get searchHintFull;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\".'**
  String noResults(String query);

  /// No description provided for @summaryActivitiesLabel.
  ///
  /// In en, this message translates to:
  /// **'activities'**
  String get summaryActivitiesLabel;

  /// No description provided for @summaryTotalDistance.
  ///
  /// In en, this message translates to:
  /// **'total distance'**
  String get summaryTotalDistance;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @emptyActivities.
  ///
  /// In en, this message translates to:
  /// **'No activities yet.\nSync to download them from Strava.'**
  String get emptyActivities;

  /// No description provided for @resyncAll.
  ///
  /// In en, this message translates to:
  /// **'Re-sync everything'**
  String get resyncAll;

  /// No description provided for @resyncAllSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reload and complete the history detail'**
  String get resyncAllSubtitle;

  /// No description provided for @syncingWithStrava.
  ///
  /// In en, this message translates to:
  /// **'Syncing with Strava…'**
  String get syncingWithStrava;

  /// No description provided for @loadActivitiesFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load activities.'**
  String get loadActivitiesFailed;

  /// No description provided for @preparingData.
  ///
  /// In en, this message translates to:
  /// **'Preparing your data…'**
  String get preparingData;

  /// No description provided for @syncUpToDate.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up.'**
  String get syncUpToDate;

  /// No description provided for @syncDetailed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 with detail} other{{count} with detail}}'**
  String syncDetailed(int count);

  /// No description provided for @syncRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 left to enrich} other{{count} left to enrich}}'**
  String syncRemaining(int count);

  /// No description provided for @detailTitle.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get detailTitle;

  /// No description provided for @sectionElevationProfile.
  ///
  /// In en, this message translates to:
  /// **'Elevation profile'**
  String get sectionElevationProfile;

  /// No description provided for @sectionWeather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get sectionWeather;

  /// No description provided for @sectionSplits.
  ///
  /// In en, this message translates to:
  /// **'Splits per km'**
  String get sectionSplits;

  /// No description provided for @sectionZones.
  ///
  /// In en, this message translates to:
  /// **'Time in zones'**
  String get sectionZones;

  /// No description provided for @metricDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get metricDistance;

  /// No description provided for @metricMovingTime.
  ///
  /// In en, this message translates to:
  /// **'Moving time'**
  String get metricMovingTime;

  /// No description provided for @metricTotalTime.
  ///
  /// In en, this message translates to:
  /// **'Total time'**
  String get metricTotalTime;

  /// No description provided for @metricAvgPace.
  ///
  /// In en, this message translates to:
  /// **'Avg pace'**
  String get metricAvgPace;

  /// No description provided for @metricAvgSpeed.
  ///
  /// In en, this message translates to:
  /// **'Avg speed'**
  String get metricAvgSpeed;

  /// No description provided for @metricMaxPace.
  ///
  /// In en, this message translates to:
  /// **'Max pace'**
  String get metricMaxPace;

  /// No description provided for @metricMaxSpeed.
  ///
  /// In en, this message translates to:
  /// **'Max speed'**
  String get metricMaxSpeed;

  /// No description provided for @metricElevGain.
  ///
  /// In en, this message translates to:
  /// **'Elevation gain'**
  String get metricElevGain;

  /// No description provided for @metricMaxAlt.
  ///
  /// In en, this message translates to:
  /// **'Max altitude'**
  String get metricMaxAlt;

  /// No description provided for @metricMinAlt.
  ///
  /// In en, this message translates to:
  /// **'Min altitude'**
  String get metricMinAlt;

  /// No description provided for @metricAvgHr.
  ///
  /// In en, this message translates to:
  /// **'Avg HR'**
  String get metricAvgHr;

  /// No description provided for @metricMaxHr.
  ///
  /// In en, this message translates to:
  /// **'Max HR'**
  String get metricMaxHr;

  /// No description provided for @metricAvgPower.
  ///
  /// In en, this message translates to:
  /// **'Avg power'**
  String get metricAvgPower;

  /// No description provided for @metricNormPower.
  ///
  /// In en, this message translates to:
  /// **'Normalized power'**
  String get metricNormPower;

  /// No description provided for @metricMaxPower.
  ///
  /// In en, this message translates to:
  /// **'Max power'**
  String get metricMaxPower;

  /// No description provided for @metricWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get metricWork;

  /// No description provided for @metricCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get metricCalories;

  /// No description provided for @metricCadence.
  ///
  /// In en, this message translates to:
  /// **'Cadence'**
  String get metricCadence;

  /// No description provided for @metricEffort.
  ///
  /// In en, this message translates to:
  /// **'Effort'**
  String get metricEffort;

  /// No description provided for @metricTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get metricTemperature;

  /// No description provided for @metricDevice.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get metricDevice;

  /// No description provided for @metricGear.
  ///
  /// In en, this message translates to:
  /// **'Gear'**
  String get metricGear;

  /// No description provided for @metricElevation.
  ///
  /// In en, this message translates to:
  /// **'Elevation'**
  String get metricElevation;

  /// No description provided for @comparison.
  ///
  /// In en, this message translates to:
  /// **'Comparison'**
  String get comparison;

  /// No description provided for @periodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get periodMonth;

  /// No description provided for @evolution.
  ///
  /// In en, this message translates to:
  /// **'Evolution'**
  String get evolution;

  /// No description provided for @noPreviousData.
  ///
  /// In en, this message translates to:
  /// **'no previous data'**
  String get noPreviousData;

  /// No description provided for @vsPrevWeek.
  ///
  /// In en, this message translates to:
  /// **'vs prev. week'**
  String get vsPrevWeek;

  /// No description provided for @vsPrevMonth.
  ///
  /// In en, this message translates to:
  /// **'vs prev. month'**
  String get vsPrevMonth;

  /// No description provided for @sportAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get sportAll;

  /// No description provided for @sportRun.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get sportRun;

  /// No description provided for @sportTrail.
  ///
  /// In en, this message translates to:
  /// **'Trail'**
  String get sportTrail;

  /// No description provided for @sportRide.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get sportRide;

  /// No description provided for @sportSwim.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get sportSwim;

  /// No description provided for @sportWalk.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get sportWalk;

  /// No description provided for @sportHike.
  ///
  /// In en, this message translates to:
  /// **'Hiking'**
  String get sportHike;

  /// No description provided for @sportWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get sportWorkout;

  /// No description provided for @comparatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Comparator'**
  String get comparatorTitle;

  /// No description provided for @tabHeadToHead.
  ///
  /// In en, this message translates to:
  /// **'Head to head'**
  String get tabHeadToHead;

  /// No description provided for @tabSameRoute.
  ///
  /// In en, this message translates to:
  /// **'Same route'**
  String get tabSameRoute;

  /// No description provided for @tabPeriods.
  ///
  /// In en, this message translates to:
  /// **'Periods'**
  String get tabPeriods;

  /// No description provided for @pickTwoHint.
  ///
  /// In en, this message translates to:
  /// **'Pick two activities to compare them across all metrics.'**
  String get pickTwoHint;

  /// No description provided for @pickActivity.
  ///
  /// In en, this message translates to:
  /// **'Pick activity'**
  String get pickActivity;

  /// No description provided for @routesEmpty.
  ///
  /// In en, this message translates to:
  /// **'We haven\'t detected repeated routes yet.\nWe need at least 2 outings with the same start, finish and distance.'**
  String get routesEmpty;

  /// No description provided for @routeOutings.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 outing} other{{count} outings}}'**
  String routeOutings(int count);

  /// No description provided for @routeBest.
  ///
  /// In en, this message translates to:
  /// **'best {time}'**
  String routeBest(String time);

  /// No description provided for @routeTitle.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get routeTitle;

  /// No description provided for @statBest.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get statBest;

  /// No description provided for @statAvg.
  ///
  /// In en, this message translates to:
  /// **'Avg'**
  String get statAvg;

  /// No description provided for @statImprovement.
  ///
  /// In en, this message translates to:
  /// **'Improvement'**
  String get statImprovement;

  /// No description provided for @yourAttempts.
  ///
  /// In en, this message translates to:
  /// **'Your attempts (by time)'**
  String get yourAttempts;

  /// No description provided for @record.
  ///
  /// In en, this message translates to:
  /// **'record'**
  String get record;

  /// No description provided for @periodThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get periodThisWeek;

  /// No description provided for @periodPrevWeek.
  ///
  /// In en, this message translates to:
  /// **'Prev. week'**
  String get periodPrevWeek;

  /// No description provided for @periodThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get periodThisMonth;

  /// No description provided for @periodPrevMonth.
  ///
  /// In en, this message translates to:
  /// **'Prev. month'**
  String get periodPrevMonth;

  /// No description provided for @periodLast30.
  ///
  /// In en, this message translates to:
  /// **'Last 30d'**
  String get periodLast30;

  /// No description provided for @periodPrev30.
  ///
  /// In en, this message translates to:
  /// **'Prev. 30d'**
  String get periodPrev30;

  /// No description provided for @seg30d.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get seg30d;

  /// No description provided for @segYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get segYear;

  /// No description provided for @kudos.
  ///
  /// In en, this message translates to:
  /// **'Kudos'**
  String get kudos;

  /// No description provided for @weatherClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get weatherClear;

  /// No description provided for @weatherMostlyClear.
  ///
  /// In en, this message translates to:
  /// **'Mostly clear'**
  String get weatherMostlyClear;

  /// No description provided for @weatherPartlyCloudy.
  ///
  /// In en, this message translates to:
  /// **'Partly cloudy'**
  String get weatherPartlyCloudy;

  /// No description provided for @weatherCloudy.
  ///
  /// In en, this message translates to:
  /// **'Cloudy'**
  String get weatherCloudy;

  /// No description provided for @weatherFog.
  ///
  /// In en, this message translates to:
  /// **'Fog'**
  String get weatherFog;

  /// No description provided for @weatherDrizzle.
  ///
  /// In en, this message translates to:
  /// **'Drizzle'**
  String get weatherDrizzle;

  /// No description provided for @weatherFreezingDrizzle.
  ///
  /// In en, this message translates to:
  /// **'Freezing drizzle'**
  String get weatherFreezingDrizzle;

  /// No description provided for @weatherRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get weatherRain;

  /// No description provided for @weatherFreezingRain.
  ///
  /// In en, this message translates to:
  /// **'Freezing rain'**
  String get weatherFreezingRain;

  /// No description provided for @weatherSnow.
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get weatherSnow;

  /// No description provided for @weatherShowers.
  ///
  /// In en, this message translates to:
  /// **'Showers'**
  String get weatherShowers;

  /// No description provided for @weatherSnowShowers.
  ///
  /// In en, this message translates to:
  /// **'Snow showers'**
  String get weatherSnowShowers;

  /// No description provided for @weatherThunderstorm.
  ///
  /// In en, this message translates to:
  /// **'Thunderstorm'**
  String get weatherThunderstorm;

  /// No description provided for @weatherThunderstormHail.
  ///
  /// In en, this message translates to:
  /// **'Thunderstorm with hail'**
  String get weatherThunderstormHail;

  /// No description provided for @weatherUnknown.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get weatherUnknown;

  /// No description provided for @compassDirs.
  ///
  /// In en, this message translates to:
  /// **'N,NE,E,SE,S,SW,W,NW'**
  String get compassDirs;

  /// No description provided for @zonesHr.
  ///
  /// In en, this message translates to:
  /// **'Heart rate zones'**
  String get zonesHr;

  /// No description provided for @zonesPower.
  ///
  /// In en, this message translates to:
  /// **'Power zones'**
  String get zonesPower;

  /// No description provided for @zonesGeneric.
  ///
  /// In en, this message translates to:
  /// **'Zones'**
  String get zonesGeneric;

  /// No description provided for @mapboxTokenHint.
  ///
  /// In en, this message translates to:
  /// **'Add a Mapbox token (lib/env.dart) to see the map'**
  String get mapboxTokenHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'eu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'eu':
      return AppLocalizationsEu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

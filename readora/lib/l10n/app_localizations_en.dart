// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Readora';

  @override
  String get tagline => 'Read more. Remember more.';

  @override
  String get navHome => 'Home';

  @override
  String get navLibrary => 'Library';

  @override
  String get navDiscover => 'Discover';

  @override
  String get navAi => 'AI';

  @override
  String get navProfile => 'Profile';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get continueReading => 'Continue reading';

  @override
  String pagesOfTotal(int current, int total) {
    return '$current / $total pages';
  }

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-day streak',
      one: '1-day streak',
      zero: 'No streak yet',
    );
    return '$_temp0';
  }

  @override
  String get statusWantToRead => 'Want to read';

  @override
  String get statusReading => 'Reading';

  @override
  String get statusFinished => 'Finished';

  @override
  String get statusDnf => 'Did not finish';

  @override
  String get statusPaused => 'Paused';

  @override
  String get syncSaved => 'Saved';

  @override
  String get syncSyncing => 'Syncing';

  @override
  String get syncOffline => 'Offline';

  @override
  String get syncWillRetry => 'Will retry';

  @override
  String get emptyLibraryTitle => 'Nothing here yet';

  @override
  String get emptyLibraryBody =>
      'Search for a book or scan its barcode to start tracking it.';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get continueAsGuest => 'Start without an account';

  @override
  String get guestReassurance =>
      'You can create an account later — nothing you track will be lost.';
}

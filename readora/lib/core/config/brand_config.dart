/// Every user-visible brand string lives here.
///
/// The product name is not final. When it changes, this file plus the two
/// native identifiers (`android/app/build.gradle.kts` applicationId and the
/// iOS bundle identifier) are the only places that need editing — nothing else
/// in `lib/` may hardcode the word "Readora".
abstract final class BrandConfig {
  static const appName = 'Readora';
  static const tagline = 'Read more. Remember more.';
  static const premiumTierName = 'Readora Plus';
  static const supportEmail = 'hello@readora.app';
  static const deepLinkScheme = 'readora';

  /// Package/bundle identifier, kept here for display in Settings > About.
  /// MUST match the native identifiers, and MUST be final before the first
  /// Play Console upload — Google does not allow changing it afterwards.
  static const packageId = 'com.readora.app';
}

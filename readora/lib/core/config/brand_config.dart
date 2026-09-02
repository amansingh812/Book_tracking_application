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

  /// Hosted Privacy Policy / Terms of Service, linked from Settings and
  /// required by both App Store Connect and Play Console before a public
  /// listing. Currently a Claude Artifacts URL — a fine placeholder for
  /// TestFlight/internal testing, worth moving to a readora.app domain
  /// before a public release.
  static const privacyPolicyUrl =
      'https://claude.ai/code/artifact/4f7f675a-8e1a-478c-9c34-21e13b1889c7#privacy';
  static const termsOfServiceUrl =
      'https://claude.ai/code/artifact/4f7f675a-8e1a-478c-9c34-21e13b1889c7#terms';
}

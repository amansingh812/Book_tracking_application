import 'package:purchases_flutter/purchases_flutter.dart';

/// Wraps RevenueCat. The client NEVER decides entitlement on its own — this
/// repository only reflects what RevenueCat's SDK reports, which itself is
/// kept in sync with `public.subscriptions` by the `revenuecat-webhook` Edge
/// Function (service role only). See docs/ARCHITECTURE.md > billing.
abstract interface class BillingRepository {
  /// True once the SDK has returned its first `CustomerInfo`.
  bool get isReady;

  /// Emits on every entitlement change, including the current value.
  Stream<bool> get isPlus;

  bool get isPlusNow;

  Future<Offerings> fetchOfferings();

  Future<CustomerInfo> purchasePackage(Package package);

  Future<CustomerInfo> restorePurchases();
}

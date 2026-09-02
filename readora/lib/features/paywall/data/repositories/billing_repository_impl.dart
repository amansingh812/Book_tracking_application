import 'dart:async';
import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:readora/core/config/env.dart';
import 'package:readora/core/logging/app_logger.dart';
import 'package:readora/features/auth/domain/entities/app_user.dart';
import 'package:readora/features/auth/domain/repositories/auth_repository.dart';
import 'package:readora/features/paywall/domain/repositories/billing_repository.dart';

/// The RevenueCat entitlement identifier — must match `subscriptions
/// .entitlement` (`'plus'`, see `0007_billing.sql`) and the entitlement
/// configured in the RevenueCat dashboard.
const String kPlusEntitlementId = 'plus';

class BillingRepositoryImpl implements BillingRepository {
  BillingRepositoryImpl({required AuthRepository auth}) : _auth = auth {
    _authSub = _auth.changes.listen(_onAuthChanged);
  }

  final AuthRepository _auth;
  StreamSubscription<AppUser?>? _authSub;
  final _isPlusController = StreamController<bool>.broadcast();
  bool _ready = false;
  bool _isPlus = false;
  String? _identifiedUserId;

  @override
  bool get isReady => _ready;

  @override
  Stream<bool> get isPlus => _isPlusController.stream;

  @override
  bool get isPlusNow => _isPlus;

  /// Configures the SDK. Call once at startup, before any other billing call.
  /// A missing dart-define key is treated as "billing not configured on this
  /// build" rather than a crash — dev builds can run without RevenueCat set up.
  Future<void> configure() async {
    final apiKey = Platform.isIOS ? Env.revenueCatIosKey : Env.revenueCatAndroidKey;
    if (apiKey.isEmpty) {
      AppLogger.warn(
        'RevenueCat key missing for ${Platform.operatingSystem} — '
        'billing features are disabled on this build.',
      );
      return;
    }

    try {
      await Purchases.configure(PurchasesConfiguration(apiKey));
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfo);
      final info = await Purchases.getCustomerInfo();
      _onCustomerInfo(info);
      _ready = true;
    } catch (error, stack) {
      AppLogger.error('RevenueCat configure failed', error, stack);
    }
  }

  void _onCustomerInfo(CustomerInfo info) {
    _isPlus = info.entitlements.active.containsKey(kPlusEntitlementId);
    if (!_isPlusController.isClosed) _isPlusController.add(_isPlus);
  }

  /// Links the RevenueCat anonymous id to our Supabase user id so purchases
  /// survive a reinstall / new device, and detaches it on sign-out so the
  /// next guest doesn't inherit someone else's purchase state.
  Future<void> _onAuthChanged(AppUser? user) async {
    if (!_ready) return;
    try {
      if (user == null || user.isGuest) {
        if (_identifiedUserId != null) {
          await Purchases.logOut();
          _identifiedUserId = null;
        }
      } else if (_identifiedUserId != user.id) {
        final result = await Purchases.logIn(user.id);
        _identifiedUserId = user.id;
        _onCustomerInfo(result.customerInfo);
      }
    } catch (error, stack) {
      AppLogger.error('RevenueCat identity sync failed', error, stack);
    }
  }

  @override
  Future<Offerings> fetchOfferings() => Purchases.getOfferings();

  @override
  Future<CustomerInfo> purchasePackage(Package package) async {
    final result = await Purchases.purchasePackage(package);
    _onCustomerInfo(result.customerInfo);
    return result.customerInfo;
  }

  @override
  Future<CustomerInfo> restorePurchases() async {
    final info = await Purchases.restorePurchases();
    _onCustomerInfo(info);
    return info;
  }

  Future<void> dispose() async {
    await _authSub?.cancel();
    await _isPlusController.close();
  }
}

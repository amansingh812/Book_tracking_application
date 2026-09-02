import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:readora/features/paywall/domain/repositories/billing_repository.dart';

part 'paywall_event.dart';
part 'paywall_state.dart';

class PaywallBloc extends Bloc<PaywallEvent, PaywallState> {
  PaywallBloc(this._repo) : super(PaywallState(isPlus: _repo.isPlusNow)) {
    on<PaywallStarted>(_onStarted);
    on<PaywallPurchaseRequested>(_onPurchaseRequested);
    on<PaywallRestoreRequested>(_onRestoreRequested);
    on<_PaywallEntitlementChanged>(_onEntitlementChanged);
    _sub = _repo.isPlus.listen((v) => add(_PaywallEntitlementChanged(v)));
  }

  final BillingRepository _repo;
  StreamSubscription<bool>? _sub;

  Future<void> _onStarted(PaywallStarted event, Emitter<PaywallState> emit) async {
    if (!_repo.isReady) {
      emit(state.copyWith(
        error: 'Store connection is not set up on this build yet.',
        loading: false,
      ));
      return;
    }
    emit(state.copyWith(loading: true, error: null));
    try {
      final offerings = await _repo.fetchOfferings();
      emit(state.copyWith(loading: false, offerings: offerings));
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Could not load pricing. Try again.'));
    }
  }

  void _onEntitlementChanged(
    _PaywallEntitlementChanged event,
    Emitter<PaywallState> emit,
  ) {
    emit(state.copyWith(isPlus: event.isPlus));
  }

  Future<void> _onPurchaseRequested(
    PaywallPurchaseRequested event,
    Emitter<PaywallState> emit,
  ) async {
    emit(state.copyWith(purchasing: true, error: null));
    try {
      await _repo.purchasePackage(event.package);
      emit(state.copyWith(purchasing: false));
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      final cancelled = code == PurchasesErrorCode.purchaseCancelledError;
      emit(state.copyWith(
        purchasing: false,
        error: cancelled ? null : (e.message ?? 'Purchase failed. Try again.'),
      ));
    } catch (_) {
      emit(state.copyWith(purchasing: false, error: 'Purchase failed. Try again.'));
    }
  }

  Future<void> _onRestoreRequested(
    PaywallRestoreRequested event,
    Emitter<PaywallState> emit,
  ) async {
    emit(state.copyWith(purchasing: true, error: null));
    try {
      await _repo.restorePurchases();
      emit(state.copyWith(purchasing: false));
    } catch (_) {
      emit(state.copyWith(purchasing: false, error: 'Could not restore purchases.'));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

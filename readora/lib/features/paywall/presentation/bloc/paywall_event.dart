part of 'paywall_bloc.dart';

sealed class PaywallEvent extends Equatable {
  const PaywallEvent();
  @override
  List<Object?> get props => [];
}

class PaywallStarted extends PaywallEvent {
  const PaywallStarted();
}

class PaywallPurchaseRequested extends PaywallEvent {
  const PaywallPurchaseRequested(this.package);
  final Package package;
  @override
  List<Object?> get props => [package];
}

class PaywallRestoreRequested extends PaywallEvent {
  const PaywallRestoreRequested();
}

class _PaywallEntitlementChanged extends PaywallEvent {
  const _PaywallEntitlementChanged(this.isPlus);
  final bool isPlus;
  @override
  List<Object?> get props => [isPlus];
}

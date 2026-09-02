part of 'paywall_bloc.dart';

class PaywallState extends Equatable {
  const PaywallState({
    required this.isPlus,
    this.offerings,
    this.loading = false,
    this.purchasing = false,
    this.error,
  });

  final bool isPlus;
  final Offerings? offerings;
  final bool loading;
  final bool purchasing;
  final String? error;

  Package? get monthly => offerings?.current?.monthly;
  Package? get annual => offerings?.current?.annual;
  List<Package> get packages => offerings?.current?.availablePackages ?? const [];

  PaywallState copyWith({
    bool? isPlus,
    Offerings? offerings,
    bool? loading,
    bool? purchasing,
    String? error,
  }) {
    return PaywallState(
      isPlus: isPlus ?? this.isPlus,
      offerings: offerings ?? this.offerings,
      loading: loading ?? this.loading,
      purchasing: purchasing ?? this.purchasing,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isPlus, offerings, loading, purchasing, error];
}

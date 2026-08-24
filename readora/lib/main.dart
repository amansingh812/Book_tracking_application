import 'package:readora/main_dev.dart' as dev;

/// `flutter create` and some IDE run configurations look for `lib/main.dart`.
/// Readora's real entrypoints are `main_dev.dart` and `main_prod.dart`; this
/// file just points at dev so a bare `flutter run` still works.
void main() => dev.main();

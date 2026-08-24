import 'package:readora/bootstrap.dart';

/// Production entrypoint.
///
///     flutter build appbundle --flavor prod -t lib/main_prod.dart \
///       --dart-define-from-file=env/prod.json
void main() => bootstrap();

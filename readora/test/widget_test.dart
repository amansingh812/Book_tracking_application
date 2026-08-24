import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readora/design_system/widgets/progress_ring.dart';

void main() {
  testWidgets('ProgressRing renders progress correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: ProgressRing(progress: 0.75),
          ),
        ),
      ),
    );

    expect(find.text('75%'), findsOneWidget);
  });
}

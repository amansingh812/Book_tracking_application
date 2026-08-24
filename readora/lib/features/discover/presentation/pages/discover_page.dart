import 'package:flutter/material.dart';
import 'package:readora/design_system/widgets/coming_soon.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoon(
      title: 'Discover',
      description:
          'Personalised recommendations, mood-based discovery, and a plain-English '
          'reason for every suggestion.',
      milestone: 'M4',
    );
  }
}

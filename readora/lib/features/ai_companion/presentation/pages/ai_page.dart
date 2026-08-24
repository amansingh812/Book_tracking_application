import 'package:flutter/material.dart';
import 'package:readora/design_system/widgets/coming_soon.dart';

class AiPage extends StatelessWidget {
  const AiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoon(
      title: 'AI Companion',
      description:
          'Ask questions about what you are reading, grounded in your own notes '
          'and highlights. Quizzes and flashcards come from the same place.',
      milestone: 'M3',
    );
  }
}

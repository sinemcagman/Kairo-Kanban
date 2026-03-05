import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/kanban_board/presentation/screens/kanban_board_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: KairoApp(),
    ),
  );
}

class KairoApp extends StatelessWidget {
  const KairoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kairo To Do List',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const KanbanBoardScreen(),
    );
  }
}

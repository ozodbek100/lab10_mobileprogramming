import 'package:flutter/material.dart';

import '../services/app_state.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'model_screen.dart';

class Shell extends StatefulWidget {
  const Shell({super.key, required this.app});
  final AppState app;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps each tab alive when you switch.
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(app: widget.app),
          HistoryScreen(app: widget.app),
          ModelScreen(app: widget.app),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(
              icon: Icon(Icons.memory_outlined), label: 'Model'),
        ],
      ),
    );
  }
}
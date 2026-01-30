import 'package:flutter/material.dart';
import 'screens/name_screen.dart';
import 'screens/calculator_screen.dart';
import 'screens/history_screen.dart';
import 'utils/storage.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Diff',
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: {
        '/name': (_) => NameScreen(),
        '/calc': (_) => CalculatorScreen(),
        '/history': (_) => HistoryScreen(),
      },
      home: FutureBuilder<String?>(
        future: Storage.getUserName(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snap.hasError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(height: 8),
                    Text('Error: ${snap.error}'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => (context as Element).reassemble(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return snap.data == null ? NameScreen() : CalculatorScreen();
        },
      ),
    );
  }
}
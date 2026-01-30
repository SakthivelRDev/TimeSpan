import 'package:flutter/material.dart';
import '../utils/storage.dart';

class NameScreen extends StatefulWidget {
  @override
  _NameScreenState createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final _ctrl = TextEditingController();

  void _save() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    await Storage.setUserName(name);
    Navigator.pushReplacementNamed(context, '/calc');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Enter your name'),
            TextField(controller: _ctrl, decoration: const InputDecoration(hintText: 'Name')),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _save, child: const Text('Continue'))
          ],
        ),
      ),
    );
  }
}
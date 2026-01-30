import 'package:flutter/material.dart';
import '../utils/storage.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  TimeOfDay? _start;
  TimeOfDay? _end;
  String? _result;
  String? _name;
  final List<int> _downtimes = []; // minutes
  final _fmt = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final n = await Storage.getUserName();
    setState(() => _name = n);
  }

  // <-- CHANGED: force 24-hour formatting
  String _fmtTOD(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  // <-- CHANGED: showTimePicker using 24-hour format
  Future<TimeOfDay?> _pick(TimeOfDay? initial) {
    final init = initial ?? TimeOfDay.now();
    return showTimePicker(
      context: context,
      initialTime: init,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

  int _toMinutesTOD(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<void> _setNowAsEnd() async {
    final now = TimeOfDay.now();
    setState(() => _end = now);
  }

  Future<void> _addDowntimeDialog() async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add downtime (minutes)'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'e.g. 15'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add')),
        ],
      ),
    );
    if (ok == true) {
      final v = int.tryParse(controller.text.trim());
      if (v != null && v > 0) {
        setState(() => _downtimes.insert(0, v));
      }
    }
  }

  Future<void> _calc() async {
    if (_start == null || _end == null) {
      setState(() => _result = 'Select start and end times');
      return;
    }
    var sm = _toMinutesTOD(_start!);
    var em = _toMinutesTOD(_end!);
    if (em < sm) em += 24 * 60;
    final rawDiff = em - sm;
    final downtimeSum = _downtimes.fold<int>(0, (a, b) => a + b);
    var diff = rawDiff - downtimeSum;
    if (diff < 0) diff = 0;
    final h = diff ~/ 60;
    final m = diff % 60;
    final res = '${h} h ${m} min';
    setState(() => _result = res);
    await Storage.addHistory({
      'user': _name ?? '',
      'start': '${_start!.hour.toString().padLeft(2, '0')}:${_start!.minute.toString().padLeft(2, '0')}',
      'end': '${_end!.hour.toString().padLeft(2, '0')}:${_end!.minute.toString().padLeft(2, '0')}',
      'raw_diff_min': rawDiff,
      'downtimes': _downtimes,
      'downtime_total': downtimeSum,
      'result': res,
      'ts': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Diff Calculator'),
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: () => Navigator.pushNamed(context, '/history')),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Hi, ${_name ?? 'User'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Start'),
              subtitle: Text(_start == null ? 'Select start time' : _fmtTOD(_start!)),
              leading: const Icon(Icons.play_arrow),
              onTap: () async {
                final t = await _pick(_start);
                if (t != null) setState(() => _start = t);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('End'),
              subtitle: Text(_end == null ? 'Select end time or use now' : _fmtTOD(_end!)),
              leading: const Icon(Icons.stop),
              trailing: TextButton(onPressed: _setNowAsEnd, child: const Text('Use now')),
              onTap: () async {
                final t = await _pick(_end);
                if (t != null) setState(() => _end = t);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.timer_off),
                const SizedBox(width: 8),
                const Text('Downtimes (minutes):', style: TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  onPressed: _addDowntimeDialog,
                )
              ],
            ),
            if (_downtimes.isEmpty)
              const Text('No downtimes added')
            else
              Wrap(
                spacing: 8,
                children: _downtimes
                    .asMap()
                    .entries
                    .map((e) => Chip(
                          label: Text('${e.value}m'),
                          onDeleted: () => setState(() => _downtimes.removeAt(e.key)),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _calc, child: const Text('Calculate')),
            const SizedBox(height: 12),
            if (_result != null)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Result: $_result', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text('Total downtime: ${_downtimes.fold<int>(0, (a, b) => a + b)} min'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
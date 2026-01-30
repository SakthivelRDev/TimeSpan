import 'package:flutter/material.dart';
import '../utils/storage.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _items = [];
  String? _user;

  Future<void> _load() async {
    _items = await Storage.getHistory();
    _user = await Storage.getUserName();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _clear() async {
    await Storage.clearHistory();
    await _load();
  }

  String _fmtTs(String? iso) {
    if (iso == null) return '';
    try {
      final d = DateTime.parse(iso).toLocal();
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [IconButton(icon: const Icon(Icons.delete), onPressed: _clear)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text('User: ${_user ?? '-'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _items.isEmpty
                  ? const Center(child: Text('No history yet'))
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final it = _items[i];
                        final dowTotal = (it['downtime_total'] ?? 0).toString();
                        final dowList = (it['downtimes'] is List) ? (it['downtimes'] as List).join(', ') : '';
                        return ListTile(
                          leading: CircleAvatar(child: Text('${i + 1}')),
                          title: Text('${it['start']} → ${it['end']} = ${it['result']}'),
                          subtitle: Text('Downtime: ${dowTotal} min ${dowList.isNotEmpty ? '($dowList)' : ''}\n${_fmtTs(it['ts'])}'),
                          isThreeLine: true,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
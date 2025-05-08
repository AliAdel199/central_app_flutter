
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> logs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    try {
      final res = await supabase
          .from('logs')
          .select(
              'action, table_name, record_id, description, created_at, user_id, profiles(full_name)')
          .order('created_at', ascending: false);

      setState(() {
        logs = List<Map<String, dynamic>>.from(res);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching logs: \$e');
      setState(() => isLoading = false);
    }
  }

  Color getActionColor(String action) {
    switch (action) {
      case 'create':
        return Colors.green.shade100;
      case 'update':
        return Colors.blue.shade100;
      case 'delete':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  IconData getActionIcon(String action) {
    switch (action) {
      case 'create':
        return Icons.add;
      case 'update':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سجل الأحداث')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: logs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final log = logs[index];
                final action = log['action'] ?? '—';
                final table = log['table_name'] ?? '—';
                final description = log['description'] ?? '—';
                final executor = log['profiles']?['full_name'] ?? '—';
                final date = log['created_at']?.toString().split('.')[0] ?? '—';

                return Container(
                  decoration: BoxDecoration(
                    color: getActionColor(action),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(getActionIcon(action), color: Colors.black87),
                    ),
                    title: Text('$action → $table', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('الوصف: $description'),
                          Text('المنفذ: $executor'),
                          Text('التاريخ: $date'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

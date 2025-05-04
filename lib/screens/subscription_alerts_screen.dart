
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionAlertsScreen extends StatefulWidget {
  const SubscriptionAlertsScreen({super.key});

  @override
  State<SubscriptionAlertsScreen> createState() => _SubscriptionAlertsScreenState();
}

class _SubscriptionAlertsScreenState extends State<SubscriptionAlertsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> schools = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSchools();
  }

  Future<void> fetchSchools() async {
    try {
      final data = await supabase.from('schools').select('id, name, end_date');
      final List<Map<String, dynamic>> all = List<Map<String, dynamic>>.from(data);
      setState(() {
        schools = all;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error: \n $e');
      setState(() => isLoading = false);
    }
  }

  String getStatus(DateTime? endDate) {
    if (endDate == null) return 'غير محدد';
    final now = DateTime.now();
    if (endDate.isBefore(now)) return 'منتهي';
    if (endDate.difference(now).inDays <= 7) return 'قارب على الانتهاء';
    return 'فعال';
  }

  Color getColor(String status) {
    switch (status) {
      case 'منتهي':
        return Colors.red;
      case 'قارب على الانتهاء':
        return Colors.orange;
      case 'فعال':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنبيهات الاشتراك')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: schools.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final school = schools[index];
                final name = school['name'] ?? '—';
                final dateStr = school['end_date'] as String?;
                final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
                final status = getStatus(date);
                final color = getColor(status);
                final formattedDate = date != null
                    ? DateFormat('yyyy-MM-dd').format(date)
                    : 'غير محدد';

                return Card(
                  child: ListTile(
                    title: Text(name),
                    subtitle: Text('تاريخ الانتهاء: $formattedDate'),
                    trailing: Text(
                      status,
                      style: TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

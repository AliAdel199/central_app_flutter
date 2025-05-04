
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionStatsWidget extends StatefulWidget {
  const SubscriptionStatsWidget({super.key});

  @override
  State<SubscriptionStatsWidget> createState() => _SubscriptionStatsWidgetState();
}

class _SubscriptionStatsWidgetState extends State<SubscriptionStatsWidget> {
  final supabase = Supabase.instance.client;
  int expired = 0;
  int expiringSoon = 0;
  int active = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    try {
      final data = await supabase.from('schools').select('end_date');
      final now = DateTime.now();
      int expiredCount = 0;
      int soonCount = 0;
      int activeCount = 0;

      for (final item in data) {
        final endDate = DateTime.tryParse(item['end_date'] ?? '');
        if (endDate == null) continue;
        if (endDate.isBefore(now)) {
          expiredCount++;
        } else if (endDate.difference(now).inDays <= 7) {
          soonCount++;
        } else {
          activeCount++;
        }
      }

      setState(() {
        expired = expiredCount;
        expiringSoon = soonCount;
        active = activeCount;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('خطأ في جلب الإحصائيات: \n$e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const CircularProgressIndicator();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('📊 ملخص الاشتراكات:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildBox('فعال', active, Colors.green),
            buildBox('قارب الانتهاء', expiringSoon, Colors.orange),
            buildBox('منتهي', expired, Colors.red),
          ],
        ),
      ],
    );
  }

  Widget buildBox(String title, int count, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text('$count', style: TextStyle(fontSize: 20, color: color)),
        ],
      ),
    );
  }
}

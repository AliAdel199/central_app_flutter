
import 'package:central_app_flutter/screens/school_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'add_payment_screen.dart';
import 'edit_subscription_screen.dart';
import 'payments_history_screen.dart';

class SchoolDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> school;

  const SchoolDetailsScreen({super.key, required this.school});

  @override
  State<SchoolDetailsScreen> createState() => _SchoolDetailsScreenState();
}

class _SchoolDetailsScreenState extends State<SchoolDetailsScreen> {
  final supabase = Supabase.instance.client;
  late Map<String, dynamic> school;

  @override
  void initState() {
    super.initState();
    school = widget.school;
  }

  Future<void> toggleStatus() async {
    final newStatus = school['subscription_status'] == 'active' ? 'expired' : 'active';
    await supabase.from('schools').update({'subscription_status': newStatus}).eq('id', school['id']);
    setState(() {
      school['subscription_status'] = newStatus;
    });
  }

  Future<void> extendSubscription(int days) async {
    final currentEndDate = DateTime.tryParse(school['end_date'] ?? '') ?? DateTime.now();
    final newEndDate = currentEndDate.add(Duration(days: days));
    await supabase.from('schools').update({
      'end_date': newEndDate.toIso8601String(),
      'subscription_status': 'active'
    }).eq('id', school['id']);
    setState(() {
      school['end_date'] = newEndDate.toIso8601String();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.titleMedium;

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل المدرسة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildInfoRow('📛 الاسم:', school['name'], textStyle),
                    buildInfoRow('📧 البريد:', school['email'], textStyle),
                    buildInfoRow('📞 الهاتف:', school['phone'], textStyle),
                    buildInfoRow('📋 الخطة:', school['subscription_plan'], textStyle),
                    buildInfoRow('📌 الحالة:', school['subscription_status'], textStyle),
                    buildInfoRow('📅 تاريخ الانتهاء:', school['end_date'] ?? 'غير محدد', textStyle),
                  ],
                ),
              ),
            ),
            
            ElevatedButton.icon(
              onPressed: toggleStatus,
              icon: const Icon(Icons.toggle_on),
              label: Text(
                school['subscription_status'] == 'active'
                    ? 'إيقاف الاشتراك'
                    : 'تفعيل الاشتراك',
              ),
            ),
            const SizedBox(height: 12),
             ElevatedButton.icon(
              icon: const Icon(Icons.payment),
              label: const Text('عرض سجل الدفعات'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentsHistoryScreen(
                  schoolId: school['id'],
                      schoolName: school['name'],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('إضافة دفعة جديدة'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddPaymentScreen(
                      schoolId: school['id'],
                      schoolName: school['name'],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit_calendar),
              label: const Text('تعديل تاريخ الاشتراك'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditSubscriptionScreen(
                     schoolId: school['id'],
                      schoolName: school['name'],
                    ),
                  ),
                );
              },
            ),
       
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(String label, String? value, TextStyle? style) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: style),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value ?? '—', style: style?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

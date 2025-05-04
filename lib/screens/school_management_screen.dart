
import 'package:flutter/material.dart';
import 'add_payment_screen.dart';
import 'payments_history_screen.dart';
import 'edit_subscription_screen.dart';

class SchoolManagementScreen extends StatelessWidget {
  final String schoolId;
  final String schoolName;

  const SchoolManagementScreen({super.key, required this.schoolId, required this.schoolName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إدارة: $schoolName')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.payment),
              label: const Text('عرض سجل الدفعات'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentsHistoryScreen(
                      schoolId: schoolId,
                      schoolName: schoolName,
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
                      schoolId: schoolId,
                      schoolName: schoolName,
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
                      schoolId: schoolId,
                      schoolName: schoolName,
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
}

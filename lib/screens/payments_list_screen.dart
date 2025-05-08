
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentsListScreen extends StatefulWidget {
  const PaymentsListScreen({super.key});

  @override
  State<PaymentsListScreen> createState() => _PaymentsListScreenState();
}

class _PaymentsListScreenState extends State<PaymentsListScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> payments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    try {
      final currentUserId = supabase.auth.currentUser?.id;
      final currentUser = await supabase
          .from('profiles')
          .select('role, school_id')
          .eq('id', currentUserId!)
          .single();

      final allPayments = await supabase
          .from('payments')
          .select('id, amount, date, method, notes, school_id, schools(name)');

      List<Map<String, dynamic>> filtered = [];

      if (currentUser['role'] == 'super_admin') {
        filtered = List<Map<String, dynamic>>.from(allPayments);
      } else {
        filtered = List<Map<String, dynamic>>.from(allPayments)
            .where((p) => p['school_id'] == currentUser['school_id'])
            .toList();
      }

      setState(() {
        payments = filtered;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching payments: \$e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قائمة الدفعات')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: payments.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final payment = payments[index];
                return Card(
                  child: ListTile(
                    title: Text('المبلغ: \$${payment['amount']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('المدرسة: ${payment['schools']?['name'] ?? 'غير محددة'}'),
                        Text('التاريخ: ${payment['date'] ?? '—'}'),
                        Text('الطريقة: ${payment['method'] ?? '—'}'),
                        Text('ملاحظات: ${payment['notes'] ?? '—'}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

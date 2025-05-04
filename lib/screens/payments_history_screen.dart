
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentsHistoryScreen extends StatefulWidget {
  final String schoolId;
  final String schoolName;

  const PaymentsHistoryScreen({super.key, required this.schoolId, required this.schoolName});

  @override
  State<PaymentsHistoryScreen> createState() => _PaymentsHistoryScreenState();
}

class _PaymentsHistoryScreenState extends State<PaymentsHistoryScreen> {
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
      final data = await supabase
          .from('payments')
          .select()
          .eq('school_id', widget.schoolId)
          .order('payment_date', ascending: false);

      setState(() {
        payments = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('خطأ في جلب الدفعات: \$e');
      setState(() => isLoading = false);
    }
  }

  String formatDate(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '-';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('سجل دفعات ${widget.schoolName}')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : payments.isEmpty
              ? const Center(child: Text('لا توجد دفعات مسجلة'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final payment = payments[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.payment),
                        title: Text('${payment['amount']} د.ع'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('التاريخ: ${formatDate(payment['payment_date'])}'),
                            Text('الطريقة: ${payment['method'] ?? '-'}'),
                            if (payment['notes'] != null && payment['notes'].toString().isNotEmpty)
                              Text('ملاحظة: ${payment['notes']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

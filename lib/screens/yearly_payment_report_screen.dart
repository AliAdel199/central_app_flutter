
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class YearlyPaymentReportScreen extends StatefulWidget {
  const YearlyPaymentReportScreen({super.key});

  @override
  State<YearlyPaymentReportScreen> createState() => _YearlyPaymentReportScreenState();
}

class _YearlyPaymentReportScreenState extends State<YearlyPaymentReportScreen> {
  final supabase = Supabase.instance.client;
  Map<String, double> yearlyTotals = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchYearlyReport();
  }

  Future<void> fetchYearlyReport() async {
    try {
      final data = await supabase.from('payments').select('amount, payment_date');
      final List<Map<String, dynamic>> payments = List<Map<String, dynamic>>.from(data);

      final Map<String, double> yearTotals = {};

      for (final payment in payments) {
        final date = DateTime.tryParse(payment['payment_date'] ?? '');
        if (date == null) continue;

        final yearKey = DateFormat('yyyy').format(date);
        final amount = double.tryParse(payment['amount'].toString()) ?? 0;

        yearTotals[yearKey] = (yearTotals[yearKey] ?? 0) + amount;
      }

      setState(() {
        yearlyTotals = yearTotals;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('خطأ في جلب التقرير السنوي: \$e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedKeys = yearlyTotals.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(title: const Text('تقرير المدفوعات السنوي')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedKeys.length,
              itemBuilder: (context, index) {
                final key = sortedKeys[index];
                final value = yearlyTotals[key]!;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(key),
                    trailing: Text('${value.toStringAsFixed(0)} د.ع'),
                  ),
                );
              },
            ),
    );
  }
}

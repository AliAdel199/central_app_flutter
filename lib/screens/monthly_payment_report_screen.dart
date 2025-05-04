
import 'package:central_app_flutter/screens/monthly_payment_export_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MonthlyPaymentReportScreen extends StatefulWidget {
  const MonthlyPaymentReportScreen({super.key});

  @override
  State<MonthlyPaymentReportScreen> createState() => _MonthlyPaymentReportScreenState();
}

class _MonthlyPaymentReportScreenState extends State<MonthlyPaymentReportScreen> {
  final supabase = Supabase.instance.client;
  Map<String, double> monthlyTotals = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMonthlyReport();
  }

  Future<void> fetchMonthlyReport() async {
    try {
      final data = await supabase.from('payments').select('amount, payment_date');
      final List<Map<String, dynamic>> payments = List<Map<String, dynamic>>.from(data);

      final Map<String, double> monthTotals = {};

      for (final payment in payments) {
        final date = DateTime.tryParse(payment['payment_date'] ?? '');
        if (date == null) continue;

        final monthKey = DateFormat('yyyy-MM').format(date);
        final amount = double.tryParse(payment['amount'].toString()) ?? 0;

        monthTotals[monthKey] = (monthTotals[monthKey] ?? 0) + amount;
      }

      setState(() {
        monthlyTotals = monthTotals;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('خطأ في جلب التقرير الشهري: \$e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedKeys = monthlyTotals.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(title: const Text('تقرير المدفوعات الشهري')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedKeys.length,
              itemBuilder: (context, index) {
                final key = sortedKeys[index];
                final value = monthlyTotals[key]!;
                return Column(
                  children: [
                    ElevatedButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>MonthlyPaymentExportScreen())), child: Text(' طباعة التقارير')),
                    const SizedBox(height: 8),
                    const Divider(),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.calendar_month),
                        title: Text(key),
                        trailing: Text('${value.toStringAsFixed(0)} د.ع'),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MonthlyPaymentExportScreen extends StatefulWidget {
  const MonthlyPaymentExportScreen({super.key});

  @override
  State<MonthlyPaymentExportScreen> createState() => _MonthlyPaymentExportScreenState();
}

class _MonthlyPaymentExportScreenState extends State<MonthlyPaymentExportScreen> {
  final supabase = Supabase.instance.client;
  bool isLoading = false;

  Future<void> exportToExcel() async {
    setState(() => isLoading = true);

    try {
      final data = await supabase.from('payments').select('amount, payment_date');
      final payments = List<Map<String, dynamic>>.from(data);

      final Map<String, double> monthTotals = {};

      for (final payment in payments) {
        final date = DateTime.tryParse(payment['payment_date'] ?? '');
        if (date == null) continue;
        final key = DateFormat('yyyy-MM').format(date);
        final amount = double.tryParse(payment['amount'].toString()) ?? 0;
        monthTotals[key] = (monthTotals[key] ?? 0) + amount;
      }

      final excel = Excel.createExcel();
      final sheet = excel['تقرير شهري'];

      sheet.appendRow(['الشهر', 'الإجمالي']);

      final sortedKeys = monthTotals.keys.toList()..sort((a, b) => b.compareTo(a));
      for (final key in sortedKeys) {
        sheet.appendRow([key, monthTotals[key]]);
      }

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/monthly_report.xlsx')
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تصدير الملف إلى: ${file.path}')),
      );
    } catch (e) {
      debugPrint('خطأ في التصدير: \$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تصدير الملف: \$e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تصدير التقرير الشهري')),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                onPressed: exportToExcel,
                icon: const Icon(Icons.download),
                label: const Text('تصدير إلى Excel'),
              ),
      ),
    );
  }
}

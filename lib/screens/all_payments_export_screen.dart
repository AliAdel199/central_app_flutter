
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AllPaymentsExportScreen extends StatefulWidget {
  const AllPaymentsExportScreen({super.key});

  @override
  State<AllPaymentsExportScreen> createState() => _AllPaymentsExportScreenState();
}

class _AllPaymentsExportScreenState extends State<AllPaymentsExportScreen> {
  final supabase = Supabase.instance.client;
  bool isLoading = false;

  Future<void> exportAllPayments() async {
    setState(() => isLoading = true);

    try {
      final data = await supabase
          .from('payments')
          .select('amount, method, notes, payment_date, school_id');

      final payments = List<Map<String, dynamic>>.from(data);

      final excel = Excel.createExcel();
      final sheet = excel['جميع الدفعات'];

      // العناوين
      sheet.appendRow(['التاريخ', 'المبلغ', 'الطريقة', 'ملاحظات', 'رقم المدرسة']);

      for (final payment in payments) {
        final date = DateTime.tryParse(payment['payment_date'] ?? '');
        final formattedDate = date != null ? DateFormat('yyyy-MM-dd').format(date) : '-';
        final amount = payment['amount']?.toString() ?? '0';
        final method = payment['method'] ?? '-';
        final notes = payment['notes'] ?? '';
        final schoolId = payment['school_id'] ?? '-';

        sheet.appendRow([
          formattedDate,
          amount,
          method,
          notes,
          schoolId,
        ]);
      }

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/all_payments_report.xlsx')
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
      appBar: AppBar(title: const Text('تصدير جميع الدفعات')),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                onPressed: exportAllPayments,
                icon: const Icon(Icons.download),
                label: const Text('تصدير إلى Excel'),
              ),
      ),
    );
  }
}

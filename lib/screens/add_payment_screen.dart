
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AddPaymentScreen extends StatefulWidget {
  final String schoolId;
  final String schoolName;

  const AddPaymentScreen({super.key, required this.schoolId, required this.schoolName});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final supabase = Supabase.instance.client;
  final amountController = TextEditingController();
  final methodController = TextEditingController();
  final notesController = TextEditingController();
  DateTime? selectedEndDate;
  bool isLoading = false;

  Future<void> addPayment() async {
    final amount = double.tryParse(amountController.text.trim());
    final method = methodController.text.trim();
    final notes = notesController.text.trim();

    if (amount == null || amount <= 0 || method.isEmpty || selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال كافة الحقول بشكل صحيح')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // إدخال الدفع في جدول payments
      await supabase.from('payments').insert({
        'school_id': widget.schoolId,
        'amount': amount,
        'method': method,
        'notes': notes,
        'payment_date': DateTime.now().toIso8601String(),
      });

      // تحديث تاريخ انتهاء الاشتراك في جدول schools
      await supabase.from('schools').update({
        'end_date': selectedEndDate!.toIso8601String(),
      }).eq('id', widget.schoolId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة الدفعة وتحديث الاشتراك')),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint('خطأ أثناء الإضافة: \n $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: \n $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        selectedEndDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = selectedEndDate != null
        ? DateFormat('yyyy-MM-dd').format(selectedEndDate!)
        : 'اختيار تاريخ انتهاء الاشتراك';

    return Scaffold(
      appBar: AppBar(title: Text('إضافة دفعة لـ ${widget.schoolName}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'المبلغ'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: methodController,
              decoration: const InputDecoration(labelText: 'طريقة الدفع'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: pickEndDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(dateText),
            ),
            const SizedBox(height: 24),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: addPayment,
                    icon: const Icon(Icons.save),
                    label: const Text('إضافة الدفعة'),
                  ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class EditSubscriptionScreen extends StatefulWidget {
  final String schoolId;
  final String schoolName;

  const EditSubscriptionScreen({super.key, required this.schoolId, required this.schoolName});

  @override
  State<EditSubscriptionScreen> createState() => _EditSubscriptionScreenState();
}

class _EditSubscriptionScreenState extends State<EditSubscriptionScreen> {
  final supabase = Supabase.instance.client;
  DateTime? selectedDate;
  bool isLoading = false;

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> updateSubscription() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار تاريخ')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await supabase.from('schools').update({
        'end_date': selectedDate!.toIso8601String(),
      }).eq('id', widget.schoolId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث تاريخ الاشتراك بنجاح')),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint('خطأ في التحديث: \$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: \$e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayDate = selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(selectedDate!)
        : 'اختر تاريخ الاشتراك';

    return Scaffold(
      appBar: AppBar(title: Text('تعديل اشتراك ${widget.schoolName}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(displayDate),
            ),
            const SizedBox(height: 24),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: updateSubscription,
                    icon: const Icon(Icons.save),
                    label: const Text('تحديث الاشتراك'),
                  ),
          ],
        ),
      ),
    );
  }
}

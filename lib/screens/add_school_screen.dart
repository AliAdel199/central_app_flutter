import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddSchoolScreen extends StatefulWidget {
  const AddSchoolScreen({super.key});

  @override
  State<AddSchoolScreen> createState() => _AddSchoolScreenState();
}

class _AddSchoolScreenState extends State<AddSchoolScreen> {
  final supabase = Supabase.instance.client;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final subscriptionPlanController = TextEditingController();
  DateTime? endDate;
  bool isLoading = false;

  Future<void> pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (date != null) {
      setState(() => endDate = date);
    }
  }

  Future<void> addSchool() async {
    if (nameController.text.isEmpty || subscriptionPlanController.text.isEmpty || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى تعبئة جميع الحقول المطلوبة')));
      return;
    }

    setState(() => isLoading = true);

    try {
      await supabase.from('schools').insert({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'subscription_plan': subscriptionPlanController.text.trim(),
        'subscription_status': 'active',
        'end_date': endDate!.toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة المدرسة بنجاح')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة مدرسة جديدة')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'اسم المدرسة'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'البريد الإلكتروني (اختياري)'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'رقم الهاتف (اختياري)'),
            ),
            TextField(
              controller: subscriptionPlanController,
              decoration: const InputDecoration(labelText: 'خطة الاشتراك'),
            ),
            ListTile(
              title: Text(endDate == null ? 'تاريخ انتهاء الاشتراك' : endDate!.toLocal().toString().split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: pickEndDate,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: addSchool,
                    child: const Text('إضافة المدرسة'),
                  ),
          ],
        ),
      ),
    );
  }
}

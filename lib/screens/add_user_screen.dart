
import 'package:central_app_flutter/services/log_action.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final supabase = Supabase.instance.client;
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String selectedRole = 'manager';
  String? selectedSchoolId;

  bool canViewStudents = false;
  bool canManagePayments = false;
  bool canViewReports = false;
  bool canManageUsers = false;

  List<Map<String, dynamic>> schools = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchSchools();
  }

  Future<void> fetchSchools() async {
    final response = await supabase.from('schools').select('id, name');
    setState(() {
      schools = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> registerUser() async {
    setState(() => isLoading = true);
    try {
      final authRes = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      final userId = authRes.user?.id;

      if (userId != null) {
        await supabase.from('profiles').insert({
          'id': userId,
          'full_name': fullNameController.text.trim(),
          'role': selectedRole,
          'school_id': selectedRole == 'super_admin' ? null : selectedSchoolId,
        });

        await supabase.from('permissions').insert({
          'user_id': userId,
          'can_view_students': canViewStudents,
          'can_manage_payments': canManagePayments,
          'can_view_reports': canViewReports,
          'can_manage_users': canManageUsers,
        });
      // 📝 تسجيل الحدث في logs
      await logAction(
        action: 'create',
        table: 'profiles',
        recordId: userId,
        description: 'تم إضافة مستخدم جديد: ${fullNameController.text.trim()}',
      );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء المستخدم بنجاح')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error: \n$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل التسجيل: \n$e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة مستخدم')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: fullNameController,
              decoration: const InputDecoration(labelText: 'الاسم الكامل'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'كلمة المرور'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedRole,
              items: const [
                DropdownMenuItem(value: 'super_admin', child: Text('Super Admin')),
                DropdownMenuItem(value: 'manager', child: Text('Manager')),
                DropdownMenuItem(value: 'staff', child: Text('Staff')),
              ],
              onChanged: (value) {
                setState(() => selectedRole = value!);
              },
              decoration: const InputDecoration(labelText: 'الدور'),
            ),
            if (selectedRole != 'super_admin') ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedSchoolId,
                items: schools.map((school) {
                  return DropdownMenuItem<String>(
                    value: school['id'] as String,
                    child: Text(school['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedSchoolId = value);
                },
                decoration: const InputDecoration(labelText: 'المدرسة'),
              ),
            ],
            const SizedBox(height: 12),
            const Text('الصلاحيات:', style: TextStyle(fontWeight: FontWeight.bold)),
            buildCheckbox('عرض الطلاب', canViewStudents, (val) => setState(() => canViewStudents = val!)),
            buildCheckbox('إدارة الدفعات', canManagePayments, (val) => setState(() => canManagePayments = val!)),
            buildCheckbox('عرض التقارير', canViewReports, (val) => setState(() => canViewReports = val!)),
            buildCheckbox('إدارة المستخدمين', canManageUsers, (val) => setState(() => canManageUsers = val!)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : registerUser,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('تسجيل المستخدم'),
            )
          ],
        ),
      ),
    );
  }
}

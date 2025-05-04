
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterManagerScreen extends StatefulWidget {
  const RegisterManagerScreen({super.key});

  @override
  State<RegisterManagerScreen> createState() => _RegisterManagerScreenState();
}

class _RegisterManagerScreenState extends State<RegisterManagerScreen> {
  final supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String selectedRole = 'admin';
  String? selectedSchoolId;

  List<Map<String, dynamic>> schools = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchSchools();
  }

  Future<void> fetchSchools() async {
    final result = await supabase.from('schools').select('id, name');
    setState(() {
      schools = List<Map<String, dynamic>>.from(result);
    });
  }

  Future<void> registerManager() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة البيانات بشكل صحيح')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final currentSession = supabase.auth.currentSession;

      final response = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = response.user;
      if (user != null) {
        await supabase.from('profiles').insert({
          'id': user.id,
          'full_name': nameController.text.trim(),
          'role': selectedRole,
          'school_id': selectedSchoolId,
        });

        if (currentSession != null) {
          await supabase.auth.setSession(currentSession.accessToken);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تسجيل المدير بنجاح')),
        );

        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (e.message.contains('already registered')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الحساب موجود مسبقًا، يمكنك تسجيل الدخول')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: ${e.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ غير متوقع: $e')),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل مدير جديد')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'الاسم الكامل'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'كلمة المرور'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedRole,
              items: const [
                DropdownMenuItem(value: 'admin', child: Text('مدير عادي')),
                DropdownMenuItem(value: 'super_admin', child: Text('مدير عام')),
              ],
              onChanged: (val) => setState(() => selectedRole = val!),
              decoration: const InputDecoration(labelText: 'الدور'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedSchoolId,
              items: schools
                  .map((school) => DropdownMenuItem<String>(
                        value: school['id'] ,
                        child: Text(school['name']),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => selectedSchoolId = val),
              decoration: const InputDecoration(labelText: 'اختر المدرسة (اختياري)'),
            ),
            const SizedBox(height: 24),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: registerManager,
                    child: const Text('تسجيل المدير'),
                  ),
          ],
        ),
      ),
    );
  }
}

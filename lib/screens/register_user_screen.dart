import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String selectedRole = 'admin';
  int? selectedSchoolId;

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

  Future<void> registerUser() async {
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
      // تسجيل المستخدم في Supabase Auth
      final response = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = response.user;
      if (user != null) {
        // إضافة المستخدم إلى جدول profiles
        await supabase.from('profiles').insert({
          'id': user.id,
          'full_name': nameController.text.trim(),
          'role': selectedRole,
          'school_id': selectedSchoolId,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم التسجيل بنجاح')),
        );

        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء التسجيل: $e')),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل مستخدم جديد')),
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
                DropdownMenuItem(value: 'admin', child: Text('مدير')),
                DropdownMenuItem(value: 'super_admin', child: Text('مدير عام')),
              ],
              onChanged: (val) => setState(() => selectedRole = val!),
              decoration: const InputDecoration(labelText: 'الدور'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: selectedSchoolId,
              items: schools
                  .map((school) => DropdownMenuItem<int>(
                        value: school['id'] as int,
                        child: Text(school['name'] as String),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => selectedSchoolId = val),
              decoration: const InputDecoration(labelText: 'المدرسة (اختياري)'),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: registerUser,
                    child: const Text('تسجيل المستخدم'),
                  ),
          ],
        ),
      ),
    );
  }
}

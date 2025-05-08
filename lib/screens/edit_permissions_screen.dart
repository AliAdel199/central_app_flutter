
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditPermissionsScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const EditPermissionsScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<EditPermissionsScreen> createState() => _EditPermissionsScreenState();
}

class _EditPermissionsScreenState extends State<EditPermissionsScreen> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;
  bool canViewStudents = false;
  bool canManagePayments = false;
  bool canViewReports = false;
  bool canManageUsers = false;

  @override
  void initState() {
    super.initState();
    fetchPermissions();
  }

  Future<void> fetchPermissions() async {
    try {
      final res = await supabase
          .from('permissions')
          .select('*')
          .eq('user_id', widget.userId)
          .maybeSingle();

      if (res != null) {
        setState(() {
          canViewStudents = res['can_view_students'] ?? false;
          canManagePayments = res['can_manage_payments'] ?? false;
          canViewReports = res['can_view_reports'] ?? false;
          canManageUsers = res['can_manage_users'] ?? false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching permissions: \$e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> savePermissions() async {
    try {
      final existing = await supabase
          .from('permissions')
          .select('id')
          .eq('user_id', widget.userId)
          .maybeSingle();

      if (existing != null) {
        await supabase.from('permissions').update({
          'can_view_students': canViewStudents,
          'can_manage_payments': canManagePayments,
          'can_view_reports': canViewReports,
          'can_manage_users': canManageUsers,
        }).eq('user_id', widget.userId);
      } else {
        await supabase.from('permissions').insert({
          'user_id': widget.userId,
          'can_view_students': canViewStudents,
          'can_manage_payments': canManagePayments,
          'can_view_reports': canViewReports,
          'can_manage_users': canManageUsers,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الصلاحيات بنجاح')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error saving permissions: \$e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء الحفظ')),
      );
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
      appBar: AppBar(title: Text('الصلاحيات - ${widget.userName}')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  buildCheckbox('عرض الطلاب', canViewStudents,
                      (val) => setState(() => canViewStudents = val!)),
                  buildCheckbox('إدارة الدفعات', canManagePayments,
                      (val) => setState(() => canManagePayments = val!)),
                  buildCheckbox('عرض التقارير', canViewReports,
                      (val) => setState(() => canViewReports = val!)),
                  buildCheckbox('إدارة المستخدمين', canManageUsers,
                      (val) => setState(() => canManageUsers = val!)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: savePermissions,
                    child: const Text('حفظ'),
                  )
                ],
              ),
            ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_user_screen.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final currentUserId = supabase.auth.currentUser?.id;
      final currentUserData = await supabase
          .from('profiles')
          .select('role, school_id')
          .eq('id', currentUserId!)
          .single();

      final allUsers = await supabase
          .from('profiles')
          .select('id, full_name, role, school_id, schools(name)');

      final currentRole = currentUserData['role'];
      final currentSchoolId = currentUserData['school_id'];

      List<Map<String, dynamic>> filtered = [];

      if (currentRole == 'super_admin') {
        filtered = List<Map<String, dynamic>>.from(allUsers);
      } else {
        filtered = List<Map<String, dynamic>>.from(allUsers)
            .where((u) => u['school_id'] == currentSchoolId)
            .toList();
      }

      setState(() {
        users = filtered;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching users: \$e');
      setState(() => isLoading = false);
    }
  }

  Future<void> updateRole(String userId, String newRole) async {
    await supabase.from('profiles').update({'role': newRole}).eq('id', userId);
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المستخدمين')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddUserScreen()),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة مستخدم'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  child: ListTile(
                    title: Text(user['full_name'] ?? '—'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الدور: ${user['role']}'),
                        Text('المدرسة: ${user['schools']?['name'] ?? 'غير محددة'}'),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (role) => updateRole(user['id'], role),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'super_admin', child: Text('Super Admin')),
                        const PopupMenuItem(value: 'manager', child: Text('Manager')),
                        const PopupMenuItem(value: 'staff', child: Text('Staff')),
                      ],
                      icon: const Icon(Icons.edit),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

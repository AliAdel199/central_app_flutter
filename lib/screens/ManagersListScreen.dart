import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'RegisterManagerScreen.dart';

class ManagersListScreen extends StatefulWidget {
  const ManagersListScreen({super.key});

  @override
  State<ManagersListScreen> createState() => _ManagersListScreenState();
}

class _ManagersListScreenState extends State<ManagersListScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> managers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchManagers();
  }

  Future<void> fetchManagers() async {
    try {
      final result = await supabase
          .from('profiles')
          .select('id, full_name, role, school_id')
          .order('created_at', ascending: true);
      setState(() {
        managers = List<Map<String, dynamic>>.from(result);
        isLoading = false;
      });
    } catch (e) {
      print('خطأ في جلب المدراء: $e');
    }
  }

  Widget buildManagerTile(Map<String, dynamic> manager) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(manager['full_name'] ?? 'بدون اسم'),
        subtitle: Text('الدور: ${manager['role']}'),
        trailing: Text(manager['school_id'] != null ? 'مدرسة ID: ${manager['school_id']}' : 'بدون مدرسة'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   appBar: AppBar(
  title: const Text('قائمة المدراء'),
  actions: [
    IconButton(
      icon: const Icon(Icons.add),
      tooltip: 'إضافة مدير',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RegisterManagerScreen()),
        ).then((_) => fetchManagers()); // تحديث القائمة بعد الرجوع
      },
    ),
  ],
),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: managers.length,
              itemBuilder: (context, index) => buildManagerTile(managers[index]),
            ),
    );
  }
}

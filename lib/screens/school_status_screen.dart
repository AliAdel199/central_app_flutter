
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class SchoolStatusScreen extends StatefulWidget {
  const SchoolStatusScreen({super.key});

  @override
  State<SchoolStatusScreen> createState() => _SchoolStatusScreenState();
}

class _SchoolStatusScreenState extends State<SchoolStatusScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> activeSchools = [];
  List<Map<String, dynamic>> expiringSoonSchools = [];
  List<Map<String, dynamic>> expiredSchools = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSchools();
  }

  Future<void> fetchSchools() async {
    try {
      final data = await supabase
          .from('schools')
          .select('id, name, address, subscription_status');

      final now = DateTime.now();
      final in7Days = now.add(const Duration(days: 7));

      final List<Map<String, dynamic>> active = [];
      final List<Map<String, dynamic>> expiring = [];
      final List<Map<String, dynamic>> expired = [];

      for (final school in data) {
        final subEnd = DateTime.tryParse(school['subscription_status'] ?? '');
        if (subEnd == null) continue;

        if (subEnd.isBefore(now)) {
          expired.add(school);
        } else if (subEnd.isBefore(in7Days)) {
          expiring.add(school);
        } else {
          active.add(school);
        }
      }

      setState(() {
        activeSchools = active;
        expiringSoonSchools = expiring;
        expiredSchools = expired;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('خطأ في جلب حالة المدارس: \$e');
      setState(() => isLoading = false);
    }
  }

  Widget buildSection(String title, List<Map<String, dynamic>> schools) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (schools.isEmpty)
          const Text('لا توجد مدارس'),
        ...schools.map((school) {
          final endDate = DateFormat('yyyy-MM-dd').format(
              DateTime.parse(school['subscription_status'] ?? ''));
          return Card(
            child: ListTile(
              title: Text(school['name'] ?? ''),
              subtitle: Text('ينتهي الاشتراك في: $endDate'),
              trailing: Text(school['address'] ?? ''),
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حالة اشتراكات المدارس')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  buildSection('المدارس الفعالة', activeSchools),
                  buildSection('تنتهي خلال 7 أيام', expiringSoonSchools),
                  buildSection('انتهى اشتراكها', expiredSchools),
                ],
              ),
            ),
    );
  }
}

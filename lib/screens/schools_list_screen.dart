import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'school_details_screen.dart';
import 'add_school_screen.dart';

class SchoolsListScreen extends StatefulWidget {
  const SchoolsListScreen({super.key});

  @override
  State<SchoolsListScreen> createState() => _SchoolsListScreenState();
}

class _SchoolsListScreenState extends State<SchoolsListScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> schools = [];
  List<Map<String, dynamic>> filteredSchools = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchSchools();
  }

  Future<void> fetchSchools() async {
    try {
      final result = await supabase.from('schools').select().order('created_at', ascending: false);
      final schoolList = List<Map<String, dynamic>>.from(result);
      setState(() {
        schools = schoolList;
        filteredSchools = schoolList;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching schools: $e');
    }
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredSchools = schools.where((school) {
        final name = (school['name'] ?? '').toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  Widget buildSchoolCard(Map<String, dynamic> school) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  school['name'] ?? '',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  school['subscription_status'] == 'active' ? 'نشط' : 'منتهي',
                  style: TextStyle(
                    color: school['subscription_status'] == 'active'
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${school['email'] ?? 'بلا بريد'} - ${school['subscription_plan'] ?? ''}',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SchoolDetailsScreen(school: school),
                    ),
                  );
                },
                child: const Text('تفاصيل', style: TextStyle(color: Colors.blue)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة المدارس'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddSchoolScreen()),
              ).then((_) => fetchSchools());
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: updateSearch,
                    decoration: InputDecoration(
                      labelText: 'ابحث باسم المدرسة',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredSchools.length,
                    itemBuilder: (context, index) => buildSchoolCard(filteredSchools[index]),
                  ),
                ),
              ],
            ),
    );
  }
}


import 'package:central_app_flutter/screens/all_payments_export_screen.dart';
import 'package:central_app_flutter/screens/dashboard_buttons.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'payment_reports_tabs.dart';
import 'subscription_alerts_screen.dart';
import 'subscription_stats_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final supabase = Supabase.instance.client;
  int schoolCount = 0;
  int managerCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    try {
      final schools = await supabase.from('schools').select('id');
      final managers = await supabase
          .from('profiles')
          .select('id')
          .eq('role', 'admin');

      setState(() {
        schoolCount = schools.length;
        managerCount = managers.length;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching stats: \$e');
      setState(() => isLoading = false);
    }
  }

  void logout() async {
    await supabase.auth.signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم - Central App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Row(
                    children: [
                      _StatCard(label: 'عدد المدارس', count: schoolCount),
                      const SizedBox(width: 12),
                      _StatCard(label: 'عدد المدراء', count: managerCount),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SubscriptionStatsWidget(),
                  const SizedBox(height: 24),
                DashboardButtons(),
                 
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;

  const _StatCard({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text('$count',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}

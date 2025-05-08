
import 'package:flutter/material.dart';
import 'logs_screen_styled.dart';
import 'subscription_alerts_screen.dart';
import 'payment_reports_tabs.dart';
import 'all_payments_export_screen.dart';

class DashboardButtons extends StatelessWidget {
  const DashboardButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final buttons = [
      _DashboardButton(
        icon: Icons.person_add,
        label: 'إضافة مدير',
        onTap: () => Navigator.pushNamed(context, '/add-manager'),
      ),
      _DashboardButton(
        icon: Icons.school,
        label: 'إضافة مدرسة',
        onTap: () => Navigator.pushNamed(context, '/add-school'),
      ),
      // _DashboardButton(
      //   icon: Icons.people,
      //   label: 'عرض المدراء',
      //   onTap: () => Navigator.pushNamed(context, '/managers'),
      // ),
          _DashboardButton(
        icon: Icons.people,
        label: 'عرض المستخدمين',
        onTap: () => Navigator.pushNamed(context, '/users'),
      ),
      _DashboardButton(
        icon: Icons.list,
        label: 'عرض المدارس',
        onTap: () => Navigator.pushNamed(context, '/schools'),
      ),
      _DashboardButton(
        icon: Icons.warning,
        label: 'تنبيهات المدارس',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SubscriptionAlertsScreen()),
        ),
      ),
      _DashboardButton(
        icon: Icons.bar_chart,
        label: 'التقارير المالية',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaymentReportsTabs()),
        ),
      ),
      _DashboardButton(
        icon: Icons.file_download,
        label: 'تصدير التقارير',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AllPaymentsExportScreen()),
        ),
      ),
          _DashboardButton(
        icon: Icons.file_download,
        label: 'سجل التغيرات',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LogsScreen()),
        ),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: buttons,
    );
  }
}

class _DashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

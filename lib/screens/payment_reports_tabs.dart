
import 'package:flutter/material.dart';
import 'monthly_payment_report_screen.dart';
import 'yearly_payment_report_screen.dart';

class PaymentReportsTabs extends StatelessWidget {
  const PaymentReportsTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تقارير المدفوعات'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'شهري', icon: Icon(Icons.calendar_view_month)),
              Tab(text: 'سنوي', icon: Icon(Icons.calendar_today)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MonthlyPaymentReportScreen(),
            YearlyPaymentReportScreen(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../constant/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../customer/customer_report_screen.dart';
import '../customer/active_inactive_report.dart';
import 'overallTransaction.dart';

class ReportWiseScreen extends StatefulWidget {
  const ReportWiseScreen({super.key});

  @override
  State<ReportWiseScreen> createState() => _ReportWiseScreenState();
}

class _ReportWiseScreenState extends State<ReportWiseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 229, 229, 229),
      appBar: AppBar(
        backgroundColor: useColor.homeIconColor,
        title: Text("Report"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildReportBox(
              context,
              icon: FontAwesomeIcons.userXmark,
              title: "Active/Inactive Report",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActiveInactiveReportScreen(),
                  ),
                );
              },
            ),
            _buildReportBox(
              context,
              icon: FontAwesomeIcons.noteSticky,
              title: "Customer Report",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerReportScreen(),
                  ),
                );
              },
            ),
            _buildReportBox(
              context,
              icon: FontAwesomeIcons.buildingColumns,
              title: "Transaction Report",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OverallTransactionScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportBox(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: FaIcon(icon, size: 32, color: useColor.homeIconColor),
            onPressed: onTap,
          ),
          SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

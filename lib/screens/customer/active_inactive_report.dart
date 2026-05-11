import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constant/colors.dart';
import '../../providers/user.dart';
import 'customer_view.dart';

class ActiveInactiveReportScreen extends StatefulWidget {
  const ActiveInactiveReportScreen({super.key});

  @override
  State<ActiveInactiveReportScreen> createState() =>
      _ActiveInactiveReportScreenState();
}

class _ActiveInactiveReportScreenState extends State<ActiveInactiveReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> activeCustomers = [];
  List<Map<String, dynamic>> inactiveCustomers = [];
  List<Map<String, dynamic>> filteredActive = [];
  List<Map<String, dynamic>> filteredInactive = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userProvider = Provider.of<User>(context, listen: false);
      userProvider.initiliase();
      final allUsers = await userProvider.getUser() as List;

      final thirtyFiveDaysAgo =
          DateTime.now().subtract(const Duration(days: 35));

      final recentTransactions = await FirebaseFirestore.instance
          .collection('transactions')
          .where('date', isGreaterThanOrEqualTo: thirtyFiveDaysAgo)
          .get();

      final activeCustomerIds = recentTransactions.docs
          .map((doc) => doc['customerId'] as String)
          .toSet();

      activeCustomers = [];
      inactiveCustomers = [];

      for (var user in allUsers) {
        final userData = Map<String, dynamic>.from(user);
        if (activeCustomerIds.contains(userData['id'])) {
          activeCustomers.add(userData);
        } else {
          inactiveCustomers.add(userData);
        }
      }

      setState(() {
        filteredActive = activeCustomers;
        filteredInactive = inactiveCustomers;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching report data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onSearch(String query) {
    setState(() {
      filteredActive = activeCustomers
          .where((u) =>
              u['name'].toLowerCase().contains(query.toLowerCase()) ||
              u['custId'].toLowerCase().contains(query.toLowerCase()) ||
              (u['phoneNo'] ?? '').contains(query))
          .toList();
      filteredInactive = inactiveCustomers
          .where((u) =>
              u['name'].toLowerCase().contains(query.toLowerCase()) ||
              u['custId'].toLowerCase().contains(query.toLowerCase()) ||
              (u['phoneNo'] ?? '').contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        backgroundColor: useColor.homeIconColor,
        title: const Text("Active/Inactive Report"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Active"),
            Tab(text: "Inactive"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearch,
                    decoration: InputDecoration(
                      hintText: "Search customer...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                _buildSummaryBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCustomerList(filteredActive),
                      _buildCustomerList(filteredInactive),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem("Total Active", activeCustomers.length, Colors.green),
          _buildSummaryItem("Total Inactive", inactiveCustomers.length, Colors.red),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          "$count",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildCustomerList(List<Map<String, dynamic>> customers) {
    if (customers.isEmpty) {
      return const Center(child: Text("No customers found."));
    }
    return ListView.builder(
      itemCount: customers.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final user = customers[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueGrey.shade100,
              child: const Icon(Icons.person, color: Colors.blueGrey),
            ),
            title: Text(
              user['name'].toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text("ID: ${user['custId']}"),
            trailing: Text(
              "Balance: ${user['balance'].toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerViewScreen(
                    dbUser: Provider.of<User>(context, listen: false),
                    user: user,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

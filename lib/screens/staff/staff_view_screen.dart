import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constant/colors.dart';
import '../../providers/staff.dart';
import '../../providers/user.dart';
import './staff_report_screen.dart';

class StaffViewScreen extends StatefulWidget {
  StaffViewScreen({Key? key, required this.staff, required this.db})
    : super(key: key);
  Map staff;
  Staff db;

  @override
  _StaffViewScreenState createState() => _StaffViewScreenState();
}

class _StaffViewScreenState extends State<StaffViewScreen> {
  User? dbUser;
  List userList = [];
  double totalAmountNeeded = 0;
  DateTime? fromDate;
  DateTime? toDate;

  initialise() {
    setState(() {
      isLoad = false;
    });
    dbUser = User();
    dbUser!.initiliase();
    dbUser!
        .readBystaffId(widget.staff['id'], startDate: fromDate, endDate: toDate)
        .then((value) {
      setState(() {
        userList = value!;
        isLoad = true;
      });
    });
  }

  bool isLoad = false;

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: fromDate != null && toDate != null
          ? DateTimeRange(start: fromDate!, end: toDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: useColor.homeIconColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        fromDate = picked.start;
        toDate = picked.end;
      });
      initialise();
    }
  }

  @override
  void initState() {
    initialise();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: Text(
          "${widget.staff['staffName']}".toUpperCase() + "'s Customer",
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          IconButton(
            onPressed: _selectDateRange,
            icon: Icon(Icons.date_range),
          ),
          if (fromDate != null)
            IconButton(
              onPressed: () {
                setState(() {
                  fromDate = null;
                  toDate = null;
                });
                initialise();
              },
              icon: Icon(Icons.clear),
            ),
        ],
        backgroundColor: useColor.homeIconColor,
      ),
      body:
          isLoad
              ? Column(
                  children: <Widget>[
                    if (fromDate != null && toDate != null)
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        color: Colors.white,
                        child: Row(
                          children: [
                            Icon(
                              Icons.filter_list,
                              size: 16,
                              color: Colors.blueGrey,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Filter: ${DateFormat('dd-MM-yyyy').format(fromDate!)} to ${DateFormat('dd-MM-yyyy').format(toDate!)}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blueGrey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  fromDate = null;
                                  toDate = null;
                                });
                                initialise();
                              },
                              child:
                                  Icon(Icons.close, size: 16, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * .8,
                    child:
                        userList != null
                            ? userList.length > 0
                                ? ListView.builder(
                                  itemCount: userList[0].length,
                                  itemBuilder: (
                                    BuildContext context,
                                    int index,
                                  ) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            width: double.infinity,
                                            height: 1,
                                            color: Colors.blueGrey.shade100,
                                          ),
                                          ListTile(
                                            tileColor: Colors.white,
                                            title: Text(
                                              ' ${userList[0][index]['name']}'
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                            subtitle: Text(
                                              userList[0][index]['custId'],
                                            ),
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.blueGrey,
                                              child: Icon(
                                                Icons.account_box,
                                                color: Colors.white,
                                              ),
                                            ),
                                            onTap: () {},
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                )
                                : Center(
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      "No data Available",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                )
                            : Center(
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  "no users registerd",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                  ),
                  Flexible(
                    child: Container(
                      color: Colors.white,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              "Total Customer",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${userList[0].length}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
              : Center(child: CircularProgressIndicator()),
    );
  }
}

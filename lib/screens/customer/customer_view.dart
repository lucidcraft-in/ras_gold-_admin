import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../constant/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home_screen.dart';
import 'pay_amount.dart';
import 'purchase_amount.dart';
import '../../providers/user.dart';
import '../../providers/transaction.dart';
import 'setOpeningBalance.dart';
import 'update_transaction.dart';
import 'package:provider/provider.dart';

class CustomerViewScreen extends StatefulWidget {
  static const routeName = '/customer-view';
  CustomerViewScreen({Key? key, this.user, this.dbUser}) : super(key: key);
  Map? user;
  User? dbUser;

  @override
  _CustomerViewScreenState createState() => _CustomerViewScreenState();
}

class _CustomerViewScreenState extends State<CustomerViewScreen> {
  int selectedIndex = -1;
  bool isClick = false;
  TransactionProvider? db;

  List transactionList = [];
  List filteredTransactionList = [];
  List alllist = [];
  double balanceAmt = 0;
  double balancegram = 0;
  double sum = 0;
  var count = 0;
  double averageGramRate = 0;
  var _isLoading = false;
  initialise() {
    db = TransactionProvider();
    db!.initiliase();
    // print(widget.user!['id']);
    db!.read(widget.user!['id']).then((value) {
      setState(() {
        _isLoading = true;
        if (value != null) {
          alllist = value;

          transactionList = alllist[0];
          balanceAmt = (widget.user!["balance"] as num).toDouble();
          balancegram = alllist[2];
          //           for (var transaction in transactionList) {
          //             print(transaction);

          //             // Ensure "transactionType" exists and is 0
          //             if (transaction["transactionType"] == 0 &&
          //                 transaction["amount"] != null) {
          //               sum += transaction["amount"];
          //               count += 1; // Count increments per valid transaction
          //             }
          //           }

          // // Avoid division by zero
          //           setState(() {
          //             averageGramRate = (count > 0) ? (sum / count) : 0;
          //           });
        }
      });
    });
  }

  int transactionCount = 0;
  getCount(String custId) {
    print(custId);
    Provider.of<TransactionProvider>(
      context,
      listen: false,
    ).getTransactionCount(custId).then((value) {
      setState(() {
        transactionCount = value;
      });
    });
  }

  getUpdateBalance() {
    Provider.of<User>(
      context,
      listen: false,
    ).getUserBalance(widget.user!["custId"]).then((val) {
      setState(() {
        data = val;
        averageGramRate =
            double.parse(data[0]["balance"].toStringAsFixed(2)) /
            double.parse(data[0]["total_gram"].toStringAsFixed(5));

        if (averageGramRate.isInfinite || averageGramRate.isNaN) {
          setState(() {
            averageGramRate = 0;
          });
        }
        // print("--------");
        // print(averageGramRate);
      });
    });
    initialise();
  }

  List data = [];

  int staffType = 0;
  Future loginData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var Staff = jsonDecode(prefs.getString('staff')!);
      setState(() {
        staffType = Staff['type'];
      });
      getCount(widget.user!['id']);
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    loginData();

    super.initState();
    getUpdateBalance();

    // userId = ModalRoute.of(context).settings.arguments;
  }

  Future<void> _delete() async {
    try {
      try {
        Provider.of<User>(
          context,
          listen: false,
        ).delete(widget.user!['id']).then((value) {
          initialise();
          // Navigator.pushReplacement(context,
          //     MaterialPageRoute(builder: (context) => CustomerScreen()));
        });
      } catch (err) {
        // print(err);
        await showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: Text('An error occurred!'),
                content: Text('Something went wrong. ${err}'),
                actions: <Widget>[
                  OutlinedButton(
                    child: Text('Okay'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    } catch (err) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.user!['name']),
            Text(
              widget.user!['schemeType'],
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color:
                    widget.user!['schemeType'] == "Fixed"
                        ? Colors.white
                        : const Color.fromARGB(255, 244, 193, 54),
              ),
            ),
          ],
        ),

        backgroundColor: useColor.homeIconColor,
        actions: [
          if (staffType == 1)
            IconButton(
              icon: Image(
                image: AssetImage(
                  "assets/images/subscription-business-model_11869476.png",
                ),
                color: Colors.white,
              ),
              onPressed: () {
                _showCloseCustomerDialog(context);
              },
            ),
        ],
        // actions: [
        // staffType != 0
        //     ?
        // PopupMenuButton(
        //   icon: Icon(Icons.settings),
        //   itemBuilder: (BuildContext context) {
        //     return [
        //       PopupMenuItem(
        //         child: GestureDetector(
        //             onTap: () {
        //               Navigator.pushReplacement(
        //                   context,
        //                   MaterialPageRoute(
        //                       builder: (context) =>
        //                           UpdateCustomerScreen(
        //                               db: widget.dbUser,
        //                               user: widget.user)));
        //             },
        //             child: ListTile(
        //               leading: Icon(
        //                 Icons.edit,
        //                 color: Colors.blueGrey,
        //               ),
        //               title: Text("Edit"),
        //             )),
        //       ),
        //       PopupMenuItem(
        //         child: GestureDetector(
        //             onTap: () {
        //               // Navigator.push(
        //               //     context,
        //               //     MaterialPageRoute(
        //               //         builder: (context) =>
        //               //             UpdateCustomerScreen(
        //               //                 db: widget.dbUser,
        //               //                 user: widget.user)));
        //             },
        //             child: GestureDetector(
        //               onTap: () {
        //                 showDialog(
        //                     context: context,
        //                     builder: (context) {
        //                       return AlertDialog(
        //                         content: Container(
        //                           width: 300,
        //                           height: 100,
        //                           child: Column(
        //                             mainAxisAlignment:
        //                                 MainAxisAlignment.spaceAround,
        //                             crossAxisAlignment:
        //                                 CrossAxisAlignment.start,
        //                             children: [
        //                               Text(
        //                                   "Do You Want To Delete...!"),
        //                               Row(
        //                                 mainAxisAlignment:
        //                                     MainAxisAlignment.end,
        //                                 children: [
        //                                   GestureDetector(
        //                                       onTap: () {
        //                                         Navigator.pop(
        //                                             context);
        //                                       },
        //                                       child: Text("Cancel")),
        //                                   SizedBox(
        //                                     width: 20,
        //                                   ),
        //                                   GestureDetector(
        //                                       onTap: () {
        //                                         _delete();
        //                                       },
        //                                       child: Text("Ok"))
        //                                 ],
        //                               )
        //                             ],
        //                           ),
        //                         ),
        //                       );
        //                     });
        //               },
        //               child: ListTile(
        //                 leading: Icon(
        //                   Icons.delete_forever,
        //                   color: Colors.red,
        //                 ),
        //                 title: Text("Delete"),
        //               ),
        //             )),
        //       ),
        //     ];
        //   })
        // Container()
        // : Container()
        // ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(15),
              child: Container(
                width: double.infinity,
                // height: MediaQuery.of(context).size.height * .2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    width: 1.0,
                    color: Colors.blueGrey.shade200,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * .1,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    "Available balance is",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontFamily: 'latto',
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.piggyBank,
                                        size: 17,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        data.isNotEmpty
                                            ? data[0]["balance"]
                                                .toStringAsFixed(2)
                                            : 0.0.toString(),
                                        // alllist.isNotEmpty
                                        //     ? " + ₹ ${balanceAmt.toString()}"
                                        //     : " + ₹ 00",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'latto',
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: Container(
                              width: 1,
                              height: 100,
                              color: Colors.black12,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    "Total Gram ",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontFamily: 'latto',
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.coins,
                                        size: 17,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        data.isNotEmpty
                                            ? data[0]["total_gram"]
                                                .toStringAsFixed(3)
                                            : 0.toString(),
                                        // alllist != null
                                        //     ? " ${balancegram.toStringAsFixed(3)}"
                                        //     : "0.00",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'latto',
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    staffType == 1
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .32,
                              height: MediaQuery.of(context).size.width * .1,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => PayAmountScreen(
                                            user: widget.user!,
                                            dbUser: widget.dbUser!,
                                            userid: widget.user!['id'],
                                            custName: widget.user!['name'],
                                            token: widget.user!['token'],
                                            balance: balanceAmt.toDouble(),
                                          ),
                                    ),
                                  ).then((value) {
                                    if (value == true) {
                                      setState(() {
                                        getUpdateBalance();
                                      });
                                    }
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    Colors.white,
                                  ),
                                  shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder
                                  >(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                      side: BorderSide(color: Colors.green),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  // Replace with a Row for horizontal icon + text
                                  children: <Widget>[
                                    Icon(
                                      Icons.arrow_downward,
                                      color: Colors.green,
                                    ),
                                    Text(
                                      "Reciept",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * .32,
                              height: MediaQuery.of(context).size.width * .1,
                              child: ElevatedButton(
                                onPressed: () {
                                  // print(data[0]["total_gram"].runtimeType);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => PurchaseAmountScreen(
                                            avgGrmRate: averageGramRate,
                                            depositAmt: data[0]["balance"],
                                            user: widget.user!,
                                            dbUser: widget.dbUser!,
                                            userid: widget.user!['id'],
                                            token: widget.user!['token'],
                                            balance: balanceAmt,
                                            custName: widget.user!['name'],
                                            totalGram: data[0]["total_gram"],
                                            // totalGram: double.parse(
                                            //     data[0]["total_gram"]),
                                          ),
                                    ),
                                  ).then((value) {
                                    if (value == true) {
                                      setState(() {
                                        getUpdateBalance();
                                      });
                                    }
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    Colors.white,
                                  ),
                                  shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder
                                  >(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                      side: BorderSide(color: Colors.red),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  // Replace with a Row for horizontal icon + text
                                  children: <Widget>[
                                    Icon(Icons.arrow_upward, color: Colors.red),
                                    Text(
                                      "Purchase",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                        : Container(
                          width: MediaQuery.of(context).size.width * .32,
                          height: MediaQuery.of(context).size.width * .1,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => PayAmountScreen(
                                        user: widget.user!,
                                        dbUser: widget.dbUser!,
                                        userid: widget.user!['id'],
                                        custName: widget.user!['name'],
                                        token: widget.user!['token'],
                                        balance: balanceAmt.toDouble(),
                                      ),
                                ),
                              ).then((value) {
                                if (value == true) {
                                  setState(() {
                                    getUpdateBalance();
                                  });
                                }
                              });
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                Colors.white,
                              ),
                              shape: MaterialStateProperty.all<
                                RoundedRectangleBorder
                              >(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  side: BorderSide(color: Colors.green),
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              // Replace with a Row for horizontal icon + text
                              children: <Widget>[
                                Icon(Icons.arrow_downward, color: Colors.green),
                                Text(
                                  "Reciept",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    SizedBox(height: 20),
                    // if (data.isNotEmpty)
                    //   if (data[0]["balance"] != 0)
                    //     Container(
                    //       width: MediaQuery.of(context).size.width * .32,
                    //       height: MediaQuery.of(context).size.width * .1,
                    //       child: ElevatedButton(
                    //         onPressed: () {
                    //           Navigator.push(
                    //               context,
                    //               MaterialPageRoute(
                    //                   builder: (context) => TransactionForm(
                    //                         user: widget.user!,
                    //                         dbUser: widget.dbUser!,
                    //                         userid: widget.user!['id'],
                    //                         token: widget.user!['token'],
                    //                         balance: balanceAmt.toDouble(),
                    //                         custName: widget.user!['name'],
                    //                       ))).then((value) {
                    //             if (value == true) {
                    //               setState(() {
                    //                 getUpdateBalance();
                    //               });
                    //             }
                    //           });
                    //         },
                    //         style: ButtonStyle(
                    //             backgroundColor:
                    //                 MaterialStateProperty.all(Colors.white),
                    //             shape: MaterialStateProperty.all<
                    //                     RoundedRectangleBorder>(
                    //                 RoundedRectangleBorder(
                    //                     borderRadius:
                    //                         BorderRadius.circular(15.0),
                    //                     side: BorderSide(
                    //                       color: Color.fromARGB(
                    //                           255, 210, 111, 36),
                    //                     )))),
                    //         child: Row(
                    //           mainAxisAlignment:
                    //               MainAxisAlignment.spaceEvenly,
                    //           // Replace with a Row for horizontal icon + text
                    //           children: <Widget>[
                    //             Icon(
                    //               Icons.discount,
                    //               color: Color.fromARGB(255, 210, 111, 36),
                    //             ),
                    //             Text(
                    //               "Discount",
                    //               style: TextStyle(
                    //                   color: Colors.black,
                    //                   fontSize: 14,
                    //                   fontWeight: FontWeight.w500),
                    //             )
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    // if (data.isNotEmpty)
                    //   if (data[0]["balance"] != 0) SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: useColor.homeIconColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Average Gram Rate: ${averageGramRate.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child:
                      alllist.isNotEmpty
                          ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: transactionList.length,
                            itemBuilder: (BuildContext context, int index) {
                              DateTime myDateTime =
                                  (transactionList[index]['date']).toDate();
                              // print(myDateTime);
                              // String formattedDate = DateFormat('dd/MM/yyyy')
                              //     .format(transactionList[index]['date']);
                              // Transaction details section
                              return GestureDetector(
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      // Date Time Header
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(14),
                                          ),
                                        ),
                                        child: Text(
                                          DateFormat.yMMMd().add_jm().format(
                                            myDateTime,
                                          ),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),

                                      // Heading
                                      Container(
                                        padding: EdgeInsets.all(15),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor:
                                                  transactionList[index]['transactionType'] ==
                                                          0
                                                      ? Colors.green.shade100
                                                      : Colors.red.shade100,
                                              child: Icon(
                                                transactionList[index]['transactionType'] ==
                                                        0
                                                    ? Icons.add
                                                    : Icons.remove,
                                                color:
                                                    transactionList[index]['transactionType'] ==
                                                            0
                                                        ? Colors.green
                                                        : Colors.red,
                                              ),
                                            ),
                                            SizedBox(width: 12),

                                            Expanded(
                                              child: Text(
                                                transactionList[index]['note']
                                                    .toString()
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),

                                            Text(
                                              "${transactionList[index]['gramWeight'].toStringAsFixed(3)} gm",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Divider(height: 1),

                                      // Transaction Details Heading
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 10,
                                        ),
                                        child: Text(
                                          "Transaction Details",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ),

                                      // Details
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 15,
                                        ),
                                        child: Column(
                                          children: [
                                            detailRow(
                                              "Gram Price",
                                              "${transactionList[index]['gramPriceInvestDay']}",
                                            ),

                                            detailRow(
                                              "Received Amount",
                                              "₹ ${transactionList[index]['amount'].toStringAsFixed(2)}",
                                            ),

                                            detailRow(
                                              "Weight",
                                              "${transactionList[index]['gramWeight'].toStringAsFixed(3)} gm",
                                            ),

                                            detailRow(
                                              "Payment Mode",
                                              "${transactionList[index]['transactionMode']}",
                                            ),

                                            detailRow(
                                              "Invoice No",
                                              "${transactionList[index]['merchentTransactionId']}",
                                            ),

                                            detailRow(
                                              "Note",
                                              "${transactionList[index]['note']}",
                                            ),
                                          ],
                                        ),
                                      ),

                                      Divider(),

                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Paid Amount",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              "₹ ${transactionList[index]['amount'].toStringAsFixed(2)}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                          : Text("No Data Available...."),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
 // Detail Row Widget for Transaction details
  Widget detailRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showCloseCustomerDialog(BuildContext context) {
    DateTime? selectedDate = DateTime.now(); // Initial selected date

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Close Customer'),
              content: Container(
                height: MediaQuery.of(context).size.height * .25,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Are you sure you want to close this customer?'),
                    SizedBox(height: 10),
                    Text("Customer Name: ${widget.user!['name']}"),
                    Text("Customer Balance: ${data[0]["balance"]}"),
                    SizedBox(height: 10),
                    // Select Date button and display selected date
                    TextButton(
                      onPressed: () async {
                        // DateTime? pickedDate = await showDatePicker(
                        //   context: context,
                        //   initialDate: DateTime.now(),
                        //   firstDate: DateTime(2000),
                        //   lastDate: DateTime(2101),
                        // );
                        // if (pickedDate != null) {
                        //   setState(() {
                        //     selectedDate = pickedDate;
                        //   });
                        // }
                      },
                      child: Text(
                        selectedDate == null
                            ? 'Select Closing Date'
                            : 'Closing Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}',
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
                TextButton(
                  child: Text('Confirm'),
                  onPressed: () {
                    Provider.of<User>(context, listen: false).upldateCloseUser(
                      widget.user!['id'],
                      data[0]["balance"],
                      data[0]["total_gram"],
                      selectedDate!,
                    ); // Pass the selected date instead of DateTime.now()
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (BuildContext context) => HomeScreen(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

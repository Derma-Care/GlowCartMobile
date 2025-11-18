// import 'package:cutomer_app/Utils/Header.dart';
// import 'package:flutter/material.dart';
// import 'package:upi_india/upi_india.dart';

// class UpiPaymentPage extends StatefulWidget {
//   final double amount;
//   const UpiPaymentPage({Key? key, required this.amount}) : super(key: key);

//   @override
//   _UpiPaymentPageState createState() => _UpiPaymentPageState();
// }

// class _UpiPaymentPageState extends State<UpiPaymentPage> {
//   UpiIndia _upiIndia = UpiIndia();
//   late Future<List<UpiApp>> apps;

//   final String upiId = "9148986699@ybl"; // Replace with your real UPI ID

//   @override
//   void initState() {
//     super.initState();
//     apps = _upiIndia.getAllUpiApps(mandatoryTransactionId: false);

//     // Automatically open UPI app list when the page loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       showUpiApps();
//     });
//   }

//   void _startTransaction(UpiApp app) async {
//     try {
//       UpiResponse response = await _upiIndia.startTransaction(
//         app: app,
//         receiverUpiId: upiId,
//         receiverName: "Clinic Payment",
//         transactionRefId: "TXN-${DateTime.now().millisecondsSinceEpoch}",
//         transactionNote: "Clinic Consultation",
//         amount: widget.amount,
//       );

//       showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: Text("Payment Status"),
//           content: Text(
//             "Status: \${response.status}\nTransaction ID: \${response.transactionId ?? 'N/A'}",
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text("OK"),
//             )
//           ],
//         ),
//       );
//     } catch (e) {
//       showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: Text("Error"),
//           content: Text(
//             "Transaction failed.\nYou can also pay manually to:\n\nUPI ID: $upiId\nAmount: ₹\${widget.amount}",
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text("OK"),
//             )
//           ],
//         ),
//       );
//     }
//   }

//   void showUpiApps() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => DraggableScrollableSheet(
//         expand: false,
//         initialChildSize: 0.5,
//         minChildSize: 0.4,
//         maxChildSize: 0.9,
//         builder: (context, scrollController) {
//           return FutureBuilder<List<UpiApp>>(
//             future: apps,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Center(child: CircularProgressIndicator());
//               }

//               if (snapshot.hasError) {
//                 return Center(child: Text("Error: \${snapshot.error}"));
//               }

//               if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                 return Center(child: Text("No UPI apps found"));
//               }

//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Row(
//                       children: [
//                         Icon(Icons.account_balance_wallet_rounded, size: 28),
//                         SizedBox(width: 10),
//                         Text(
//                           "Choose UPI App",
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: ListView.separated(
//                       controller: scrollController,
//                       itemCount: snapshot.data!.length,
//                       separatorBuilder: (_, __) => Divider(height: 1),
//                       itemBuilder: (context, index) {
//                         final app = snapshot.data![index];
//                         return ListTile(
//                           leading: Image.memory(app.icon, height: 40),
//                           title: Text(app.name),
//                           trailing: Icon(Icons.arrow_forward_ios, size: 16),
//                           onTap: () {
//                             Navigator.pop(context);
//                             _startTransaction(app);
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CommonHeader(
//         title: "UPI Payment",
//       ),
//       body: const Center(
//         child: Text("Fetching UPI Apps..."),
//       ),
//     );
//   }
// }

// import 'package:csc_picker/csc_picker.dart';
// import 'package:flutter/material.dart';
 
 

// class StateAndCity extends StatefulWidget {
//   StateAndCity({Key? key, required this.title}) : super(key: key);

//   final String title;

//   @override
//   _StateAndCityState createState() => _StateAndCityState();
// }

// class _StateAndCityState extends State<StateAndCity> {
//   /// Variables to store country, state, city data.
//   String? countryValue = "";
//   String? stateValue = "";
//   String? cityValue = "";
//   String? address = "";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 20),
//           height: 600,
//           child: Column(
//             children: [
//               /// Adding CSC Picker Widget in app
//               CSCPicker(
//                 /// Enable/disable state dropdown (OPTIONAL)
//                 showStates: true,

//                 /// Enable/disable city dropdown (OPTIONAL)
//                 showCities: true,

//                 /// Enable/disable flag with country name in dropdown (OPTIONAL)
//                 flagState: CountryFlag.DISABLE,

//                 /// Styling for dropdown box
//                 dropdownDecoration: BoxDecoration(
//                   borderRadius: BorderRadius.all(Radius.circular(10)),
//                   color: Colors.white,
//                   border: Border.all(color: Colors.grey.shade300, width: 1),
//                 ),

//                 /// Styling for disabled dropdown box
//                 disabledDropdownDecoration: BoxDecoration(
//                   borderRadius: BorderRadius.all(Radius.circular(10)),
//                   color: Colors.grey.shade300,
//                   border: Border.all(color: Colors.grey.shade300, width: 1),
//                 ),

//                 /// Placeholder texts for dropdown search field
//                 countrySearchPlaceholder: "Country",
//                 stateSearchPlaceholder: "State",
//                 citySearchPlaceholder: "City",

//                 /// Labels for dropdowns
//                 countryDropdownLabel: "*Country",
//                 stateDropdownLabel: "*State",
//                 cityDropdownLabel: "*City",

//                 /// Filter for countries (optional)
//                 countryFilter: [
//                   CscCountry.India,
//                   CscCountry.United_States,
//                   CscCountry.Canada
//                 ],

//                 /// Selected item style
//                 selectedItemStyle: TextStyle(
//                   color: Colors.black,
//                   fontSize: 14,
//                 ),

//                 /// Dropdown dialog heading style
//                 dropdownHeadingStyle: TextStyle(
//                   color: Colors.black,
//                   fontSize: 17,
//                   fontWeight: FontWeight.bold,
//                 ),

//                 /// Dropdown item style
//                 dropdownItemStyle: TextStyle(
//                   color: Colors.black,
//                   fontSize: 14,
//                 ),

//                 /// Radius for dropdown dialog
//                 dropdownDialogRadius: 10.0,

//                 /// Radius for search bar
//                 searchBarRadius: 10.0,

//                 /// Triggered when country is selected
//                 onCountryChanged: (value) {
//                   setState(() {
//                     countryValue = value;
//                   });
//                 },

//                 /// Triggered when state is selected
//                 onStateChanged: (value) {
//                   setState(() {
//                     stateValue = value;
//                   });
//                 },

//                 /// Triggered when city is selected
//                 onCityChanged: (value) {
//                   setState(() {
//                     cityValue = value;
//                   });
//                 },
//               ),

//               /// Print newly selected country, state, and city in Text Widget
//               TextButton(
//                 onPressed: () {
//                   setState(() {
//                     address = "$cityValue, $stateValue, $countryValue";
//                   });
//                 },
//                 child: Text("Print Data"),
//               ),
//               Text(address!)
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

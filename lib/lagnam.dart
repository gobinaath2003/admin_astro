// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:testadm/sidebar/sidebar.dart';

// class Lagnam extends StatefulWidget {
//   @override
//   _LagnamScreenState createState() => _LagnamScreenState();
// }

// class _LagnamScreenState extends State<Lagnam> {
//   final List<String> planets = [
//     'அனைத்து லக்னம்',
//     'மேஷம் லக்னம்',
//     'ரிஷபம் லக்னம்',
//     'மிதுனம் லக்னம்',
//     'கடகம் லக்னம்',
//     'சிம்மம் லக்னம்',
//     'கன்னி லக்னம்',
//     'துலாம் லக்னம்',
//     'விருச்சிகம் லக்னம்',
//     'தனுசு லக்னம்',
//     'மகரம் லக்னம்',
//     'கும்பம் லக்னம்',
//     'மீனம் லக்னம்',
//   ];

//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   final TextEditingController noteController = TextEditingController();
//   final ValueNotifier<String> selectedLagnam = ValueNotifier<String>('அனைத்து லக்னம்');

//   Future<void> addDataToFirestore(String planetName, String note) async {
//     await FirebaseFirestore.instance.collection('lagnam').add({
//       'lagnam': planetName,
//       'notes': note,
//       'timestamp': Timestamp.now(),
//     });
//   }

//   Future<void> updateNote(String docId, String newNote) async {
//     await FirebaseFirestore.instance.collection('lagnam').doc(docId).update({
//       'notes': newNote,
//     });
//   }

//   Future<void> deleteNote(String docId) async {
//     await FirebaseFirestore.instance.collection('lagnam').doc(docId).delete();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isLargeScreen = screenWidth >= 800;

//     return Scaffold(
//       key: _scaffoldKey,
//       drawer: isLargeScreen ? null : Sidebar(),
//       body: SafeArea(
//         child: Row(
//           children: [
//             if (isLargeScreen)
//               Container(width: screenWidth * 0.15, child: Sidebar()),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(30.0),
//                 child: Column(
//                   children: [
//                     if (!isLargeScreen)
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: IconButton(
//                           icon: Icon(Icons.menu, color: Colors.orange),
//                           onPressed: () => _scaffoldKey.currentState?.openDrawer(),
//                         ),
//                       ),
//                     Row(
//                       children: [
//                         Expanded(
//                           flex: 2,
//                           child: Container(
//                             padding: EdgeInsets.symmetric(horizontal: 16),
//                             decoration: BoxDecoration(
//                               color: const Color.fromARGB(255, 229, 188, 127),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: DropdownButtonHideUnderline(
//                               child: ValueListenableBuilder<String>(
//                                 valueListenable: selectedLagnam,
//                                 builder: (context, value, child) {
//                                   return DropdownButton<String>(
//                                     value: value,
//                                     onChanged: (newValue) {
//                                       if (newValue != null) {
//                                         selectedLagnam.value = newValue;
//                                       }
//                                     },
//                                     items: planets.map((planet) {
//                                       return DropdownMenuItem(
//                                         value: planet,
//                                         child: Text(planet),
//                                       );
//                                     }).toList(),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 10),
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Color.fromARGB(255, 209, 134, 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           onPressed: () async {
//                             final planet = selectedLagnam.value;
//                             final note = noteController.text.trim();

//                             if (planet != 'அனைத்து லக்னம்' && note.isNotEmpty) {
//                               try {
//                                 await addDataToFirestore(planet, note);
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(content: Text('$planet வெற்றிகரமாக சேர்க்கப்பட்டது!')),
//                                 );
//                                 noteController.clear();
//                               } catch (e) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(content: Text('தவறு: ${e.toString()}')),
//                                 );
//                               }
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text('தயவுசெய்து ஒரு லக்னத்தை தேர்வு செய்து குறிப்பை உள்ளிடவும்'),
//                                 ),
//                               );
//                             }
//                           },
//                           child: Text("சேர்", style: TextStyle(color: Colors.white)),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: TextField(
//                         controller: noteController,
//                         maxLines: null,
//                         decoration: InputDecoration(
//                           hintText: "குறிப்பு சேர்க்கவும்",
//                           border: InputBorder.none,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 30),
//                     Expanded(
//                       child: ValueListenableBuilder<String>(
//                         valueListenable: selectedLagnam,
//                         builder: (context, currentLagnam, _) {
//                           return StreamBuilder<QuerySnapshot>(
//                             stream: FirebaseFirestore.instance
//                                 .collection('lagnam')
//                                 .orderBy('timestamp', descending: true)
//                                 .snapshots(),
//                             builder: (context, snapshot) {
//                               if (snapshot.connectionState == ConnectionState.waiting) {
//                                 return Center(child: CircularProgressIndicator());
//                               }

//                               if (!snapshot.hasData) {
//                                 return Center(child: Text("தரவு கிடைக்கவில்லை"));
//                               }

//                               final allNotes = snapshot.data!.docs;
//                               final filteredNotes = currentLagnam == 'அனைத்து லக்னம்'
//                                   ? allNotes
//                                   : allNotes
//                                       .where((doc) => doc['lagnam'] == currentLagnam)
//                                       .toList();

//                               if (filteredNotes.isEmpty) {
//                                 return Center(child: Text("தேர்வு செய்த லக்னத்திற்கு தரவு இல்லை"));
//                               }

//                               return SingleChildScrollView(
//                                 scrollDirection: Axis.horizontal,
//                                 child: SingleChildScrollView(
//                                   scrollDirection: Axis.vertical,
//                                   child: Table(
//                                     border: TableBorder.all(color: Colors.black),
//                                     columnWidths: {
//                                       0: FixedColumnWidth(200),
//                                       1: FixedColumnWidth(200),
//                                       2: FixedColumnWidth(200),
//                                     },
//                                     children: [
//                                       TableRow(
//                                         decoration: BoxDecoration(
//                                           color: Color.fromARGB(255, 229, 188, 127),
//                                         ),
//                                         children: [
//                                           _buildTableHeader("பார்வை எண்"),
//                                           _buildTableHeader("குறிப்பு"),
//                                           _buildTableHeader("செயல்கள்"),
//                                         ],
//                                       ),
//                                       ...filteredNotes.asMap().entries.map((entry) {
//                                         final index = entry.key + 1;
//                                         final doc = entry.value;
//                                         final data = doc.data() as Map<String, dynamic>;
//                                         final docId = doc.id;

//                                         return TableRow(
//                                           children: [
//                                             Padding(
//                                               padding: EdgeInsets.all(8.0),
//                                               child: Text('$index'),
//                                             ),
//                                             Padding(
//                                               padding: EdgeInsets.all(8.0),
//                                               child: Text(data['notes'] ?? '', softWrap: true),
//                                             ),
//                                             Padding(
//                                               padding: EdgeInsets.all(8.0),
//                                               child: Row(
//                                                 children: [
//                                                   IconButton(
//                                                     icon: Icon(Icons.edit, color: Colors.blue),
//                                                     onPressed: () {
//                                                       final editController = TextEditingController(text: data['notes']);
//                                                       showDialog(
//                                                         context: context,
//                                                         builder: (context) => AlertDialog(
//                                                           title: Text("சரியான குறிப்பை திருத்தவும்"),
//                                                           content: TextField(
//                                                             controller: editController,
//                                                             maxLines: null,
//                                                           ),
//                                                           actions: [
//                                                             TextButton(
//                                                               child: Text("ரத்து செய்"),
//                                                               onPressed: () => Navigator.pop(context),
//                                                             ),
//                                                             ElevatedButton(
//                                                               child: Text("புதுப்பி"),
//                                                               onPressed: () async {
//                                                                 final newNote = editController.text.trim();
//                                                                 if (newNote.isNotEmpty) {
//                                                                   await updateNote(docId, newNote);
//                                                                   Navigator.pop(context);
//                                                                 }
//                                                               },
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       );
//                                                     },
//                                                   ),
//                                                   IconButton(
//                                                     icon: Icon(Icons.delete, color: Colors.red),
//                                                     onPressed: () {
//                                                       showDialog(
//                                                         context: context,
//                                                         builder: (context) => AlertDialog(
//                                                           title: Text("குறிப்பை அழிக்கவும்"),
//                                                           content: Text("நிச்சயமாக அழிக்க விரும்புகிறீர்களா?"),
//                                                           actions: [
//                                                             TextButton(
//                                                               child: Text("ரத்து செய்"),
//                                                               onPressed: () => Navigator.pop(context),
//                                                             ),
//                                                             ElevatedButton(
//                                                               child: Text("அழி"),
//                                                               onPressed: () async {
//                                                                 await deleteNote(docId);
//                                                                 Navigator.pop(context);
//                                                               },
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       );
//                                                     },
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         );
//                                       }).toList(),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTableHeader(String text) {
//     return Padding(
//       padding: EdgeInsets.all(8.0),
//       child: Text(
//         text,
//         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
//       ),
//     );
//   }
// }

import 'package:abtms/widgets/my_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class MyHealthHistoryPage extends StatefulWidget {
  @override
  _MyHealthHistoryPageState createState() => _MyHealthHistoryPageState();
}

class _MyHealthHistoryPageState extends State<MyHealthHistoryPage> {
  String formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return DateFormat('d MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'History',
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('patients')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('measurements')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: SpinKitThreeBounce(
                    size: 20,
                    color: Color(0xFF343F9B),
                  ),);
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No measurements found.'));
          }

          // Group measurements by date
          Map<String, List<QueryDocumentSnapshot>> groupedMeasurements = {};
          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            var timestamp = data['timestamp'] as Timestamp?;
            if (timestamp != null) {
              String dateKey =
                  DateFormat('yyyy-MM-dd').format(timestamp.toDate());
              if (!groupedMeasurements.containsKey(dateKey)) {
                groupedMeasurements[dateKey] = [];
              }
              groupedMeasurements[dateKey]!.add(doc);
            }
          }

          if (groupedMeasurements.isEmpty) {
            return Center(child: Text('No valid measurements found.'));
          }

          return ListView.builder(
            itemCount: groupedMeasurements.length,
            itemBuilder: (context, index) {
              String dateKey = groupedMeasurements.keys.elementAt(index);
              String formattedDate = formatDate(dateKey);
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blueGrey[50],
                  ),
                  child: ListTile(
                    title: Text(
                      formattedDate,
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                    ),
                    subtitle: Container(
                      alignment: Alignment.centerLeft,
                      height: 40,
                      child: Text(
                        '${groupedMeasurements[dateKey]!.length} measurements',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailedMeasurementsPage(
                            date: formattedDate,
                            measurements: groupedMeasurements[dateKey]!,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DetailedMeasurementsPage extends StatelessWidget {
  final String date;
  final List<QueryDocumentSnapshot> measurements;

  DetailedMeasurementsPage({required this.date, required this.measurements});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(date),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(CupertinoIcons.back),
        ),
      ),
      body: ListView.builder(
        itemCount: measurements.length,
        itemBuilder: (context, index) {
          var data = measurements[index].data() as Map<String, dynamic>;
          var timestamp = data['timestamp'] as Timestamp?;

          if (timestamp == null) {
            return Card(
              margin: EdgeInsets.all(8.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Invalid measurement data'),
              ),
            );
          }

          return Card(
            elevation: 0,
            color: Colors.grey[100],
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Time: ${DateFormat('hh:mm:ss a').format(timestamp.toDate())}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      color: Color(0xFF343F9B),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Heart Rate: ${data['heartrate'] ?? 'N/A'} BPM',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'SpO2: ${data['spo2'] ?? 'N/A'}%',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Temperature: ${data['temperature'] ?? 'N/A'}°C',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class PatientHistoryPage extends StatelessWidget {
  final String patientId; // Add patientId to the constructor
  final Map<String, dynamic> patientData;

  const PatientHistoryPage({
    Key? key,
    required this.patientId, // Make this required
    required this.patientData,
  }) : super(key: key);

  String formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return DateFormat('d MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        leadingWidth: screenWidth * 0.7,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(CupertinoIcons.back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: patientData['profileImage'] != null &&
                          patientData['profileImage'].isNotEmpty
                      ? NetworkImage(patientData['profileImage'])
                      : null,
                  child: patientData['profileImage'] == null ||
                          patientData['profileImage'].isEmpty
                      ? const Icon(
                          Icons.person_outline,
                          size: 22.0,
                          color: Color(0xFF3E4D99),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    // Navigate to patient details page
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientData['username'] ?? '',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3E4D99),
                        ),
                      ),
                      const Text(
                        "Tap to view details",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('patients')
            .doc(patientData['id']) // Use the patient's document ID here
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

          return Card(
            elevation: 0,
            color: Colors.blueGrey[50],
            margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Time: ${DateFormat('hh:mm:ss a').format(timestamp!.toDate())}',
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

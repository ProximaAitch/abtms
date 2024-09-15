import 'package:abtms/widgets/my_widgets.dart';
import 'package:abtms/health_screens/patients/patient_history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PatientsPage extends StatefulWidget {
  PatientsPage({Key? key}) : super(key: key);

  @override
  _PatientsPageState createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<DocumentSnapshot> _allPatients = [];
  String? _providerCode;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _getProviderCode();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _getProviderCode() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot providerDoc = await _firestore
            .collection('healthcare_providers')
            .doc(user.uid)
            .get()
            .timeout(Duration(seconds: 10));
        if (providerDoc.exists) {
          setState(() {
            _providerCode = providerDoc['hCode'];
          });
        } else {
          throw Exception('Provider document does not exist');
        }
      } catch (e) {
        print('Error fetching provider code: $e');
        throw Exception('Failed to fetch provider code');
      }
    } else {
      throw Exception('User not authenticated');
    }
  }

  void _filterPatients(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: const HealthMonitoringAppbar(),
        body: _buildLoadingIndicator(),
      );
    } else if (_error != null) {
      return Scaffold(
        appBar: const HealthMonitoringAppbar(),
        body: Center(child: Text('Error: $_error')),
      );
    } else {
      return Scaffold(
        appBar: const HealthMonitoringAppbar(),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _buildPatientListStream(),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search patients...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          contentPadding: EdgeInsets.all(10),
        ),
        onChanged: _filterPatients,
      ),
    );
  }

  Widget _buildPatientListStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('patients')
          .where('hCode', isEqualTo: _providerCode)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        } else if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          _allPatients = snapshot.data!.docs;
          return _buildFilteredPatientList();
        } else {
          return Center(child: Text('No patients found.'));
        }
      },
    );
  }

  Widget _buildFilteredPatientList() {
    List<DocumentSnapshot> filteredPatients = _allPatients.where((patient) {
      Map<String, dynamic> patientData = patient.data() as Map<String, dynamic>;
      return patientData['fullName']
          .toString()
          .toLowerCase()
          .contains(_searchQuery);
    }).toList();

    if (filteredPatients.isEmpty) {
      return Center(child: Text('No patients found.'));
    } else {
      return RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: filteredPatients.length,
          itemBuilder: (context, index) {
            return _buildPatientCard(filteredPatients[index]);
          },
        ),
      );
    }
  }

  Widget _buildPatientCard(DocumentSnapshot patient) {
    Map<String, dynamic> patientData = patient.data() as Map<String, dynamic>;
    Widget profileImageWidget = _buildProfileImage(patientData);

    return GestureDetector(
      onTap: () => _navigateToPatientHistory(patientData),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: const Color.fromRGBO(224, 224, 224, 1),
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Hero(
                  tag: 'profileImage-${patientData['username']}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: 88,
                      height: 85,
                      child: profileImageWidget,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientData['fullName'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            patientData['mobileNo'],
                            style: const TextStyle(fontSize: 15),
                          ),
                          SizedBox(width: 16),
                          Text(
                            patientData['gender'],
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {},
                    child: Text("Details"),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _navigateToPatientHistory(patientData),
                    child: Text("History"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(Map<String, dynamic> patientData) {
    if (patientData['profileImage'] != null &&
        patientData['profileImage'].isNotEmpty) {
      return Image.network(
        patientData['profileImage'],
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    } else {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return CircleAvatar(
      child: Icon(
        EneftyIcons.user_outline,
        size: 50.0,
        color: Color(0xFF3E4D99),
      ),
    );
  }

  void _navigateToPatientHistory(Map<String, dynamic> patientData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientHistoryPage(patientData: patientData),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: SpinKitThreeBounce(
        color: Color(0xFF3E4D99),
        size: 20.0,
      ),
    );
  }
}

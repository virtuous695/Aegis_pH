import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Dashboard.dart';
import 'package:pie_chart/pie_chart.dart';

class PhPage extends StatefulWidget {
  final double maxPh = 14.0;
  final dbref = FirebaseDatabase.instance.ref();
  final String deviceId; // Tambahkan deviceId di sini

  PhPage({Key? key, required this.deviceId}) : super(key: key);

  @override
  _PhPageState createState() => _PhPageState();
}

class _PhPageState extends State<PhPage> {
  double? phValue;
  String result = "-";
  String explanation = "Connect Your Device!";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    widget.dbref.child("esp32/sensor_ph").onValue.listen((event) {
      setState(() {
        phValue = double.tryParse(event.snapshot.value.toString());
        phValue = phValue != null
            ? (phValue! > widget.maxPh ? widget.maxPh : phValue)
            : null;

        if (phValue != null) {
          if (phValue! < 4.0) {
            result = "Sangat Asam";
            explanation =
                "Air yang sangat asam, mungkin disebabkan oleh polusi asam seperti limbah pertambangan atau industri.";
          } else if (phValue! >= 4.0 && phValue! <= 5.5) {
            result = "Asam";
            explanation =
                "Air yang asam, bisa menjadi tidak sehat bagi kehidupan akuatik dan tumbuhan air.";
          } else if (phValue! > 5.5 && phValue! <= 7.5) {
            result = "Netral";
            explanation =
                "pH air yang seimbang, cocok untuk kehidupan akuatik dan tumbuhan air.";
          } else if (phValue! > 7.5 && phValue! <= 9.0) {
            result = "Basa";
            explanation =
                "Air basa, bisa menjadi habitat bagi beberapa organisme akuatik.";
          } else if (phValue! > 9.0) {
            result = "Sangat Basa";
            explanation =
                "Air yang sangat basa, dapat merusak kehidupan akuatik dan tumbuhan air.";
          }
        }
      });
    });
  }

  Future<void> refreshData() async {
    setState(() {
      isLoading = true;
    });
    await Future.delayed(
        Duration(milliseconds: 1500)); // Simulate loading delay
    await fetchData();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detection pH',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF1A499B),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            // Add Center widget around the content
            child: isLoading
                ? CircularProgressIndicator() // Show loading indicator
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (phValue != null)
                        PieChart(
                          dataMap: {
                            "pH value": phValue!,
                            "Remaining": widget.maxPh - phValue!,
                          },
                          chartType: ChartType.ring,
                          ringStrokeWidth: 32,
                          colorList: [
                            Colors.blue.withOpacity(1.0),
                            const Color.fromARGB(128, 82, 79, 79),
                          ],
                          chartRadius: MediaQuery.of(context).size.width / 2.5,
                        ),
                      SizedBox(height: 20),
                      Text(
                        "Nilai pH: ${phValue != null ? phValue!.toStringAsFixed(1) : '-'} ",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "pH value: $result",
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        explanation,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      if (phValue != null)
                        ElevatedButton(
                          onPressed: () {
                            // Save pH value to Firebase
                            savePhValueToFirebase(phValue!, widget.deviceId);

                            // Navigate to the dashboard screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Dashboard()),
                            );
                          },
                          child: Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Inter',
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFF5B22),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void savePhValueToFirebase(double phValue, String deviceId) async {
    try {
      // Get a reference to the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Create a map with the pH value, current timestamp, and device ID
      Map<String, dynamic> parameterInfoMap = {
        'ph_value': phValue,
        'timestamp': Timestamp.now(),
        'device_id': deviceId,
      };

      // Add the new parameter data to the 'Parameter' collection
      await firestore.collection("Parameter").add(parameterInfoMap);

      // Show a success message or perform other actions
      print('pH value saved to Firebase Firestore');
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error saving pH value: $e');
    }
  }
}

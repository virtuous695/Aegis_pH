import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Dashboard.dart';
import 'package:vertical_percent_indicator/vertical_percent_indicator.dart';

class TemperaturePage extends StatefulWidget {
  final double maxTemperature = 50;
  final dbref = FirebaseDatabase.instance.ref();
  final String deviceId; // Add deviceId here

  TemperaturePage({Key? key, required this.deviceId}) : super(key: key);

  @override
  _TemperaturePageState createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  double? temperature;
  String result = "-";
  String description = "Connect Your Device!";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    widget.dbref.child("esp32/sensor_suhu").onValue.listen((event) {
      setState(() {
        temperature = double.tryParse(event.snapshot.value.toString());
        temperature = temperature != null
            ? (temperature! > widget.maxTemperature
                ? widget.maxTemperature
                : temperature)
            : null;

        if (temperature != null) {
          if (temperature! < 0) {
            result = "Sangat Dingin";
            description =
                "Air beku, umumnya di lingkungan kutub atau pegunungan yang sangat tinggi.";
          } else if (temperature! >= 0 && temperature! <= 10) {
            result = "Dingin";
            description =
                "Air yang dingin, mungkin terjadi di sungai yang berasal dari salju mencair atau air laut di daerah kutub.";
          } else if (temperature! > 10 && temperature! <= 20) {
            result = "Sejuk";
            description =
                "Suhu air yang nyaman bagi kebanyakan organisme akuatik.";
          } else if (temperature! > 20 && temperature! <= 30) {
            result = "Hangat";
            description =
                "Suhu yang hangat, mungkin disebabkan oleh faktor alami atau aktivitas manusia.";
          } else if (temperature! > 30 && temperature! <= 40) {
            result = "Panas";
            description =
                "Air yang panas, dapat mengakibatkan stres panas pada organisme hidup di dalamnya.";
          } else {
            result = "Sangat Panas";
            description =
                "Suhu air yang sangat tinggi, dapat mengakibatkan kematian bagi banyak organisme akuatik.";
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
          'Temperature Detection',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF1A499B),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          // Add Center widget around the content
          child: isLoading
              ? CircularProgressIndicator() // Show loading indicator
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (temperature != null)
                      VerticalBarIndicator(
                        key: UniqueKey(),
                        percent: temperature! / widget.maxTemperature,
                        header:
                            '${(temperature! / widget.maxTemperature * 100).toStringAsFixed(0)}%',
                        height: 200,
                        width: 30,
                        color: [
                          Colors.red,
                          Colors.blue,
                        ],
                        footer: 'Task Completed',
                      ),
                    SizedBox(height: 20),
                    Text(
                      "Temperature: ${temperature != null ? temperature!.toStringAsFixed(1) : '-'} °C",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Status: $result",
                      style: TextStyle(
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    if (temperature != null)
                      ElevatedButton(
                        onPressed: () {
                          // Save temperature value to Firebase
                          saveTemperatureToFirebase(
                              temperature!, widget.deviceId);

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
    );
  }

  void saveTemperatureToFirebase(double temperature, String deviceId) async {
    try {
      // Get a reference to the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Create a map with the temperature value, current timestamp, and device ID
      Map<String, dynamic> parameterInfoMap = {
        'temperature': temperature,
        'timestamp': Timestamp.now(),
        'device_id': deviceId,
      };

      // Add the new parameter data to the 'Parameter' collection
      await firestore.collection("Parameter").add(parameterInfoMap);

      // Show a success message or perform other actions
      print('Temperature saved to Firebase Firestore');
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error saving temperature: $e');
    }
  }
}

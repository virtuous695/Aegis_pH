import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Dashboard.dart';
import 'package:vertical_percent_indicator/vertical_percent_indicator.dart';

class ParticlePage extends StatefulWidget {
  final double maxParticleCount = 501;
  final dbref = FirebaseDatabase.instance.ref();

  ParticlePage({Key? key, required String deviceId}) : super(key: key);

  @override
  _ParticlePageState createState() => _ParticlePageState();
}

class _ParticlePageState extends State<ParticlePage> {
  double? particleCount;
  String result = "-";
  String description = "Connect Your Device!";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    widget.dbref.child("esp32/sensor_particle").onValue.listen((event) {
      setState(() {
        particleCount = double.tryParse(event.snapshot.value.toString());
        particleCount = particleCount != null
            ? (particleCount! > widget.maxParticleCount
                ? widget.maxParticleCount
                : particleCount)
            : null;

        if (particleCount != null) {
          if (particleCount! < 50) {
            result = "Sangat Bersih";
            description =
                "Air sangat bersih, dengan sedikit atau tanpa polusi.";
          } else if (particleCount! >= 50 && particleCount! <= 100) {
            result = "Bersih";
            description = "Air yang bersih, cocok untuk kehidupan akuatik.";
          } else if (particleCount! > 100 && particleCount! <= 200) {
            result = "Normal";
            description =
                "Kualitas air yang masih baik, tetapi mungkin mulai terdapat sedikit polusi.";
          } else if (particleCount! > 200 && particleCount! <= 500) {
            result = "Sedikit Tinggi";
            description =
                "Air dengan sedikit polusi, mungkin memerlukan perhatian lebih.";
          } else {
            result = "Tinggi";
            description =
                "Air tercemar, tidak sehat bagi kehidupan akuatik dan manusia.";
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
          'Detection Particle',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF1A499B),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: isLoading
              ? CircularProgressIndicator() // Show loading indicator
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (particleCount != null)
                      VerticalBarIndicator(
                        key: UniqueKey(),
                        percent: particleCount! / widget.maxParticleCount,
                        header:
                            '${(particleCount! / widget.maxParticleCount * 100).toStringAsFixed(0)}%',
                        height: 200,
                        width: 30,
                        color: [
                          Colors.red,
                          Colors.orange,
                        ],
                        footer: 'Task Completed',
                      ),
                    SizedBox(height: 20),
                    Text(
                      "Nilai Particle: ${particleCount != null ? particleCount!.toStringAsFixed(1) : '-'}",
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
                    if (particleCount != null)
                      ElevatedButton(
                        onPressed: () {
                          // Save particle count value to Firebase
                          saveParticleCountToFirebase(particleCount!);

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

  void saveParticleCountToFirebase(double particleCount) async {
    try {
      // Get a reference to the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Create a map with the particle count value and current timestamp
      Map<String, dynamic> parameterInfoMap = {
        'particle_count': particleCount,
        'timestamp': Timestamp.now(),
      };

      // Add the new parameter data to the 'Parameter' collection
      await firestore.collection("Parameter").add(parameterInfoMap);

      // Show a success message or perform other actions
      print('Particle count saved to Firebase Firestore');
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error saving particle count: $e');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Dashboard.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:vertical_percent_indicator/vertical_percent_indicator.dart';

class SemuaFitur extends StatelessWidget {
  SemuaFitur({Key? key});
  final dbref = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'All Fitur',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1A499B),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Text(
                  'pH',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Temperature',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Particle',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PieChartlPage(),
            TemperatureePage(),
            ParticleePage(),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Builder(
          builder: (context) {
            double? phValue = PieChartlPage.phValue;
            double? temperature = TemperatureePage.temperature;
            double? particleCount = ParticleePage.particleCount;

            bool showSaveButton =
                phValue != null && temperature != null && particleCount != null;

            return showSaveButton
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Get the device ID
                        String deviceId = 'device_id';

                        // Save all parameter values to Firebase with device ID
                        saveAllParameterValuesToFirebase(
                            phValue, temperature, particleCount, deviceId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Dashboard()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5B22),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  )
                : const SizedBox
                    .shrink(); // If conditions are not met, hide the button
          },
        ),
      ),
    );
  }

  void saveAllParameterValuesToFirebase(double phValue, double temperature,
      double particleCount, String deviceId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      Map<String, dynamic> parameterInfoMap = {
        'temperature': temperature,
        'ph_value': phValue,
        'particle_count': particleCount,
        'device_id': deviceId,
        'timestamp': Timestamp.now(),
      };

      await firestore.collection("Parameter").add(parameterInfoMap);

      // Show a success message or perform other actions
      print('Parameter values saved to Firebase Firestore');
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error saving parameter values: $e');
    }
  }
}

// Remaining code for PieChartlPage, TemperatureePage, and ParticleePage remains unchanged

class PieChartlPage extends StatefulWidget {
  const PieChartlPage({Key? key}) : super(key: key);

  static double? phValue;

  @override
  _PieChartlPageState createState() => _PieChartlPageState();
}

class _PieChartlPageState extends State<PieChartlPage> {
  final dbref = FirebaseDatabase.instance.ref();
  final double maxPh = 14;

  @override
  void initState() {
    super.initState();
    dbref.child("esp32/sensor_ph").onValue.listen((event) {
      setState(() {
        PieChartlPage.phValue =
            double.tryParse(event.snapshot.value.toString());
        PieChartlPage.phValue = PieChartlPage.phValue != null
            ? (PieChartlPage.phValue! > maxPh ? maxPh : PieChartlPage.phValue)
            : null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double? phValue = PieChartlPage.phValue;

    String result = "-";
    String explanation = "Connect Your Device!";

    if (phValue != null) {
      if (phValue < 4.0) {
        result = "Sangat Asam";
        explanation =
            "Air yang sangat asam, mungkin disebabkan oleh polusi asam seperti limbah pertambangan atau industri.";
      } else if (phValue >= 4.0 && phValue <= 5.5) {
        result = "Asam";
        explanation =
            "Air yang asam, bisa menjadi tidak sehat bagi kehidupan akuatik dan tumbuhan air.";
      } else if (phValue > 5.5 && phValue <= 7.5) {
        result = "Netral";
        explanation =
            "pH air yang seimbang, cocok untuk kehidupan akuatik dan tumbuhan air.";
      } else if (phValue > 7.5 && phValue <= 9.0) {
        result = "Basa";
        explanation =
            "Air basa, bisa menjadi habitat bagi beberapa organisme akuatik.";
      } else if (phValue > 9.0) {
        result = "Sangat Basa";
        explanation =
            "Air yang sangat basa, dapat merusak kehidupan akuatik dan tumbuhan air.";
      } else {
        result = "Unknown";
        explanation = "Unknown pH value";
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (phValue != null)
            PieChart(
              dataMap: {
                "pH value": phValue,
                "Remaining": maxPh - phValue,
              },
              chartType: ChartType.ring,
              ringStrokeWidth: 32,
              colorList: [
                Colors.blue.withOpacity(1.0),
                const Color.fromARGB(128, 82, 79, 79),
              ],
              chartRadius: MediaQuery.of(context).size.width / 2.5,
            ),
          const SizedBox(height: 80),
          Text(
            "Nilai pH: ${phValue != null ? phValue.toString() : '-'}",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            "pH value: $result",
            style: const TextStyle(
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            explanation,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class TemperatureePage extends StatefulWidget {
  const TemperatureePage({Key? key}) : super(key: key);

  static double? temperature;

  @override
  _TemperatureePageState createState() => _TemperatureePageState();
}

class _TemperatureePageState extends State<TemperatureePage> {
  final dbref = FirebaseDatabase.instance.ref();
  final double maxTemperature = 50;

  @override
  void initState() {
    super.initState();
    dbref.child("esp32/sensor_suhu").onValue.listen((event) {
      setState(() {
        TemperatureePage.temperature =
            double.tryParse(event.snapshot.value.toString());
        TemperatureePage.temperature = TemperatureePage.temperature != null
            ? (TemperatureePage.temperature! > maxTemperature
                ? maxTemperature
                : TemperatureePage.temperature)
            : null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double? temperature = TemperatureePage.temperature;

    String result = "-";
    String description = "Connect Your Device!";

    if (temperature != null) {
      if (temperature < 0) {
        result = "Sangat Dingin";
        description =
            "Air beku, umumnya di lingkungan kutub atau pegunungan yang sangat tinggi.";
      } else if (temperature >= 0 && temperature <= 10) {
        result = "Dingin";
        description =
            "Air yang dingin, mungkin terjadi di sungai yang berasal dari salju mencair atau air laut di daerah kutub.";
      } else if (temperature > 10 && temperature <= 20) {
        result = "Sejuk";
        description = "Suhu air yang nyaman bagi kebanyakan organisme akuatik.";
      } else if (temperature > 20 && temperature <= 30) {
        result = "Hangat";
        description =
            "Suhu yang hangat, mungkin disebabkan oleh faktor alami atau aktivitas manusia.";
      } else if (temperature > 30 && temperature <= 40) {
        result = "Panas";
        description =
            "Air yang panas, dapat mengakibatkan stres panas pada organisme hidup di dalamnya.";
      } else {
        result = "Sangat Panas";
        description =
            "Suhu air yang sangat tinggi, dapat mengakibatkan kematian bagi banyak organisme akuatik.";
      }
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (temperature != null)
                VerticalBarIndicator(
                  key: UniqueKey(),
                  percent: temperature / maxTemperature,
                  header:
                      '${(temperature / maxTemperature * 100).toStringAsFixed(0)}%',
                  height: 200,
                  width: 30,
                  color: const [
                    Colors.red,
                    Colors.blue,
                  ],
                  footer: 'Task Completed',
                ),
              const SizedBox(height: 20),
              Text(
                "Temperature: ${temperature != null ? temperature.toString() : '-'} °C",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Status: $result",
                style: const TextStyle(
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class ParticleePage extends StatefulWidget {
  const ParticleePage({Key? key}) : super(key: key);

  static double? particleCount;

  @override
  _ParticleePageState createState() => _ParticleePageState();
}

class _ParticleePageState extends State<ParticleePage> {
  final dbref = FirebaseDatabase.instance.ref();
  final double maxParticleCount = 500;

  @override
  void initState() {
    super.initState();
    dbref.child("esp32/sensor_particle").onValue.listen((event) {
      setState(() {
        ParticleePage.particleCount =
            double.tryParse(event.snapshot.value.toString());
        ParticleePage.particleCount = ParticleePage.particleCount != null
            ? (ParticleePage.particleCount! > maxParticleCount
                ? maxParticleCount
                : ParticleePage.particleCount)
            : null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double? particleCount = ParticleePage.particleCount;

    String result = "-";
    String description = "Connect Your Device!";

    if (particleCount != null) {
      if (particleCount < 50) {
        result = "Sangat Bersih";
        description = "Air sangat bersih, dengan sedikit atau tanpa polusi.";
      } else if (particleCount >= 50 && particleCount <= 100) {
        result = "Bersih";
        description = "Air yang bersih, cocok untuk kehidupan akuatik.";
      } else if (particleCount > 100 && particleCount <= 200) {
        result = "Normal";
        description =
            "Kualitas air yang masih baik, tetapi mungkin mulai terdapat sedikit polusi.";
      } else if (particleCount > 200 && particleCount <= 500) {
        result = "Sedikit Tinggi";
        description =
            "Air dengan sedikit polusi, mungkin memerlukan perhatian lebih.";
      } else {
        result = "Tinggi";
        description =
            "Air tercemar, tidak sehat bagi kehidupan akuatik dan manusia.";
      }
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (particleCount != null)
                VerticalBarIndicator(
                  key: UniqueKey(),
                  percent: particleCount / maxParticleCount,
                  header:
                      '${(particleCount / maxParticleCount * 100).toStringAsFixed(0)}%',
                  height: 200,
                  width: 30,
                  color: const [
                    Colors.red,
                    Colors.orange,
                  ],
                  footer: 'Task Completed',
                ),
              const SizedBox(height: 20),
              Text(
                "Nilai Particle: ${particleCount != null ? particleCount.toString() : '-'}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Status: $result",
                style: const TextStyle(
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              if (particleCount != null) const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

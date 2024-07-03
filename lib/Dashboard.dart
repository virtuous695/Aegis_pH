// ignore_for_file: file_names, library_private_types_in_public_api, prefer_const_constructors, avoid_print, unnecessary_string_interpolations, sort_child_properties_last, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/HistoryPage.dart';
import 'package:flutter_application_2/InfoPage.dart';
import 'package:flutter_application_2/ParticlePage.dart';
import 'package:flutter_application_2/PhPage.dart';
import 'package:flutter_application_2/TemperaturePage.dart';
import 'package:flutter_application_2/main.dart';
import 'package:flutter_application_2/semuafitur.dart';
import 'package:intl/intl.dart'; // Import DateFormat from intl package

void main() {
  runApp(MyApp());
}

class Dashboard extends StatefulWidget {
  Stream<QuerySnapshot> getParameter() {
    return FirebaseFirestore.instance.collection("Parameter").snapshots();
  }

  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final List<Map<String, dynamic>> data = [
    {'title': 'pH', 'icon': Icons.waves, 'your_image': 'your_image1'},
    {
      'title': 'Temperature',
      'icon': Icons.thermostat,
      'your_image': 'your_image2'
    },
    {'title': 'Particle', 'icon': Icons.grain, 'your_image': 'your_image3'},
    {'title': 'History', 'your_image': 'your_image4'},
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool isDarkMode = false;
  bool _iotState = false;
  late final String deviceId;

  final dbref = FirebaseDatabase.instance.ref();

  bool _isDeviceIdInitialized = false; // Flag to track initialization status

  @override
  void initState() {
    super.initState();
    _initializeDeviceId();
  }

  Future<void> _initializeDeviceId() async {
    deviceId = await getDeviceId();
    setState(() {
      _isDeviceIdInitialized = true; // Set flag to true once initialized
    });
  }

  Future<String> getDeviceId() async {
    // Simulate a network call or some asynchronous operation
    await Future.delayed(Duration(seconds: 2));
    return 'device_id'; // Replace with actual device ID retrieval logic
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    // Conditionally render the UI based on whether deviceId is initialized
    if (!_isDeviceIdInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AEGIS_pH',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF1A499B),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actions: [
          Switch(
            value: _iotState,
            onChanged: (value) {
              setState(() {
                _iotState = value;
              });
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title:
                        Text(_iotState ? 'Menghidupkan IoT' : 'Mematikan IoT'),
                    content: Text(_iotState
                        ? 'Apakah Anda yakin ingin menghidupkan IoT?'
                        : 'Apakah Anda yakin ingin mematikan IoT?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _iotState = !value;
                          });
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _iotState = value;
                          });
                          dbref.child("esp32").set({"switch": value});
                          Navigator.pop(context);
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
            activeColor: Colors.white,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: data.length,
              itemBuilder: (context, index) {
                return _buildDashboardCell(data[index]);
              },
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              data.length,
              (index) => _buildIndicator(index),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'HISTORY',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: 10.0),
          _buildHistoryTable(),
          SizedBox(height: 40.0),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildDashboardCell(Map<String, dynamic> item) {
    Color textColor = const Color.fromARGB(255, 0, 0, 0);

    String title = item['title'];
    String description = '';

    switch (title) {
      case 'pH':
        description =
            'pH is a scale measuring acidity or alkalinity in a substance. Lower values indicate acidity, 7 is neutral, and higher values denote alkalinity.';
        break;
      case 'Temperature':
        description =
            'Water temperature measures the degree of warmth or coldness. It influences aquatic ecosystems, affecting dissolved oxygen levels, metabolic rates, and overall habitat suitability for various organisms.';
        break;
      case 'Particle':
        description =
            'Particles in water, like sediment and pollutants, can harm aquatic ecosystems. Monitoring particle levels is vital for preserving water quality and ecosystem balance.';
        break;
      case 'History':
        description =
            'pH measures acidity, particles like sediment impact water quality, and water temperature affects aquatic ecosystems, influencing dissolved oxygen, metabolic rates, and overall habitat suitability for organisms.';
        break;
    }

    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      margin: EdgeInsets.only(left: 45.0, right: 45.0, top: 10.0, bottom: 10.0),
      child: InkWell(
        onTap: () {
          print('Dashboard item tapped: $title');
          if (title == 'pH') {
            _showPhExplanation();
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width - 0,
          decoration: BoxDecoration(
            color: const Color(0xFFfffffb),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: EdgeInsets.all(5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/${item['your_image']}.png',
                width: 100.0,
                height: 100.0,
              ),
              SizedBox(height: 30),
              Text(description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontFamily: 'Inter',
                    color: textColor,
                  )),
              SizedBox(
                height: 30,
              ),
              _buildSliderButton(
                'Detection',
                data.indexOf(item),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(int index) {
    return Container(
      width: 8.0,
      height: 8.0,
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index
            ? Color(0xFFFF5B22)
            : Colors.grey.withOpacity(0.5),
      ),
    );
  }

  Widget _buildHistoryTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Parameter")
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final parameterDocs = snapshot.data?.docs ?? [];
        if (parameterDocs.isEmpty) {
          return Center(child: Text('No data available'));
        }

        final latestParameter = parameterDocs.first;
        final parameter = latestParameter.data() as Map<String, dynamic>;
        final timestamp = parameter['timestamp'];
        final phValue = parameter['ph_value'];
        final temperature = parameter['temperature'];
        final particleCount = parameter['particle_count'];

        final formattedDate =
            DateFormat('dd-MM-yyyy').format(timestamp.toDate());

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          width: MediaQuery.of(context).size.width - 20,
          height: 170,
          decoration: BoxDecoration(
            color: const Color(0xFFfffffb),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Padding(padding: EdgeInsets.all(10)),
                    SizedBox(
                      width: 65,
                      child: Text(
                        'Date',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 30,
                      child: Text(
                        'pH',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 85,
                      child: Text(
                        'Temperature',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        'PPM',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(padding: EdgeInsets.all(5)),
                    Material(elevation: 5),
                    Padding(
                      padding: EdgeInsets.all(0),
                      child: Row(
                        children: [
                          Padding(padding: EdgeInsets.all(0)),
                          Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xFF1A499B),
                            child: Container(
                              width: 85,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0x0eeededb),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  '$formattedDate',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(0),
                      child: Row(
                        children: [
                          Padding(padding: EdgeInsets.all(0)),
                          Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 75,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0x0eeededb),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  '${phValue ?? '-'} ',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(0),
                      child: Row(
                        children: [
                          Padding(padding: EdgeInsets.all(0)),
                          Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 75,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0x0eeededb),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  '${temperature ?? '-'} ',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(0),
                      child: Row(
                        children: [
                          Padding(padding: EdgeInsets.all(0)),
                          Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 80,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0x0eeededb),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  '${particleCount ?? '-'} ',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HistoryPage()),
                      );
                    },
                    child: Text(
                      'See More',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF5B22),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.all(7.0),
      color: Color.fromARGB(255, 222, 222, 222),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomButton(
            Image.asset('assets/home.png', width: 25, height: 25),
            'Home',
            () {
              // Tambahkan aksi untuk tombol Home
            },
          ),
          _buildBottomButton(
            Image.asset('assets/history.png', width: 25, height: 25),
            'History',
            () {
              // Aksi untuk tombol History
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryPage()),
              );
            },
          ),
          _buildBottomButton(
            Image.asset('assets/info.png', width: 25, height: 25),
            'Info',
            () {
              // Aksi untuk tombol Info
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InfoPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(Widget icon, String label, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: label == 'Home'
                  ? Colors.grey.withOpacity(0.3)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: icon,
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderButton(String label, int sliderIndex) {
    return InkWell(
      onTap: () {
        // Aksi yang dijalankan saat tombol slider ditekan
        print('Slider $sliderIndex button tapped: $label');
        _navigateToSliderPage(sliderIndex);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 40.0),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Color(0xFFFF5B22),
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showPhExplanation() {}

  void _navigateToSliderPage(int sliderIndex) {
    switch (sliderIndex) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PhPage(
                    deviceId: deviceId,
                  )),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TemperaturePage(
                    deviceId: deviceId,
                  )),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ParticlePage(
                    deviceId: deviceId,
                  )),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SemuaFitur()),
        );
        break;
      default:
        break;
    }
  }
}

class FixedSizeText extends StatelessWidget {
  final String text;
  final double width;

  const FixedSizeText(this.text, this.width);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: Text(
        text,
        style: TextStyle(fontFamily: 'Inter'),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

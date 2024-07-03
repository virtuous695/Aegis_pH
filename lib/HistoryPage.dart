// ignore_for_file: file_names, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Dashboard.dart';
import 'package:flutter_application_2/InfoPage.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  Stream<QuerySnapshot> getParameter() {
    return FirebaseFirestore.instance
        .collection("Parameter")
        .orderBy('timestamp',
            descending:
                true) // Urutkan data secara descending berdasarkan timestamp
        .limit(20)
        .snapshots();
  }

  Widget _buildHistoryData(
    dynamic timestamp,
    dynamic phValue,
    dynamic temperature,
    dynamic particleCount,
  ) {
    DateTime formattedDate =
        timestamp != null ? (timestamp as Timestamp).toDate() : DateTime.now();

    String formattedDateString =
        '${formattedDate.day}/${formattedDate.month}/${formattedDate.year}';

    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A499B),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: Text(
                  'Date',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                formattedDateString,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: Text(
                  'pH',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${phValue ?? '-'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: Text(
                  'Temperature (°C)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${temperature ?? '-'} ',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: Text(
                  'PPM',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${particleCount ?? '-'} ',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A499B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBar: _buildBottomButtons(context),
      body: StreamBuilder<QuerySnapshot>(
        stream: getParameter(), // Call the method to get Firestore stream
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No data available'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return _buildHistoryData(
                data['timestamp'],
                data['ph_value'],
                data['temperature'],
                data['particle_count'],
              );
            },
          );
        },
      ),
    );
  }
}

Widget _buildBottomButtons(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(7.0),
    color: const Color.fromARGB(255, 222, 222, 222),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildBottomButton(
          Image.asset('assets/home.png', width: 25, height: 25),
          'Home',
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
            );
          },
        ),
        _buildBottomButton(
          Image.asset('assets/history.png', width: 25, height: 25),
          'History',
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryPage()),
            );
          },
        ),
        _buildBottomButton(
          Image.asset('assets/info.png', width: 25, height: 25),
          'Info',
          () {
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
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: label == 'History'
                ? Colors.grey.withOpacity(0.3)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: icon,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Inter',
          ),
        ),
      ],
    ),
  );
}

void main() {
  runApp(const MaterialApp(
    home: HistoryPage(),
  ));
}

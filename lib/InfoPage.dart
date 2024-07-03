// ignore_for_file: file_names, library_private_types_in_public_api, avoid_print, annotate_overrides, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_application_2/Dashboard.dart';
import 'package:flutter_application_2/HistoryPage.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  late String videoId;
  late YoutubePlayerController _controller;
  bool _appBarVisibility = true;
  bool _bottomButtonsVisibility = true;

  @override
  void initState() {
    super.initState();
    // Ambil ID video dari URL YouTube
    videoId = YoutubePlayer.convertUrlToId(
            "https://www.youtube.com/watch?v=EPhhBtrBjxU&t=17s") ??
        "";
    print(videoId); // BBAyRBTfsOU

    // Inisialisasi controller
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );

    // Tambahkan listener untuk full screen mode
    _controller.addListener(() {
      if (_controller.value.isFullScreen) {
        // Full screen mode
        _hideAppBarAndBottomButtons();
      } else {
        // Exit full screen mode
        _showAppBarAndBottomButtons();
      }
    });
  }

  @override
  void dispose() {
    // Hapus controller saat widget di dispose
    _controller.dispose();
    super.dispose();
  }

  void _hideAppBarAndBottomButtons() {
    setState(() {
      // Set app bar dan bottom buttons menjadi tidak visible
      _appBarVisibility = false;
      _bottomButtonsVisibility = false;
    });
  }

  void _showAppBarAndBottomButtons() {
    setState(() {
      // Set app bar dan bottom buttons menjadi visible
      _appBarVisibility = true;
      _bottomButtonsVisibility = true;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarVisibility
          ? AppBar(
              title: const Text(
                'Info',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF1A499B),
              iconTheme: const IconThemeData(color: Colors.white),
            )
          : PreferredSize(
              child: Container(),
              preferredSize: const Size(0.0, 0.0),
            ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri
            children: [
              const Text(
                'About Application',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'This app is designed for android users. Usability of this application to detect water worthy of use for everyday needs. The application uses the Arduino Uno micro controller and uses sensors from external devices such as DS18B20, PH-4520C, TDS Sensor Meter, and ESP-32. TDS sensors are electronic devices used to measure water-solved particles, including organic and inorganic substances in the form of molecular, ionic, or micro-granular suspensions. TDS units are generally expressed in parts per million (ppm) or milligrams per liter (mg/L). The lower the ppm of drinking water, the more pure it is.',
                textAlign: TextAlign.start, // Rata kiri
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Watch the Video',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 10),
              YoutubePlayerBuilder(
                player: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                  aspectRatio: 16 / 9, // Rasio aspek video
                  onReady: () {
                    // Set fungsi hide/show app bar dan bottom buttons saat siap
                    _controller.addListener(() {
                      if (_controller.value.isFullScreen) {
                        _hideAppBarAndBottomButtons();
                      } else {
                        _showAppBarAndBottomButtons();
                      }
                    });
                  },
                ),
                builder: (context, player) {
                  return player;
                },
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 20),
              const Text(
                'How to Work',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'This app is designed for android users. The application has several features: Get Started, Water pH Detection, Water Temperature, Water Particles, Data, How to Works, Navigation Menu, and Info. If the user wants to detect the pH in the water, the user can press "detect" on the "Water pH Scale" section and press "save" to save the data in history',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          _bottomButtonsVisibility ? _buildBottomButtons(context) : null,
    );
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
              // Tambahkan aksi untuk tombol Home
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
              // Aksi untuk tombol History
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
              // Aksi untuk tombol Info
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InfoPage()),
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
              color: label == 'Info'
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
}

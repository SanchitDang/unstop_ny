import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class FindingAutoRideScreen extends StatefulWidget {
  const FindingAutoRideScreen({
    Key? key,
    required this.sLat,
    required this.sLng,
    required this.dLat,
    required this.dLng, required this.distance, required this.openToCarPool, required this.duration,
  }) : super(key: key);

  final double sLat;
  final double sLng;
  final double dLat;
  final double dLng;
  final int distance;
  final int duration;
  final bool openToCarPool;

  @override
  State<FindingAutoRideScreen> createState() => _FindingAutoRideScreenState();
}

class _FindingAutoRideScreenState extends State<FindingAutoRideScreen> {

  Future<void> sendDataDriveRoute(
      double sLat, double sLng, double dLat, double dLng) async {
    const url = 'https://ny-backend.onrender.com/postride';
    final data = {
      'riderName': "Abhay",
      'gender': "Male",
      'distance': widget.distance,
      'duration': widget.duration,
      'openToCarPool': widget.openToCarPool,
      'sourceLat': sLat,
      'sourceLng': sLng,
      'destLat': dLat,
      'destLng': dLng,
      'startTime': DateTime.now().millisecondsSinceEpoch ~/ 1000
    };

    try {
      final response = await Dio().post(
        url,
        data: jsonEncode(data),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 201) {
        // Success!
        print('Sent Successful');
      } else {
        // Error - handle it accordingly
        print('Error fetching data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sendDataDriveRoute(widget.sLat,  widget.sLng,  widget.dLat,  widget.dLng);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Booking",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black, // Set the color of the back button here
          onPressed: () {
            // Handle back button press here
            Navigator.pop(context);
          },
        ),
      ),
      body: const Center(
          child: Text("Ride Booked...",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500
            ),
          )

      ),
    );
  }
}

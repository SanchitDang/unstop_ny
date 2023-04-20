import 'package:flutter/material.dart';

class FindingAutoRideScreen extends StatefulWidget {
  const FindingAutoRideScreen({Key? key}) : super(key: key);

  @override
  State<FindingAutoRideScreen> createState() => _FindingAutoRideScreenState();
}

class _FindingAutoRideScreenState extends State<FindingAutoRideScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Finding Auto",
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
          child: Text("Finding auto...",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500
            ),
          )

      ),
    );
  }
}

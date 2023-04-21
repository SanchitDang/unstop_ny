import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CarPoolScreen extends StatefulWidget {
  const CarPoolScreen({
    Key? key,
    required this.sLat,
    required this.sLng,
    required this.dLat,
    required this.dLng,
  }) : super(key: key);

  final double sLat;
  final double sLng;
  final double dLat;
  final double dLng;

  @override
  State<CarPoolScreen> createState() => _CarPoolScreenState();
}

class _CarPoolScreenState extends State<CarPoolScreen> {
  bool poolAvailable = false;
  String poolId = "";
  List<dynamic> jsonList = [];


  Future<void> fetchDataPublicRoute(
      double sLat, double sLng, double dLat, double dLng) async {
    const url = 'https://ny-backend.onrender.com/getpool';
    final data = {
      'startTime': DateTime.now().millisecondsSinceEpoch ~/ 1000
      //'startTime': 1200
    };

    try {
      final response = await Dio().post(
        url,
        data: jsonEncode(data),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        // Success!

        setState(() {
          jsonList.addAll(response.data);
          print(jsonList);
        });


        for (int i =0 ; i< jsonList.length ; i++) {
          double neLat = double.parse(jsonList[i]["northEast"]['lat']);
          double neLng = double.parse(jsonList[i]["northEast"]['lng']);
          double swLat = double.parse(jsonList[i]["southWest"]['lat']);
          double swLng = double.parse(jsonList[i]["southWest"]['lng']);

          bool ans = false;
          try {
            LatLngBounds bounds = LatLngBounds(
              southwest: LatLng(swLat, swLng),
              northeast: LatLng(neLat, neLng),
            );
            ans = bounds.contains(LatLng(widget.sLat, widget.sLng));
          } catch (e) {
            // TODO
            LatLngBounds bounds = LatLngBounds(
              southwest: LatLng(neLat, neLng),
              northeast: LatLng(swLat, swLng),
            );
            ans = bounds.contains(LatLng(widget.sLat, widget.sLng));
          }

          // bool ans = bounds.contains(LatLng(widget.sLat, widget.sLng));

          print(ans);

          if (ans){
            setState(() {
              poolId = jsonList[i]["poolingId"];
              poolAvailable = true;
            });
            break;
          }

        }

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
    fetchDataPublicRoute(widget.sLat, widget.sLng, widget.dLat, widget.dLng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Car Pooling",
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              poolAvailable
                  ?
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text("Car Pooling Available!",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 6,),
                      Row(
                        children: const [
                          Text("Driver Name: ",
                            style: TextStyle(
                                fontSize: 18,
                            ),
                          ),
                          Spacer(),
                          Text("xyz",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          )
                        ],
                      ),

                      Row(
                        children: const [
                          Text("Driver Car: ",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          Spacer(),
                          Text("pqr",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          )
                        ],
                      ),

                      Row(
                        children: [
                          const Text("Pooling id: ",
                            style: TextStyle(
                                fontSize: 18,
                            ),
                          ),
                          const Spacer(),
                          Text(poolId,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),

                              ),
                              onPressed: () {},
                              child: const Text(
                                'Request Pooling',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
                  :
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text("No Car Pooling Available!",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 6,),
                      Row(
                        children: const [
                          Text("Currently no car pooling is avaiable.",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),

                        ],
                      ),
                      Row(
                        children: const [
                          Text("Try again later or book an Auto.",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),

                              ),
                              onPressed: () {},
                              child: const Text(
                                'Book a auto',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

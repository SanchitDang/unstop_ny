import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:unstop_ny/home_screen/thank_screen.dart';

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
  String riderName = "";
  String gender = "";
  String sAdd = "";
  String dAdd = "";
  double gotSLat = 00;
  double gotSLng = 00;
  double gotDLat = 00;
  double gotDLng = 00;
  double prox = 00;

  List<dynamic> jsonList = [];

  // Future<void> fetchDataPublicRoute(
  //     double sLat, double sLng, double dLat, double dLng) async {
  //   const url = 'https://ny-backend.onrender.com/getpool';
  //   final data = {
  //     'startTime': DateTime.now().millisecondsSinceEpoch ~/ 1000,
  //     'sourceLat': widget.sLat,
  //     'sourceLng': widget.sLng,
  //     //'startTime': 1200
  //   };
  //
  //   try {
  //     final response = await Dio().post(
  //       url,
  //       data: jsonEncode(data),
  //       options: Options(
  //         headers: {'Content-Type': 'application/json'},
  //       ),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       // Success!
  //
  //       setState(() {
  //         jsonList.addAll(response.data);
  //         print(jsonList);
  //       });
  //
  //
  //       for (int i =0 ; i< jsonList.length ; i++) {
  //         double neLat = double.parse(jsonList[i]["northEast"]['lat']);
  //         double neLng = double.parse(jsonList[i]["northEast"]['lng']);
  //         double swLat = double.parse(jsonList[i]["southWest"]['lat']);
  //         double swLng = double.parse(jsonList[i]["southWest"]['lng']);
  //
  //         bool ans = false;
  //         try {
  //           LatLngBounds bounds = LatLngBounds(
  //             southwest: LatLng(swLat, swLng),
  //             northeast: LatLng(neLat, neLng),
  //           );
  //           ans = bounds.contains(LatLng(widget.sLat, widget.sLng));
  //         } catch (e) {
  //           // TODO
  //           LatLngBounds bounds = LatLngBounds(
  //             southwest: LatLng(neLat, neLng),
  //             northeast: LatLng(swLat, swLng),
  //           );
  //           ans = bounds.contains(LatLng(widget.sLat, widget.sLng));
  //         }
  //
  //         // bool ans = bounds.contains(LatLng(widget.sLat, widget.sLng));
  //
  //         print(ans);
  //
  //         if (ans){
  //           setState(() {
  //             poolId = jsonList[i]["poolingId"];
  //             riderName = jsonList[i]["riderName"];
  //             gender = jsonList[i]["gender"];
  //             gotSLat = jsonList[i]["sourceLocation"]["lat"];
  //             gotSLng = jsonList[i]["sourceLocation"]["lng"];
  //             getAddressSFromLatLng(gotSLat, gotSLng);
  //             gotDLat = jsonList[i]["destLocation"]["lat"];
  //             gotDLng = jsonList[i]["destLocation"]["lng"];
  //             getAddressDFromLatLng(gotDLat, gotDLng);
  //             prox =  jsonList[i]["proximity"];
  //             poolAvailable = true;
  //           });
  //           break;
  //         }
  //
  //       }
  //
  //     } else {
  //       // Error - handle it accordingly
  //       print('Error fetching data: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching data: $e');
  //   }
  // }

  Future<void> fetchDataPublicRoute(
      double sLat, double sLng, double dLat, double dLng) async {
    const url = 'https://ny-backend.onrender.com/getpool';
    final data = {
      'startTime': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'sourceLat': widget.sLat,
      'sourceLng': widget.sLng,
      //'startTime': 1682413820
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
          jsonList.add(response.data);
          print(jsonList);
        });

        if (jsonList[0] != null) {
          setState(() {
            poolId = jsonList[0]["poolingId"];
            riderName = jsonList[0]["riderName"];
            gender = jsonList[0]["gender"];
            gotSLat = double.parse(jsonList[0]["sourceLocation"]["lat"]);
            gotSLng = double.parse(jsonList[0]["sourceLocation"]["lng"]);
            getAddressSFromLatLng(gotSLat, gotSLng);
            gotDLat = double.parse(jsonList[0]["destLocation"]["lat"]);
            gotDLng = double.parse(jsonList[0]["destLocation"]["lng"]);
            getAddressDFromLatLng(gotDLat, gotDLng);
            prox = jsonList[0]["proximity"];
            poolAvailable = true;
          });
        } else {
          setState(() {
            poolAvailable = false;
          });
        }
      } else {
        // Error - handle it accordingly
        print('Error fetching data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> getAddressSFromLatLng(double lat, double lng) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    Placemark place = placemarks[0];
    String address = "${place.street}, ${place.subLocality}";
    setState(() {
      sAdd = address;
    });
  }

  Future<void> getAddressDFromLatLng(double lat, double lng) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    Placemark place = placemarks[0];
    String address = "${place.street}, ${place.subLocality}";
    setState(() {
      dAdd = address;
    });
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
                  ? Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            //heading
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "Pooling Available!",
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),

                            //Details
                            Row(
                              children: [
                                Text(
                                  riderName,
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Row(
                              children: [
                                Text(
                                  gender,
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                )
                              ],
                            ),

                            const SizedBox(
                              height: 2,
                            ),
                            Row(
                              children: [
                                Text(
                                  sAdd,
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Row(
                              children: const [Icon(Icons.arrow_downward)],
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Row(
                              children: [
                                Text(
                                  dAdd,
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Row(
                              children: [
                                Text(
                                  "${prox.toStringAsFixed(2)} Kms away from you",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 10,
                            ),
                            //BUTTON
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
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Confirm'),
                                            content: const Text(
                                                'Do you really want to request pooling?'),
                                            actions: [
                                              ElevatedButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(Colors.black),
                                                ),
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(false),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(
                                                    Colors.black,
                                                  ),
                                                ),
                                                onPressed: () => {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const ThankYouPage(
                                                              title:
                                                                  "Booking Done",
                                                            )),
                                                  )
                                                },
                                                child: const Text('Yes'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
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
                  : Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            //heading
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "Pooling Not Available!",
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: const [
                                Text(
                                  "Currently no car pooling is avaiable.",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: const [
                                Text(
                                  "Try again later or book an Auto.",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
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

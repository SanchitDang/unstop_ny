import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class OtherOptions extends StatefulWidget {
  const OtherOptions({
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
  State<OtherOptions> createState() => _OtherOptionsState();
}

class _OtherOptionsState extends State<OtherOptions> {
  bool show = false;

  List<dynamic> transitFlow = [];
  List<dynamic> ways = [];

  Future<void> fetchData(
      double sLat, double sLng, double dLat, double dLng) async {
    const url = 'https://ny-backend.onrender.com/api';
    final data = {
      'source_lat': sLat,
      'source_lng': sLng,
      'dest_lat': dLat,
      'dest_lng': dLng
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
        print(response.data['transitFlow']);

        transitFlow.addAll(response.data['transitFlow']);
        print(transitFlow);

        ways.addAll(response.data['way']);
        print(ways[0]['distance']['text']);
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
    super.initState();
    // TODO: implement initState
    fetchData(widget.sLat, widget.sLng, widget.dLat, widget.dLng)
        .then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Other Options",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    show = !show;
                  });
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: transitFlow.map((flow) {
                        if (flow == "WALKING") {
                          return Row(
                            children: const [
                              Icon(Icons.directions_walk),
                            ],
                          );
                        } else if (flow == "BUS") {
                          return Row(
                            children: const [
                              Icon(Icons.bus_alert),
                            ],
                          );
                        } else if (flow == "METRO") {
                          return Row(
                            children: const [
                              Icon(Icons.directions_train_outlined),
                            ],
                          );
                        } else {
                          return const SizedBox();
                        }
                      }).toList(),
                    ),
                  ),
                ),
              ),
              show
                  ? Column(
                    children: List.generate(
                      ways.length,
                      (index) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  ways[index]['walkable']
                                      ? Text(
                                          "Walk ${ways[index]['distance']['text']}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                          ),
                                        )
                                      : Text(
                                          ways[index]['distance']['text'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                          ),
                                        )
                                ],
                              ),
                              Row(
                                children: [
                                  ways[index]['walkable']
                                      ? SizedBox()
                                      : Text(
                                          "${ways[index]['transitDetails']['type']}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      ways[index]['walkable']
                                          ? const SizedBox()
                                          : Text(
                                        "Departure Stop: ${ways[index]['transitDetails']['departureStop']['name'].toString().length>22 ?
                                        ways[index]['transitDetails']['departureStop']['name'].toString().substring(0,22) :
                                        ways[index]['transitDetails']['departureStop']['name']
                                        }",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.0,
                                              ),
                                            ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      ways[index]['walkable']
                                          ? const SizedBox()
                                          : Text(
                                              "Arrival Stop: ${ways[index]['transitDetails']['arrivalStop']['name'].toString().length>22 ?
                                                  ways[index]['transitDetails']['arrivalStop']['name'].toString().substring(0,22) :
                                              ways[index]['transitDetails']['arrivalStop']['name']
                                        }",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.0,
                                              ),
                                            ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Estimated Time: ${ways[index]['duration']['text']}",
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16,)
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}

// Row(
//   children: [
//     Icon(Icons.directions_walk),
//     Spacer(),
//     Icon(Icons.bus_alert),
//     Spacer(),
//     Icon(Icons.directions_car_outlined),
//   ],
// ),

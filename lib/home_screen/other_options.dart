import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:unstop_ny/home_screen/request_ride.dart';

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
  Map<String,dynamic> desc = {};

  bool suggestFullRide = false;

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

        desc.addAll(response.data['desc']);
        //desc.addAll(response.data);
        print(desc);

        ways.addAll(response.data['way']);

        setState(() {
          suggestFullRide = response.data['suggestFullRide'];
        });
        print(suggestFullRide);

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

              //WAYS CARD
              GestureDetector(
                onTap: () {
                  setState(() {
                    show = !show;
                  });
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        ways.isEmpty
                            ?
                        const Center(child: CircularProgressIndicator( color: Colors.black,))
                            :
                        Column(
                      children: [
                        Row(
                          children: transitFlow.map((flow) {
                            if (flow == "WALKING") {
                              return const Expanded(
                                child: Icon(Icons.directions_walk),
                              );
                            } else if (flow == "BUS") {
                              return const Expanded(
                                child: Icon(Icons.bus_alert),
                              );
                            } else if (flow == "METRO") {
                              return const Expanded(
                                child: Icon(Icons.directions_train_outlined),
                              );
                            } else {
                              return const SizedBox();
                            }
                          }).toList(),
                        ),

                       desc.isEmpty ? const SizedBox() :
                       Padding(
                         padding: const EdgeInsets.fromLTRB(8, 10, 8, 2),
                         child: Column(
                            children: [
                              Row(
                                  children: [
                                    Text(desc['duration']['text'],
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),

                                  ]
                              ),
                              Row(
                                  children: [
                                    Text(desc['distance']['text'],
                                      style: const TextStyle(
                                          fontSize: 18,

                                      ),
                                    ),
                                    const Spacer(),
                                    Text(desc['fare']['text'],
                                      style: const TextStyle(
                                          fontSize: 18,

                                      ),
                                    ),
                                  ]
                              ),
                              Row(
                                  children: [
                                    Text("${desc['departTime']['text']} -> ${desc['arrivalTime']['text']}",
                                      style: const TextStyle(
                                          fontSize: 18,

                                      ),
                                    ),

                                  ]
                              ),
                            ],
                          ),
                       ),

                        suggestFullRide ?    Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    backgroundColor: const Color.fromRGBO(43, 45, 58, 1),
                                  ),
                                  onPressed: () {


                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>
                                          RequestARideScreen(
                                            sLat: desc['startLocation']['lat'],
                                            sLng: desc['startLocation']['lng'],
                                            dLat: desc['finalLocation']['lat'],
                                            dLng: desc['finalLocation']['lng'],
                                          )
                                      ),
                                    );


                                  },
                                  child: const Text(
                                    'Too far? Book Auto Ride',
                                    style: TextStyle(
                                        color: Color.fromRGBO(168, 142, 60, 1)
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
          : const SizedBox()

                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 4,),

              //BELOW SUB CARDS
              AnimatedOpacity(
                opacity: show ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child:   Column(
                  children: List.generate(
                    ways.length,
                        (index) => Column(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: const BorderSide(
                              width: 2,
                              color: Color.fromRGBO(168, 142, 60, 1),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                            child: Row(
                              children: [
                                Column(
                                  children: const [
                                    SizedBox(
                                      width: 34,
                                    ),
                                    SizedBox(
                                      height:
                                      80, // Add a height to the SizedBox
                                      child: VerticalDivider(
                                        width: 1,
                                        thickness: 1,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                  ],
                                ),
                                ways[index]['walkable']
                                    ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: const [
                                        Text(
                                          "WALK",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "${ways[index]['transitDetails']['amountOfSteps']} steps",
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "${ways[index]['distance']['text']}",
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Duration: ${ways[index]['duration']['text']}",
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                                    : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          ways[index]['transitDetails']['type'].toString().toUpperCase(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                          ),
                                        )
                                      ],
                                    ),

                                    Row(
                                      children: [
                                        Text(
                                          "${ways[index]['transitDetails']['departureStop']['name'].toString().length > 18 ? ways[index]['transitDetails']['departureStop']['name'].toString().substring(0, 18) : ways[index]['transitDetails']['departureStop']['name']} -> ${ways[index]['transitDetails']['arrivalStop']['name'].toString().length > 18 ? ways[index]['transitDetails']['arrivalStop']['name'].toString().substring(0, 18) : ways[index]['transitDetails']['arrivalStop']['name']}",
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ],
                                    ),


                                    Row(
                                      children: [
                                        Text(
                                          ways[index]['distance']['text'],
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Duration: ${ways[index]['duration']['text']}",
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        ways[index]['suggestRide']
                            ?
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    backgroundColor: const Color.fromRGBO(43, 45, 58, 1),
                                  ),
                                  onPressed: () {


                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>
                                          RequestARideScreen(
                                            sLat: ways[index]['startLocation']['lat'],
                                            sLng: ways[index]['startLocation']['lng'],
                                            dLat: ways[index]['finalLocation']['lat'],
                                            dLng: ways[index]['finalLocation']['lng'],
                                          )
                                      ),
                                    );



                                  },
                                  child: const Text(
                                    'In hurry? Book Auto Ride',
                                    style: TextStyle(
                                        color: Color.fromRGBO(168, 142, 60, 1)
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                            :
                        const SizedBox(),

                        if(index < ways.length-1)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4,),

                                  Container(
                                    width: 15,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color.fromRGBO(168, 142, 60, 1), width: 3),
                                      color: Colors.transparent,
                                    ),
                                  ),

                                  const SizedBox(height: 4,),

                                  Container(
                                    width: 15,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color.fromRGBO(168, 142, 60, 1), width: 3),
                                      color: Colors.transparent,
                                    ),
                                  ),

                                  const SizedBox(height: 4,),

                                ],
                              ),
                            ),
                          )

                      ],
                    ),
                  ),
                )
              ),

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

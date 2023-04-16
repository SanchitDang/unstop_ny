import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:unstop_ny/home_screen/request_ride.dart';
import 'search_map.dart';
import 'loc_search/components/location_list_tile.dart';
import 'loc_search/components/network_utility.dart';
import 'loc_search/models/autocomplate_prediction.dart';
import 'loc_search/models/place_auto_complate_response.dart';

class PickAnotherLocation extends StatefulWidget {
  const PickAnotherLocation({Key? key}) : super(key: key);

  @override
  State<PickAnotherLocation> createState() => _PickAnotherLocationState();
}

class _PickAnotherLocationState extends State<PickAnotherLocation> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrPos();
  }

  Future<void> fetchData(
      double sLat, double sLng, double dLat, double dLng) async {
    // for edge
    //const url = 'http://localhost:8000/api';

    //const url = 'http://192.168.1.31:39028/api';
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
        print(response.data);
      } else {
        // Error - handle it accordingly
        print('Error fetching data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  final String apiKey = "AIzaSyAfZTYWDvvhw53Zi4w_tmqhCYM6MWogBaE";
  late String currLoc = '';
  late double currLat = 0.0;
  late double currLng = 0.0;

  late String pickLocFromNextScreen = currLoc;
  late double pickLatFromNextScreen = currLat;
  late double pickLngFromNextScreen = currLng;

  late String dropLocFromNextScreen = '';
  late double dropLatFromNextScreen = 0.0;
  late double dropLngFromNextScreen = 0.0;

  late Map<String, dynamic> _data;

  final TextEditingController pickController = TextEditingController();
  final TextEditingController dropController = TextEditingController();

  bool _dropIsPressed = false;
  bool _pickIsPressed = false;

  final FocusNode _pickNode = FocusNode();
  final FocusNode _dropNode = FocusNode();

  late double nextPickLat;
  late double nextPickLng;

  late double nextDropLat;
  late double nextDropLng;

  List<AutocompletePrediction> placePredictions = [];

  final places =
      GoogleMapsPlaces(apiKey: 'AIzaSyBJnW7uKl9qaMpvdZsLRvaY4HvYIg2FWsQ');

  GoogleMapsPlaces googleMapsPlaces =
      GoogleMapsPlaces(apiKey: "AIzaSyBJnW7uKl9qaMpvdZsLRvaY4HvYIg2FWsQ");

  // void placeAutoComplete(String query) async {
  //   Uri uri = Uri.https(
  //       "maps.googleapis.com",
  //       "/maps/api/place/autocomplete/json",
  //       {"input": query, "key": "AIzaSyBJnW7uKl9qaMpvdZsLRvaY4HvYIg2FWsQ"});
  //   String? response = await NetworkUtility.fetchUrl(uri);
  //
  //   if (response != null) {
  //     PlaceAutocompleteResponse result =
  //         PlaceAutocompleteResponse.parseAutocompleteResult(response);
  //     if (result.predictions != null) {
  //       setState(() {
  //         placePredictions = result.predictions!;
  //       });
  //     }
  //   }
  // }

  //restricting within india
  void placeAutoComplete(String query) async {
    Uri uri =
        Uri.https("maps.googleapis.com", "/maps/api/place/autocomplete/json", {
      "input": query,
      "components": "country:in",
      "key": "AIzaSyBJnW7uKl9qaMpvdZsLRvaY4HvYIg2FWsQ"
    });
    String? response = await NetworkUtility.fetchUrl(uri);

    if (response != null) {
      PlaceAutocompleteResponse result =
          PlaceAutocompleteResponse.parseAutocompleteResult(response);
      if (result.predictions != null) {
        setState(() {
          placePredictions = result.predictions!;
        });
      }
    }
  }

  void showSnackBarText(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  Future _getCurrPos() async {
    Position currentPosition = await _determineUserCurrentPosition();
    List<Placemark> placemarks = await placemarkFromCoordinates(
        currentPosition.latitude, currentPosition.longitude);
    Placemark address = placemarks[0]; // get only first and closest address
    String addressStr =
        "${address.street}, ${address.subLocality}, ${address.locality}, ${address.administrativeArea}, ${address.country}";

    setState(() {
      currLoc = addressStr;
      currLat = currentPosition.latitude;
      currLng = currentPosition.longitude;
    });
    pickController.text = addressStr;
    pickLocFromNextScreen = addressStr;
  }

  Future _determineUserCurrentPosition() async {
    LocationPermission locationPermission;
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    //check if user enable service for location permission
    if (!isLocationServiceEnabled) {
      showSnackBarText("user don't enabled location permission");
    }

    locationPermission = await Geolocator.checkPermission();

    //check if user denied location and retry requesting for permission
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        showSnackBarText("user denied location permission");
      }
    }

    //check if user denied permission forever
    if (locationPermission == LocationPermission.deniedForever) {
      showSnackBarText("user denied permission forever");
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _pickNode.unfocus();
        _dropNode.unfocus();
        //placePredictions.clear();
        _dropIsPressed = false;
        _pickIsPressed = false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Search Location",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Column(
          children: [
            //PICK DROP LOC
            Card(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _pickIsPressed = true;
                      });
                    },
                    child: Form(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                        child: TextFormField(
                          focusNode: _pickNode,
                          controller: pickController,
                          onChanged: (value) {
                            placeAutoComplete(value);
                          },
                          textInputAction: TextInputAction.search,
                          decoration: const InputDecoration(
                            hintText: "Pickup Location",
                            prefixIcon: Icon(Icons.location_on_outlined,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Add some vertical space between the text fields
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _dropIsPressed = true;
                      });
                    },
                    child: Form(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 2, 10, 4),
                        child: TextFormField(
                          focusNode: _dropNode,
                          controller: dropController,
                          onChanged: (value) {
                            placeAutoComplete(value);
                          },
                          textInputAction: TextInputAction.search,
                          decoration: const InputDecoration(
                            hintText: "Drop Location",
                            prefixIcon: Icon(Icons.directions_walk,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //SAVED PLACES and SET LOCATION ON MAP
            Card(
              child: Column(children: [
                ListTile(
                  title: const Text('Set location on map'),
                  leading: const Icon(Icons.location_on_outlined),
                  onTap: () async {
                    if (_pickNode.hasFocus) {
                      final pL = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SearchPickMap()),
                      );
                      setState(() {
                        pickController.text = pL['loc'];
                        pickLocFromNextScreen = pL['loc'];
                        pickLatFromNextScreen = pL['lat'];
                        pickLngFromNextScreen = pL['lng'];

                        //working
                        //pickController.text=pL;
                        //pickLocFromNextScreen=pL;
                      });

                      //} else if (_dropNode.hasFocus) {
                    } else {
                      //String dL = await Navigator.push(
                      final dL = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SearchPickMap()),
                      );
                      setState(() {
                        dropController.text = dL['loc'];
                        dropLocFromNextScreen = dL['loc'];
                        dropLatFromNextScreen = dL['lat'];
                        dropLngFromNextScreen = dL['lng'];

                        //working
                        //dropController.text=dL;
                        //dropLocFromNextScreen=dL;
                      });
                    }
                  },
                )
              ]),
            ),

            // have to only show if first 2 text boxes are not active
            Expanded(
              child: ListView.builder(
                itemCount: placePredictions.length,
                itemBuilder: (context, index) => LocationListTile(
                  press: () async {
                    if (_pickNode.hasFocus) {
                      // Text field 1 is selected
                      setState(() {
                        pickController.text =
                            placePredictions[index].description!;

                        pickLocFromNextScreen =
                            placePredictions[index].description!;
                      });

                      String placeId = placePredictions[index].placeId!;
                      String url =
                          "https://maps.googleapis.com/maps/api/geocode/json?place_id=$placeId&key=AIzaSyAfZTYWDvvhw53Zi4w_tmqhCYM6MWogBaE";

                      final response = await http.get(Uri.parse(url));
                      final responseBody = json.decode(response.body);

                      if (responseBody["status"] == "OK") {
                        final result = responseBody["results"][0];
                        final location = result["geometry"]["location"];
                        final lat = location["lat"];
                        final lng = location["lng"];

                        setState(() {
                          // nextPickLat = lat;
                          // nextPickLng = lng;
                          pickLatFromNextScreen = lat;
                          pickLngFromNextScreen = lng;
                        });

                        // print({
                        //   "nextPicklatitude": nextPickLat,
                        //   "nextPicklongitude": nextPickLng
                        // });
                      } else {
                        //print(responseBody["status"]);
                      }
                    } else if (_dropNode.hasFocus) {
                      // Text field 2 is selected
                      setState(() {
                        dropController.text =
                            placePredictions[index].description!;

                        dropLocFromNextScreen =
                            placePredictions[index].description!;
                      });

                      String placeId = placePredictions[index].placeId!;
                      String url =
                          "https://maps.googleapis.com/maps/api/geocode/json?place_id=$placeId&key=AIzaSyAfZTYWDvvhw53Zi4w_tmqhCYM6MWogBaE";

                      final response = await http.get(Uri.parse(url));
                      final responseBody = json.decode(response.body);

                      if (responseBody["status"] == "OK") {
                        final result = responseBody["results"][0];
                        final location = result["geometry"]["location"];
                        final lat = location["lat"];
                        final lng = location["lng"];

                        setState(() {
                          // nextDropLat = lat;
                          // nextDropLng = lng;
                          dropLatFromNextScreen = lat;
                          dropLngFromNextScreen = lng;
                        });

                        // print({
                        //   "nextDroplatitude": nextDropLat,
                        //   "nextDroplongitude": nextDropLng
                        // });
                      } else {
                        //print(responseBody["status"]);
                      }
                    }
                  },
                  location: placePredictions[index].description!,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton:
            (currLoc.isNotEmpty && dropLocFromNextScreen.isNotEmpty) ||
                    (pickLocFromNextScreen.isNotEmpty &&
                        dropLocFromNextScreen.isNotEmpty)
                ? Container(
                    width: double.infinity,
                    height: 44,
                    padding: const EdgeInsets.fromLTRB(32, 0, 0, 0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        backgroundColor: Colors.black,
                      ),
                      child: const Text('Confirm'),
                      onPressed: () async {

                        // fetchData(pickLatFromNextScreen, pickLngFromNextScreen,
                        //     dropLatFromNextScreen, dropLngFromNextScreen);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RequestARideScreen(
                                  sLat: pickLatFromNextScreen,
                                  sLng: pickLngFromNextScreen,
                                  dLat: dropLatFromNextScreen,
                                  dLng: dropLngFromNextScreen)),
                        );
                      },
                    ),
                  )
                : null,
      ),
    );
  }
}

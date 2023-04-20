import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../model/direction_model.dart';
import '../../../model/directions_repository.dart';
import '../model/polyline_response.dart';
import 'drop_markers.dart';
import 'package:geolocator/geolocator.dart';
import 'get_dropMarkers.dart';
import 'package:unstop_ny/home_screen/other_options.dart';

class RequestARideScreen extends StatefulWidget {
  RequestARideScreen({
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
  State<RequestARideScreen> createState() => _RequestARideScreenState();
}

class _RequestARideScreenState extends State<RequestARideScreen> {
  late Position _currentPosition;
  Future<void> getCurrLoc() async {
    _currentPosition = await Geolocator.getCurrentPosition();
    setState(() {});
  }

  final Completer<GoogleMapController> _controller = Completer();

  static CameraPosition initialPosition = CameraPosition(
      target: LatLng(28.640956116187407, 77.12170606332784), zoom: 14);


  String apiKey = "AIzaSyAfZTYWDvvhw53Zi4w_tmqhCYM6MWogBaE";

  late Directions info;

  PolylineResponse polylineResponse = PolylineResponse();

  Set<Marker> markers = {};
  Set<Polyline> polylinePoints = {};

//   List<LatLng> myLatLngList = [
// LatLng(28.653467836101004, 77.13154423515411),
//     LatLng(28.65467294129605, 77.15291607528403)
//  ];

  List<LatLng> myLatLngList = [];

  //To get data from button Selection
  List<DropMarker> myLatLngDropMarkers = getMarkers();

  String stops = '';

  final List<Directions> _directionsList = [];

  // Fetch directions for each LatLng in myLatLngList
  Future<void> fetchDirections() async {
    if (myLatLngList.isEmpty) {
      return;
    }

    List<Directions> directionsList = [];

    for (int i = 0; i < myLatLngList.length - 1; i++) {
      LatLng origin = myLatLngList[i];
      LatLng destination = myLatLngList[i + 1];

      final directions = await DirectionsRepository().getDirections(
        origin: origin,
        destination: destination,
      );

      if (directions != null) {
        directionsList.add(directions);
      }
    }

    setState(() {
      _directionsList.addAll(directionsList);
    });
    print(_directionsList);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrLoc();

    myLatLngList.add(
      LatLng(widget.sLat, widget.sLng),
    );
    myLatLngList.add(LatLng(widget.dLat, widget.dLng));

    setState(() {});

    //To get data from button Selection
    for (DropMarker marker in myLatLngDropMarkers) {
      //print('Name: ${marker.name}, Position: ${marker.position}');
      myLatLngList.add(marker.position);
      stops += '${marker.position.latitude},${marker.position.longitude}|';
    }
    print(stops);

    for (int i = 0; i < myLatLngList.length; i++) {
      markers.add(Marker(
          markerId: MarkerId(i.toString()),
          position: myLatLngList[i],
          infoWindow: InfoWindow(
            title: "Passenger",
            onTap: () {
              print(myLatLngList[i]);
            },
          ),
          icon: BitmapDescriptor.defaultMarker));
      setState(() {});
      polylinePoints.add(Polyline(
        polylineId: PolylineId('1'),
        points: myLatLngList,
        color: Colors.redAccent,
      ));
    }

    fetchDirections();

  }

  Widget _getMap() {
    return GoogleMap(
      //polylines: polylinePoints,
      polylines: {
        for (var i = 0; i < _directionsList.length; i++)
          Polyline(
            polylineId: PolylineId('overview_polyline_$i'),
            color: Colors.red,
            width: 5,
            points: _directionsList[i]
                .polylinePoints
                .map((e) => LatLng(e.latitude, e.longitude))
                .toList(),
          ),
      },
      scrollGesturesEnabled: false,
      rotateGesturesEnabled: false,
      zoomGesturesEnabled: false,
      zoomControlsEnabled: false,
      markers: markers,
      initialCameraPosition: initialPosition,
      mapType: MapType.normal,
      onMapCreated: (GoogleMapController controller) {
        LatLngBounds bounds = LatLngBounds(
         southwest: LatLng(widget.sLat, widget.sLng), // First coordinate
         northeast: LatLng(widget.dLat, widget.dLng), // Second coordinate
        );
        double lat = (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
        double lng = (bounds.northeast.longitude + bounds.southwest.longitude) / 2;
        controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            //target: bounds.southwest, // Center of bounds
            target:  LatLng(lat, lng), // Center of bounds
            zoom: 14, // Zoom level
          ),
        ));
      },
    );
  }

  Widget _buildBody() {
    return Stack(children: [
      _getMap(),
      Align(
        alignment: Alignment.bottomCenter,
        child: _showWhereToAddress(),
      )
    ]);
  }

  Widget _showWhereToAddress() {
    return SizedBox(
      height: 249,
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("Request Auto Ride",
                          style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                children: const [
                                  Text('₹pqr',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w500
                                  ),),
                                ],
                              ),
                              const SizedBox(height:5),
                              Row(
                                children: const [
                                  Text('x kms | y min'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Row(
                    children: [
                      Expanded(
                        child:
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            backgroundColor: const Color.fromRGBO(43, 45, 58, 1),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OtherOptions(
                                    sLng: widget.sLng,
                                    sLat: widget.sLat,
                                    dLng: widget.dLng,
                                    dLat: widget.dLat,
                                  )),
                            );
                          },
                          child: const Text(
                            'Other Ways To Go',
                            style: TextStyle(
                                color: Color.fromRGBO(168, 142, 60, 1)
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            backgroundColor: const Color.fromRGBO(43, 45, 58, 1),
                          ),
                          onPressed: () {
                            LatLngBounds bounds = LatLngBounds(
                              // southwest: LatLng(widget.sLat, widget.sLng), // First coordinate
                              // northeast: LatLng(widget.dLat, widget.dLng), // Second coordinate
                              southwest: LatLng(28.595308144478015, 77.0532471476376), //mcd
                              northeast: LatLng(28.617235978914973, 77.10096900622817), // tihar
                            );

                            print(bounds.contains(LatLng(28.596438557089765, 77.09942405397165)));

                          },
                          child: const Text(
                            'Request Ride',
                            style: TextStyle(
                                color: Color.fromRGBO(168, 142, 60, 1)
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }
}

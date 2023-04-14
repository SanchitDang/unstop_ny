import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  //Search
  static const kGoogleApiKey = 'AIzaSyAfZTYWDvvhw53Zi4w_tmqhCYM6MWogBaE';
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  final Mode _mode = Mode.overlay;


  //get map controller to access map
  final Completer<GoogleMapController> _googleMapController = Completer();
  CameraPosition? _cameraPosition;
  late LatLng _defaultLatLng;
  late LatLng _draggedLatlng;
  String _draggedAddress = "";



  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() {
    //set default latlng for camera position
    _defaultLatLng = const LatLng(20.5937, 78.9629);
    _draggedLatlng = _defaultLatLng;
    _cameraPosition = CameraPosition(
        target: _defaultLatLng,
        zoom: 17.5 // number of map view
    );

    //map will redirect to my current location when loaded
    _gotoUserCurrentPosition();
  }
  Future _gotoSpecificPosition(LatLng position) async {
    GoogleMapController mapController = await _googleMapController.future;
    mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: position,
            zoom: 17.5
        )
    ));
    //every time that we dragged pin , it will list down the address here
    await _getAddress(position);
  }

  Future _gotoUserCurrentPosition() async {
    Position currentPosition = await _determineUserCurrentPosition();
    _gotoSpecificPosition(LatLng(currentPosition.latitude, currentPosition.longitude));
  }
  Future _determineUserCurrentPosition() async {
    LocationPermission locationPermission;
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    //check if user enable service for location permission
    if(!isLocationServiceEnabled) {
      //print("user don't enable location permission");
    }

    locationPermission = await Geolocator.checkPermission();

    //check if user denied location and retry requesting for permission
    if(locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
      if(locationPermission == LocationPermission.denied) {
        //print("user denied location permission");
      }
    }

    //check if user denied permission forever
    if(locationPermission == LocationPermission.deniedForever) {
      //print("user denied permission forever");
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }

  Future _getAddress(LatLng position) async {
    //this will list down all address around the position
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark address = placemarks[0]; // get only first and closest address
    String addresStr = "${address.street}, ${address.subLocality}, ${address.locality}, ${address.administrativeArea}, ${address.country}";
    setState(() {
      _draggedAddress = addresStr;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(15, 40, 15, 0),
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Pick Up Location',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.purple,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Add navigation logic
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Add navigation logic
              },
            ),
          ],
        ),
      ),


      body: Column(
        children: [
        GoogleMap(
          zoomControlsEnabled: false,
          //markers: markersList,
          initialCameraPosition: _cameraPosition!, //initialize camera position for map
          mapType: MapType.normal,
          onCameraIdle: () {
            //this function will trigger when user stop dragging on map
            //every time user drag and stop it will display address
            _getAddress(_draggedLatlng);
          },
          onCameraMove: (cameraPosition) {
            //this function will trigger when user keep dragging on map
            //every time user drag this will get value of latlng
            _draggedLatlng = cameraPosition.target;
          },
          onMapCreated: (GoogleMapController controller) {
            //this function will trigger when map is fully loaded
            if (!_googleMapController.isCompleted) {
              //set controller to google map when it is fully loaded
              _googleMapController.complete(controller);
            }
          },
        )
        ],
      ),

      bottomNavigationBar:  SizedBox(
        height: 192,
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children:  [
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: const [
                                  Icon(Icons.arrow_right_alt),
                                  SizedBox(width: 15),
                                  Text('Where to?'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Row(
                      children:  [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: const [
                                  Icon(Icons.history),
                                  SizedBox(width: 15),
                                  Text('UB City, KG Halli'),
                                  Spacer(),
                                  Icon(Icons.favorite_border),
                                ],
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
      ),
    );
  }
}
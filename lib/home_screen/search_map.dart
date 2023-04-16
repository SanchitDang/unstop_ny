import 'dart:async';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:lottie/lottie.dart';

import '../../home_screen/another_search_location.dart';


class SearchPickMap extends StatefulWidget {
  const SearchPickMap({Key? key}) : super(key: key);

  @override
  State<SearchPickMap> createState() => _SearchPickMapState();
}

class _SearchPickMapState extends State<SearchPickMap> {
  //Text Box Controller
  final TextEditingController _textController = TextEditingController();
  late LatLng _pickedLocation = const LatLng(20.5937, 78.9629);
  final places =
      GoogleMapsPlaces(apiKey: 'AIzaSyBJnW7uKl9qaMpvdZsLRvaY4HvYIg2FWsQ');

  late double _lat;
  late double _lng;
  late String _loc;
  void showSnackBarText(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }
  Future<void> _delayedPop(BuildContext context, dynamic data) async {
    unawaited(
      Navigator.of(context, rootNavigator: true).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => WillPopScope(
            onWillPop: () async => false,
            child: const Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
          ),
          transitionDuration: Duration.zero,
          barrierDismissible: false,
          barrierColor: Colors.black45,
          opaque: false,
        ),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 1000));
    Navigator.of(context)
      ..pop(data)
      ..pop(data);
  }


  RoutePredicate isNamedRoute(String name) {
    return (Route<dynamic> route) => route.settings.name == name;
  }

  //Search
  static const kGoogleApiKey = 'AIzaSyBJnW7uKl9qaMpvdZsLRvaY4HvYIg2FWsQ';
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  final Mode _mode = Mode.overlay;

  //get map controller to access map
  Completer<GoogleMapController> _googleMapController = Completer();
  CameraPosition? _cameraPosition;
  late LatLng _defaultLatLng;
  late LatLng _draggedLatlng;
  String _draggedAddress = "";

  @override
  void initState() {
    _init();
    super.initState();
    // _controller.addListener(() {
    //   onChange();
    // });
  }

  void _searchPlaces() async {
    final places =
        GoogleMapsPlaces(apiKey: 'AIzaSyBJnW7uKl9qaMpvdZsLRvaY4HvYIg2FWsQ');
    final result = await places.autocomplete(_textController.text);

    if (result.status == 'OK' && result.predictions.isNotEmpty) {
      final placeId = result.predictions.first.placeId;
      final details = await places.getDetailsByPlaceId(placeId!);
      final lat = details.result.geometry?.location.lat;
      final lng = details.result.geometry?.location.lng;

      setState(() {
        _pickedLocation = LatLng(lat!, lng!);
      });
    }
  }
  void navigateToPickAnotherLocation(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const PickAnotherLocation(),
        settings: const RouteSettings(name: 'pick_another_location'),
      ),
    );
    Navigator.of(context).pop();
  }

  _init() {
    //set default latlng for camera position
    _defaultLatLng = const LatLng(20.5937, 78.9629);
    _draggedLatlng = _defaultLatLng;
    _cameraPosition =
        CameraPosition(target: _defaultLatLng, zoom: 17.5 // number of map view
            );

    //map will redirect to my current location when loaded
    _gotoUserCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: FloatingActionButton(
          mini: true,
        onPressed: () {
          _delayedPop(context, "loc");
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.arrow_back, color: Colors.black,),
      ),

      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Stack(children: [
      _getMap(),
      _getCustomPin(),
      //_showDraggedAddress(),
      Positioned(
        bottom: 0,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 210,
          child: Card(
            child: Column(
              children: [
                Column(
                  children: [
                    // First row
                    Row(
                      children: const [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                            child: Center(
                              child: Text(
                                'Set your desired Location',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Line separator
                    Container(
                      height: 2,
                      color: Colors.grey[300],

                    ),
                    // Second row
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _draggedAddress
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                primary: Color.fromRGBO(211,211,211,1),
                              ),
                              child: const Text('Search',
                                  style: TextStyle(color: Colors.black)
                              ),
                              onPressed: () async {
                               //opens Google Search Bar on top
                                // _handlePressButton();

                                // but as per req, go back to search box )
                                _delayedPop(context, "OpenSearchBox");
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Third row
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2),
                            ),
                            primary: Colors.black,
                          ),
                          child: const Text('Confirm Location'),
                          onPressed: () async {
                            final String loc = _loc;
                            final double myLat = _lat;
                            final double myLng = _lng;
                            // print( myLat);
                            // print( myLng);
                            // print(loc);
                              //Navigator.pop(context, _loc);

                            Map<String, dynamic> data = {
                              'loc': loc,
                              'lat': myLat,
                              'lng': myLng,
                            };

                           // _delayedPop(context, _loc);
                            _delayedPop(context, data);
                              // Navigator.of(context).pushAndRemoveUntil(
                              //     MaterialPageRoute(builder: (context) => PickAnotherLocation()),
                              //         (route) => false
                              // );

                          },
                        ),
                      ),
                    ),
                  ],
                ),

                // rows here
              ],
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _showDraggedAddress() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(0),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _draggedAddress,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getMap() {
    return GoogleMap(
      zoomControlsEnabled: false,
      //markers: markersList,
      initialCameraPosition:
          _cameraPosition!, //initialize camera position for map
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
    );
  }

  Widget _getCustomPin() {
    return Center(
      child: SizedBox(
        width: 150,
        child: Lottie.asset("assets/pin.json"),
      ),
    );
  }

  //get address from dragged pin
  Future _getAddress(LatLng position) async {
    //this will list down all address around the position
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark address = placemarks[0]; // get only first and closest address
    String addresStr =
        "${address.street}, ${address.locality}, ${address.administrativeArea}, ${address.country}";
    setState(() {
      _lat = position.latitude;
      _lng = position.longitude;
      _loc = addresStr;
      _draggedAddress = addresStr;
    });
  }

  //get user's current location and set the map's camera to that location
  Future _gotoUserCurrentPosition() async {
    Position currentPosition = await _determineUserCurrentPosition();
    _pickedLocation =
        LatLng(currentPosition.latitude, currentPosition.longitude);
    _gotoSpecificPosition(
        LatLng(currentPosition.latitude, currentPosition.longitude));
  }

  //go to specific position by latlng
  Future _gotoSpecificPosition(LatLng position) async {
    GoogleMapController mapController = await _googleMapController.future;
    mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 17.5)));
    //every time that we dragged pin , it will list down the address here
    await _getAddress(position);
  }

  Future _determineUserCurrentPosition() async {
    LocationPermission locationPermission;
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    //check if user enable service for location permission
    if (!isLocationServiceEnabled) {
      showSnackBarText("user don't enable location permission");
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

  //Search Button
  Future<void> _handlePressButton() async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        onError: onError,
        mode: _mode,
        language: 'en',
        strictbounds: false,
        types: [""],
        decoration: InputDecoration(
            hintText: 'Search',
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.white))),
        components: [Component(Component.country, "ind")]);

    displayPrediction(p!, homeScaffoldKey.currentState);
  }

  void onError(PlacesAutocompleteResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Message',
        message: response.errorMessage!,
        contentType: ContentType.failure,
      ),
    ));
  }

  Future<void> displayPrediction(
      Prediction p, ScaffoldState? currentState) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders());

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;

    setState(() {});
    GoogleMapController mapController = await _googleMapController.future;
    mapController
        .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0));
  }
}

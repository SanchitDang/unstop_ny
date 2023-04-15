import 'package:flutter/material.dart';
import 'package:unstop_ny/home_screen/loc_search/card_wid.dart';
import 'package:unstop_ny/home_screen/ola_type_map.dart';
import 'package:unstop_ny/home_screen/request_ride.dart';
import 'package:unstop_ny/home_screen/test.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nama Yatri',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: RequestARideScreen(sLat:28.653467836101004, sLng:77.13154423515411,dLat: 28.65467294129605,dLng: 77.15291607528403,)
      home: OlaMap()
    );
  }
}

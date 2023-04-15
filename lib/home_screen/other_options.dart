import 'package:flutter/material.dart';

class OtherOptions extends StatefulWidget {
  const OtherOptions({Key? key, required this.sLat, required this.sLng, required this.dLat, required this.dLng,}) : super(key: key);

  final double sLat;
  final double sLng;
  final double dLat;
  final double dLng;

  @override
  State<OtherOptions> createState() => _OtherOptionsState();
}

class _OtherOptionsState extends State<OtherOptions> {



  bool show = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation:0, centerTitle:true,title: Text("Other Options", style: TextStyle(color: Colors.black),),),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  show = true;
                });
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(Icons.directions_walk),
                      Spacer(),
                      Icon(Icons.bus_alert),
                      Spacer(),
                      Icon(Icons.directions_car_outlined),

                    ],
                  ),
                ),
              ),
            ),

            show ? SingleChildScrollView(
              child: Container(
                child: Text("1q23213"),
              ),
            ) : const SizedBox()
          ],
        ),
      ),
    );
  }
}

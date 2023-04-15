import 'package:flutter/material.dart';

class MyCardWidget extends StatefulWidget {
  @override
  _MyCardWidgetState createState() => _MyCardWidgetState();
}

class _MyCardWidgetState extends State<MyCardWidget> {
  double _cardHeight = 100.0;

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _cardHeight -= details.delta.dy;
      _cardHeight = _cardHeight.clamp(100.0, MediaQuery.of(context).size.height);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_cardHeight > 150.0) {
      setState(() {
        _cardHeight = MediaQuery.of(context).size.height;
      });
    } else {
      setState(() {
        _cardHeight = 100.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Swipe-to-Maximize Demo'),
      ),
      body: GestureDetector(
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _cardHeight,
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Swipe up to maximize',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
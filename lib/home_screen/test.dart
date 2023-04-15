import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {



  Future<void> fetchData() async {
    // for edge
    //const url = 'http://localhost:8000/api';

    const url = 'http://192.168.1.31:39028/api';
    final data = {
      'source_lat': 28.655647796354163,
      'source_lng': 77.15090785073525,
      'dest_lat': 28.642479065386944,
      'dest_lng': 77.17863448413084
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
      } else {
        // Error - handle it accordingly
        print('Error fetching data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Testing API"),
      ),
      body: Column(
        children: [ElevatedButton(onPressed: () {
          fetchData();
        }, child: const Text("API test"))],
      ),
    );
  }
}

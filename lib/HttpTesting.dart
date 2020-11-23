import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'main.dart';

class HttpTesting extends StatefulWidget {
  @override
  _HttpTestingState createState() => _HttpTestingState();
}

class _HttpTestingState extends State<HttpTesting> {

  fetchData() async {
    var headers = {
      'Cookie': '__cfduid=d61e20889aeab7de8722e8e3bd5fe41a91605938764',
      "Access-Control-Allow-Origin": "*",
    };
    var request = http.MultipartRequest('GET', Uri.parse('https://freaktemplate.com/appointment_book/api/login?email=1@gmail.com&password=1&token=abc'));
    request.fields.addAll({
      'email': '1@gmail.com',
      'password': '1',
      'token': 'abc'
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: OutlineButton(
          child: Text('call api'),
          onPressed: fetchData,
        ),
      )
    );
  }
}

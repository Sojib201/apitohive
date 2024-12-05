import 'dart:convert';

import 'package:apitohive/showDatafromHive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class FetchDataFromApi extends StatefulWidget {
  const FetchDataFromApi({super.key});

  @override
  State<FetchDataFromApi> createState() => _FetchDataFromApiState();
}

class _FetchDataFromApiState extends State<FetchDataFromApi> {
  final dataBox = Hive.box('sojib');

  bool isLoading = false;

  Future<void> fetchData() async {
    String url = 'https://jsonplaceholder.typicode.com/posts';
    try {
      Uri uri = Uri.parse(url);

      http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        dataBox.put('apiData', data);
        print('successfull');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully fetch')));

      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fetch Data From Api'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 50,
            ),
            isLoading ? CircularProgressIndicator() : ElevatedButton(
              onPressed: () async {
                isLoading = true;
                setState(() {});

              await  fetchData();
                isLoading=false;
                setState(() {

                });
              },
              child:
                  Text('Fetch Data'),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShowDataFromHive(),
                    ));
              },
              child: Text('Show'),
            ),
          ],
        ),
      ),
    );
  }
}

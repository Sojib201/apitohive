import 'dart:convert';

import 'package:apitohive/views/showDatafromHive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../model/userDetails.dart';

class FetchDataFromApi extends StatefulWidget {
  const FetchDataFromApi({super.key});

  @override
  State<FetchDataFromApi> createState() => _FetchDataFromApiState();
}

class _FetchDataFromApiState extends State<FetchDataFromApi> {
  final dataBox = Hive.box('sojib'); gjyhg
  List<dynamic> data1 = [];

  bool isLoading = false;

  Future<void> getData() async {
    data1 = await dataBox.get('apiData');

    // Filter items
    data1 = data1
        .where((item) => item['quantity'] != null && item['quantity'] != '')
        .toList();

    setState(() {});
  }

  Future<UserDetails?> fetchData() async {
    String url = 'https://jsonplaceholder.typicode.com/posts';
    try {
      Uri uri = Uri.parse(url);

      http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        dataBox.put('apiData', data);
        print('successfull');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Successfully fetch')));
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
        backgroundColor: Colors.grey,
        title: Text('Fetch Data From Api'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            isLoading
                ? CircularProgressIndicator()
                : SizedBox(
                    height: 50,
                    width: 377,
                    child: ElevatedButton(
                      onPressed: () async {
                        await fetchData();
                      },
                      child: Text(
                        'Fetch Data',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 15,
                        backgroundColor: Colors.grey,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 50,
              width: 377,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShowDataFromHive(),
                      ));
                },
                child: Text(
                  'Show Data',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 15,
                  backgroundColor: Colors.grey,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 50,
              width: 377,
              child: ElevatedButton(
                onPressed: () async {
                  await getData();
                  setState(() {});
                },
                child: Text(
                  'Show Data with Quantity',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 15,
                  backgroundColor: Colors.grey,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: data1.length,
                itemBuilder: (context, index) {
                  final item = data1[index];
                  return Card(
                    elevation: 50,
                    color: Colors.grey,
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(
                        item['title'] ?? 'No Title',
                        style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        item['body'] ?? 'No Body',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      trailing: Text(
                        item['quantity'] ?? 'No Quantity',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

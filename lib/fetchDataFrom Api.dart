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
  final newBox = Hive.box('newBox');

  bool isLoading = false;

  List<dynamic> data1 = [];
  List<Map<String, dynamic>> mergedData1 = [];

  @override
  void initState() {
    super.initState();
    mergeData();
  }

  void mergeData() {
    var dataBoxData = dataBox.get('apiData', defaultValue: []);
    var newBoxData = newBox.get('quantity', defaultValue: []);

    if (dataBoxData is! List<dynamic>) {
      print('Error: dataBoxData is not a List');
      dataBoxData = [];
    }

    if (newBoxData is! List<dynamic>) {
      print('Error: newBoxData is not a List');
      newBoxData = [];
    }

    mergedData1 = List.generate(dataBoxData.length, (index) {
      return {
        'title': dataBoxData[index]['title'],
        'body': dataBoxData[index]['body'],
        'quantity': index < newBoxData.length ? newBoxData[index] : 'No Quantity',
      };
    });

    setState(() {
      data1 = mergedData1; // Update data1 with merged data
    });
  }


  Future<void> getData() async {
    // Load existing data from the merged data
    List<dynamic> existingData = dataBox.get('data', defaultValue: []);
    setState(() {
      data1 = existingData;
    });
  }

  Future<void> fetchData() async {
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
                : ElevatedButton(
                    onPressed: () async {
                      isLoading = true;
                      setState(() {});

                      await fetchData();
                      isLoading = false;
                      setState(() {});
                    },
                    child: Text('Fetch Data'),
                  ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShowDataFromHive(),
                    ));
              },
              child: Text('Show Data'),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                mergeData;
              },
              child: Text('Show Data with Quantity'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: data1.length,
                itemBuilder: (context, index) {
                  final item = data1[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    elevation: 4,
                    child: ListTile(
                      title: Text(item['title'] ?? 'No Title'),
                      subtitle: Text(item['body'] ?? 'No Body'),
                      trailing: Text(item['quantity'] ?? 'No Quantity'),
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

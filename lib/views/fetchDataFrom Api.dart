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
  final dataBox = Hive.box('sojib');
  List<dynamic> filterData = [];

  bool isLoading = false;

  // Future<void> getData() async {
  //   final data = await dataBox.get('apiData');
  //
  //   // Filter items
  //   filterData = data
  //       .where((item) => item['quantity'] != null && item['quantity'] != '')
  //       .toList();
  //
  //   setState(() {});
  // }

  Future<void> getData() async {
    final data = dataBox.get('apiData') ?? [];
    filterData = data
        .where((item) => item['quantity'] != null && item['quantity'] != '')
        .toList();
    setState(() {});
  }

  void removeDataAndQuantity(Map<dynamic, dynamic> item) async {
    setState(() {
      filterData.remove(item);
    });

    final data = dataBox.get('apiData');
    for (var i in data) {
      if (i['title'] == item['title']) {
        i['quantity'] = null;
        break;
      }
    }

    await dataBox.put('apiData', data);
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
                itemCount: filterData.length,
                itemBuilder: (context, index) {
                  final item = filterData[index];
                  return Card(
                    elevation: 50,
                    color: Colors.grey,
                    margin: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        ListTile(
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
                          // leading: Text(
                          //   item['quantity'] ?? 'No Quantity',
                          //   style: TextStyle(
                          //     color: Colors.black,
                          //     fontSize: 14,
                          //   ),
                          // ),

                          trailing: ElevatedButton(
                            onPressed: () {
                              removeDataAndQuantity(item);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white38,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),

                          child: TextField(
                            controller: TextEditingController(
                              text: item['quantity']?.toString() ?? '',
                            ),
                            onChanged: (value) {
                              item['quantity'] = value;

                              // dataBox.put('apiData',
                              //     dataBox);
                            },
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              fillColor: Colors.white38,
                              filled: true,
                              hintText: "Enter Quantity",
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),

                          // child: TextField(
                          //   decoration: InputDecoration(
                          //     focusedBorder: OutlineInputBorder(
                          //       borderSide: BorderSide(color: Colors.black),
                          //       borderRadius: BorderRadius.circular(12),
                          //     ),
                          //     fillColor: Colors.white38,
                          //     filled: true,
                          //     //hintText: "Enter Quantity",
                          //     border: OutlineInputBorder(
                          //       borderSide: BorderSide(color: Colors.black),
                          //       borderRadius: BorderRadius.circular(8),
                          //     ),
                          //     contentPadding: EdgeInsets.symmetric(
                          //         horizontal: 12, vertical: 8),
                          //   ),
                          // ),
                        ),
                      ],
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

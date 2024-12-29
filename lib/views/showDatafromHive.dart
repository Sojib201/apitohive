import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ShowDataFromHive extends StatefulWidget {
  const ShowDataFromHive({super.key});

  @override
  State<ShowDataFromHive> createState() => _ShowDataFromHiveState();
}

class _ShowDataFromHiveState extends State<ShowDataFromHive> {
  //TextEditingController qtyController = TextEditingController();
  final dataBox = Hive.box('sojib');

  //List<TextEditingController> controllers = [];
  final Map<String, TextEditingController> _controllers = {};

  List<dynamic> data = [];
  List<dynamic> searchedData = [];
  bool isSearching = false;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();

    // for (var item in data) {
    //   _controllers[item['title']] = TextEditingController();
    // }

    for (var item in data) {
      _controllers[item['title']] =
          TextEditingController(text: item['quantity'] ?? '');
    }
    setState(() {});
  }

  Future<void> getData() async {
    data = dataBox.get('apiData');

    // for (var item in data) {
    //   _controllers[item['title']] =
    //       TextEditingController(text: item['quantity'] ?? '');
    // }
    // setState(() {});
  }

  void saveQuantity(String title, String quantity) {
    for (var item in data) {
      if (item['title'] == title) {
        item['quantity'] = quantity;
        //break;
      }
    }
    dataBox.put('apiData', data);
  }

  Future<void> mergeQuantityIntoData() async {
    for (int i = 0; i < data.length; i++) {
      data[i]['quantity'] = _controllers[data[i]["title"]]?.text.toString();
    }

    dataBox.put('apiData', data);

    for (int i = 0; i < data.length; i++) {
      _controllers[data[i]["title"]]?.text = '';
    }

    print(dataBox.get("apiData").toString());

    setState(() {});
  }

  void SearchField(String query) {
    if (query.isEmpty) {
      searchedData = data;
    } else {
      isSearching = false;
      searchedData = data
          .where(
            (item) => item['title'].toLowerCase().contains(
                  query.toLowerCase(),
                ),
          )
          .toList();
    }
  }

  Future<void> deleteIndexData(int index) async {
    if (searchedData.isNotEmpty) {
      final itemToDelete = searchedData[index];
      data.remove(itemToDelete);

      await dataBox.put('apiData', data);

      setState(() {
        searchedData.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No matching data to delete')),
      );
    }
  }

  Future<void> deleteAllData() async {
    await dataBox.delete('apiData');
    data.clear();
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text(
          'Show Data From Hive',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          SizedBox(
            width: 380,
            child: Card(
              elevation: 50,
              child: TextField(
                onChanged: (value) {
                  SearchField(value);
                  isSearching = true;
                  setState(() {});
                },
                controller: searchController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  fillColor: Colors.white10,
                  filled: true,
                  hintText: "Search",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
          ),
          Expanded(
            child: data.isEmpty
                ? Center(child: Text('No data available'))
                : ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: isSearching ? searchedData.length : data.length,
                    itemBuilder: (context, index) {
                      List<dynamic> finalList =
                          isSearching ? searchedData : data;

                      var controller = _controllers[finalList[index]['title']]!;

                      return Card(
                        elevation: 50,
                        color: Colors.grey,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                finalList[index]['title'] ?? 'No Title',
                                style: TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                finalList[index]['body'] ?? 'No Body',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              trailing: ElevatedButton(
                                onPressed: () async {
                                  if (isSearching) {
                                    await deleteIndexData(index);
                                  } else {
                                    await data.removeAt(index);
                                  }

                                  setState(() {});
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
                                controller: controller,
                                onChanged: (value) {
                                  saveQuantity(
                                      finalList[index]['title'], value);
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
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(
                            //       horizontal: 10, vertical: 10),
                            //   child: SizedBox(
                            //     width: 400,
                            //     height: 50,
                            //     child: ElevatedButton(
                            //       onPressed: () async {
                            //         if (isSearching) {
                            //           await deleteElementFromList(index);
                            //         } else {
                            //           await data.removeAt(index);
                            //         }
                            //
                            //         setState(() {});
                            //       },
                            //       style: ElevatedButton.styleFrom(
                            //         elevation: 15,
                            //         backgroundColor: Colors.red,
                            //         padding: EdgeInsets.symmetric(
                            //             horizontal: 16, vertical: 12),
                            //         shape: RoundedRectangleBorder(
                            //           borderRadius: BorderRadius.circular(8),
                            //         ),
                            //       ),
                            //       child: Text(
                            //         'Delete',
                            //         style: TextStyle(color: Colors.white),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Row(
            children: [
              Expanded(
                flex: 50,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ElevatedButton(
                    onPressed: () async {
                      await deleteAllData();
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 50,
                      backgroundColor: Colors.red,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Delete all Data',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              // Expanded(
              //   flex: 50,
              //   child: Padding(
              //     padding: const EdgeInsets.only(right: 8),
              //     child: ElevatedButton(
              //       onPressed: () {
              //         mergeQuantityIntoData();
              //         Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //               builder: (context) => FetchDataFromApi(),
              //             ));
              //       },
              //       style: ElevatedButton.styleFrom(
              //         elevation: 50,
              //         backgroundColor: Colors.green,
              //         padding:
              //             EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(8),
              //         ),
              //       ),
              //       child: Text(
              //         'Add',
              //         style: TextStyle(color: Colors.white),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}

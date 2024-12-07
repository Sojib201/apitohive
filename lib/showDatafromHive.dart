import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ShowDataFromHive extends StatefulWidget {
  const ShowDataFromHive({super.key});

  @override
  State<ShowDataFromHive> createState() => _ShowDataFromHiveState();
}

class _ShowDataFromHiveState extends State<ShowDataFromHive> {
  TextEditingController qtyController = TextEditingController();
  final dataBox = Hive.box('sojib');
  final newBox = Hive.box('newBox');
  //List<TextEditingController> controllers = [];
  final Map<String, TextEditingController> _controllers = {};


  List<Map<String, dynamic>> mergedData=[];



  List<dynamic> data = [];
  List<dynamic> searchedData = [];
  bool isSearching = false;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();

    for (var item in data) {
      _controllers[item['title']] = TextEditingController();

    }


    // controllers = List.generate(
    //   data.length,
    //   (index) => TextEditingController(),
    // );
  }

  void mergeData() {
    List<dynamic> dataBoxData = dataBox.get('apiData');
    List<dynamic> newBoxData = newBox.get('quantity');

    mergedData = List.generate(dataBoxData.length, (index) {
      return {
        'title': dataBoxData[index]['title'],
        'body': dataBoxData[index]['body'],
        'quantity': index < newBoxData.length ? newBoxData[index] : null,
      };
    });

    setState(() {});
  }

  Future<void> getData() async {
    data = dataBox.get('apiData');
  }

  void SearchField(String query) {
    if (query.isEmpty) {
      searchedData = data;
    } else {
      isSearching = false;
      searchedData = data
          .where((item) =>
              item['title'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  Future<void> deleteElementFromList(int index) async {
    if (searchedData.isNotEmpty) {
      final itemToDelete = searchedData[index];
      data.remove(itemToDelete);

      await dataBox.put('apiData', data);

      setState(() {
        searchedData.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Searched item deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No matching data to delete')),
      );
    }
  }

  Future<void> deleteData() async {
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
            width: 374,
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
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: TextField(
                                // onChanged: (value) async {
                                //   await newBox.put('quantity', value);
                                //
                                //   ScaffoldMessenger.of(context).showSnackBar(
                                //     SnackBar(content: Text('Quantity updated in Hive')),
                                //   );
                                // },

                                onChanged: (value) async {
                                  await newBox.put('quantity', value);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Quantity updated in Hive'),
                                    ),
                                  );
                                },

                                controller:controller,
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
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: SizedBox(
                                width: 400,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (isSearching) {
                                      await deleteElementFromList(index);
                                    } else {
                                      await data.removeAt(index);
                                    }

                                    setState(() {});
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 15,
                                    backgroundColor: Colors.red,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(
            height: 50,
            width: 365,
            child: ElevatedButton(
              onPressed: () async {
                await deleteData();
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                elevation: 50,
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Delete All Data',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }
}

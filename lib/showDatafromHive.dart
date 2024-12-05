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
  List<dynamic> data = [];
  List<dynamic> searchedData = [];
  bool isSearching = false;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    data = dataBox.get('apiData');
  }

  void SearchField(String query) {
    if (query.isEmpty) {
      searchedData = data;
    } else {
      //searchedData.clear();
      isSearching = false;
      searchedData = data
          .where((item) =>
              item['title'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  Future<void> deleteData() async {
    await dataBox.delete('apiData');
    data.clear();
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
          TextField(
            onChanged: (value) {
              SearchField(value);
              isSearching = true;
              setState(() {});
              // searchedData.clear();
              // isSearching=false;
              // setState(() {
              //
              // });
            },
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Search",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            ),
          ),
          Expanded(
            child: data.isEmpty
                ? Center(child: Text('No data available'))
                : ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: isSearching ? searchedData.length : data.length,
                    itemBuilder: (context, index) {
                      List<dynamic> finalList = [];
                      isSearching ? finalList = searchedData : finalList = data;

                      return Card(
                        color: Colors.grey,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            ListTile(
                              title: Text(
                                finalList[index]['title'] ?? 'No Title',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle:
                                  Text(finalList[index]['body'] ?? 'No Body'),
                            ),
                            TextField(
                              controller:qtyController,
                              decoration: InputDecoration(),
                            ),
                          ],
                        ),
                      );
                    }),
          ),
          ElevatedButton(
            onPressed: () async {
              await deleteData();
              print('hijife');
              setState(() {});
            },
            child: Text('Delete Data'),
          ),
        ],
      ),
    );
  }
}

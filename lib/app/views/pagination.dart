import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Item {
  final int id;
  final String title;

  Item({required this.id, required this.title});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      title: json['title'],
    );
  }
}

class PaginationPage extends StatefulWidget {
  @override
  _PaginationPageState createState() => _PaginationPageState();
}

class _PaginationPageState extends State<PaginationPage> {
  int currentPage = 1;
  int itemsPerPage = 15;
  List<Item> itemList = [];
  bool isLoading = false;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchNextPage(); // Fetch initial page
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isLoading) {
        fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<Item>> fetchData(int page, int limit) async {
    String apiUrl =
        'https://jsonplaceholder.typicode.com/posts?_page=$page&_limit=$limit';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body) as List<dynamic>;
      List<Item> items = jsonData.map((item) => Item.fromJson(item)).toList();
      return items;
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  Future<void> fetchNextPage() async {
    if (isLoading) return;
    isLoading = true;

    try {
      var nextPageItems = await fetchData(currentPage, itemsPerPage);
      setState(() {
        itemList.addAll(nextPageItems);
        currentPage++;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      isLoading = false;
    }
  }

  Widget buildItemList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: itemList.length + 1,
      itemBuilder: (context, index) {
        if (index < itemList.length) {
          return ListTile(
            title: Text(itemList[index].title),
            subtitle: Text('Item ID: ${itemList[index].id}'),
          );
        } else {
          if (isLoading) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          } else {
            return Container(
              // height: 30,///
              width: double.infinity,
              child: Center(
                  // child: Text(" loading...."),
                  ),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagination Demo'),
      ),
      body: buildItemList(),
    );
  }
}

import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:untitled15/model.dart';


class MyInfiniteScrollPagination extends StatefulWidget {
  const MyInfiniteScrollPagination({Key? key}) : super(key: key);

  @override
  State<MyInfiniteScrollPagination> createState() =>
      _MyInfiniteScrollPaginationState();
}

class _MyInfiniteScrollPaginationState
    extends State<MyInfiniteScrollPagination> {

  // Dio _dio = Dio();
  late Dio dio=Dio();

  int offset = 0;
  int limit = 10;

  final PagingController<int, dynamic> _pagingController =
  PagingController(firstPageKey: 0);

  @override
  void initState() {

    _pagingController.addPageRequestListener((offset) {
      fetchNewPage();
    });
    super.initState();
  }

  getDataFromApi() async {
    log("Getting Data:");
   var url1 =
        "https://www.breakingbadapi.com/api/characters?limit=$limit&offset=$offset";
    final response = await dio.get(url1);

    if (response.statusCode == 200) {

      // return a decoded body
    var c =response.data;
   List characterDetail= c.map((r)=>CharacterModel.fromJson(r)).toList();
      // (json.decode(response.data) as List)
          // .map((data) => CharacterModel.fromJson(data))
          // .toList();
      print('Offset: $offset');
      print('Name[0]: ${characterDetail[0].name}');
      return characterDetail;
      //
    } else {
      return Future.error("Server Error !");
    }
  }

  Future<void> fetchNewPage() async {
    try {
      final List characterDetail = await getDataFromApi();
      //print('Name: ${characterDetail[1].name}');
      // to append data, as more data is still available and can be loaded
      _pagingController.appendPage(characterDetail, offset++);
      //_pagingController.appendLastPage(characterDetail);
    } catch (e) {
      _pagingController.error = e;
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Infinite Scroll Pagination'),
      centerTitle: true,
      ),
      body: PagedListView<int, dynamic>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<dynamic>(
          itemBuilder: (context, singleCharacterDetail, index) {
            return Column(
              children: [
                card(singleCharacterDetail),
                if (index == _pagingController.itemList!.length - 1)
                  Container(
                    padding: const EdgeInsets.all(15.0),
                    child: const Text("Please Wait"),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget card(CharacterModel singleCharacterDetail) {
  return Container(
    width: double.maxFinite,
    margin: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 25.0),
    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5.0),
      border: Border.all(color: Colors.black, width: 1.0),
    ),
    child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child:

            Image.network(
              singleCharacterDetail.pictureUrl,
              width: 55,
            ),
          ),
          const SizedBox(width: 12.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  width: 230,
                  child: Text(
                    '${singleCharacterDetail.id}. ${singleCharacterDetail.name}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    softWrap: true,
                    //overflow: TextOverflow.fade,
                  ),
                ),

              Text(
                'Birthday: ${singleCharacterDetail.birthday}',
                style: const TextStyle(fontSize: 15.0, color: Colors.grey),
              ),
              Text(
                'Status: ${singleCharacterDetail.status}',
                style: const TextStyle(fontSize: 15.0, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),

  );
}
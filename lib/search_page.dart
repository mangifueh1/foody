import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'colors.dart';
import 'package:http/http.dart' as http;
// import 'package:webview_flutter/webview_flutter.dart';
import 'homecard.dart';
// import 'main.dart';
import 'model.dart';

// ignore: must_be_immutable
class SearchPage extends StatefulWidget {
  String? search;
  SearchPage({super.key, this.search});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // late List<Recipe> _recipes;

  bool _isLoading = true;

  // Future<void> getRecipes() async {
  //   _recipes = await RecipeApi.getRecipe();
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }
  String? text;
  List<Model> list = <Model>[];
  Future<void> getApiData(search) async {
    final url =
        "https://api.edamam.com/search?q=$search&app_id=c457b03f&app_key=ee3f268d5dc3d0e4447dd7d1a7b37a04&from=0&to=100&calories=591-722&health=alcohol-free";
    var response = await http.get(Uri.parse(url));
    Map json = jsonDecode(response.body);
    json['hits'].forEach((e) {
      Model model = Model(
        image: e['recipe']['image'],
        url: e['recipe']['url'],
        source: e['recipe']['source'],
        label: e['recipe']['label'],
        time: e['recipe']['totalTime'],
        rating: e['recipe']['yield'],
        ingredients: e['recipe']['ingredientLines'],
      );
      setState(() {
        list.add(model);
        _isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getApiData(widget.search);
  }

  @override
  Widget build(BuildContext context) {
    // double screenWidth = MediaQuery.of(context).size.width;
    String? search = widget.search;
    // double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: FittedBox(
          child: Text(
            "Search Results for $search",
            style: GoogleFonts.montserrat(
              fontSize: 20,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 27.0,
            left: 10,
            right: 10,
          ),
          child: _isLoading == true
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 51, 128, 82),
                  ),
                )
              : ListView.builder(
                  itemCount: list.length,
                  itemExtent: 230,
                  itemBuilder: (context, index) {
                    final x = list[index];
                    return GestureDetector(
                      onTap: null,
                      // () => Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => Scaffold(
                      //       appBar: AppBar(
                      //         elevation: 0,
                      //         backgroundColor: Colors.transparent,
                      //         centerTitle: true,
                      //         title: Text(
                      //           "Recipe",
                      //           style: GoogleFonts.montserrat(
                      //             fontSize: 30,
                      //             color: mainColor,
                      //             fontWeight: FontWeight.bold,
                      //             // height: 20,
                      //           ),
                      //         ),
                      //         leading: GestureDetector(
                      //           onTap: () => Navigator.pop(context),
                      //           child: Container(
                      //             height: 60,
                      //             width: 60,
                      //             decoration: BoxDecoration(
                      //               color: iconCatBKG,
                      //               borderRadius:
                      //                   BorderRadius.circular(15),
                      //             ),
                      //             child: Align(
                      //               alignment: Alignment.center,
                      //               child: Padding(
                      //                 padding: const EdgeInsets.only(
                      //                     left: 8.0),
                      //                 child: Icon(
                      //                   Icons.arrow_back_ios,
                      //                   color: mainColor,
                      //                   size: 25,
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //       body: SafeArea(
                      //         child: WebView(
                      //           initialUrl: x.url.toString(),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      child: HomeRecipeCard(
                        title: x.label.toString(),
                        cookTime: x.time.toString() == "0"
                            ? "Unavailable"
                            : x.time.toString(),
                        rating: x.rating!.round().toString(),
                        thumbnailUrl: x.image.toString(),
                        source: x.source.toString(),
                        ingredients: x.ingredients!.length,
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

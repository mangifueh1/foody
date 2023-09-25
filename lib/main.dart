// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'categories.dart';
import 'colors.dart';
import 'homecard.dart';
import 'model.dart';
import 'search_page.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
   SystemUiOverlayStyle(statusBarColor: mainColor.withOpacity(0.83)),
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // int init = Categories(selectedIndex: 0);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foody',
      debugShowCheckedModeBanner: false,
      color: mainColor,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: HomePage(
        initial: 0,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({
    super.key,
    required this.initial,
  });
  int initial;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  bool _error = false;

  String? text;
  List<Model> list = <Model>[];

  late int sIndex;
  Future getApiData() async {
    String? cName = categories[sIndex].toString();
    var url =
        "https://api.edamam.com/search?q=$cName&app_id=c457b03f&app_key=ee3f268d5dc3d0e4447dd7d1a7b37a04&from=0&to=100&calories=591-722&health=alcohol-free";
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
    sIndex = widget.initial;
    getApiData();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    PageController scrollController = PageController(
      initialPage: sIndex,
      keepPage: true,
      viewportFraction: 0.34,
    );

    TextEditingController searchController = TextEditingController();

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.5,
                  ),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        child: Text(
                          "WELCOME TO FOODY",
                          style: GoogleFonts.montserrat(
                            fontSize: 30,
                            color: mainColor,
                          ),
                        ),
                      ),
                      const FittedBox(
                        child: Text(
                          "What Do You Want To Cook Today?",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.black,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  child: FittedBox(
                    child: Search(
                      screenWidth: screenWidth,
                      text: text,
                      control: searchController,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Categories(
                  screenWidth: screenWidth,
                  i: sIndex,
                  controller: scrollController,
                ),
                // const SizedBox(height: 15),
                Container(
                  width: screenWidth,
                  height: screenHeight / 1.5,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: _isLoading == true
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 51, 128, 82),
                          ),
                        )
                      : ListView.builder(
                              // physics: const ScrollPhysics(),

                              itemCount: 10,
                              itemExtent: 230,
                              padding: const EdgeInsets.only(
                                bottom: 45,
                              ),
                              itemBuilder: (context, index) {
                                // String name = categories[i];
                                final x = list[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            WebPage(url: x.url),
                                      ),
                                    );
                                  },
                                  child: HomeRecipeCard(
                                    title: x.label.toString(),
                                    cookTime: x.time.toString() == "0.0"
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WebPage extends StatefulWidget {
  const WebPage({
    super.key,
    this.url,
  });

  final String? url;

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Recipe",
          style: GoogleFonts.montserrat(
            fontSize: 30,
            color: mainColor,
            // height: 20,
          ),
        ),
      ),
      body: WebView(
        initialUrl: widget.url,
      ),
    );
  }
}

class Categories extends StatefulWidget {
  Categories({
    super.key,
    this.screenWidth,
    // required this.ssIndex,
    // required this.nextData,
    required this.controller,
    required this.i,
    // required this.selectedIndex,
  });
  PageController controller;
  // int i;
  final double? screenWidth;
  int i;
  // Future nextData;

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10,
        bottom: 10,
      ),
      child: SizedBox(
        height: 50,
        width: widget.screenWidth,
        child: PageView.builder(
          controller: widget.controller,
          pageSnapping: false,
          padEnds: false,
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            String catName = categories[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        initial: selectedIndex,
                      ),
                    ),
                  );
                });

                // getApiData();
              },
              child: Container(
                // height: 60,
                width: 100,
                margin: const EdgeInsets.only(right: 15, bottom: 10),
                decoration: BoxDecoration(
                  color: widget.i == index ? mainColor : iconCatBKG,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      offset: const Offset(
                        0.5,
                        3.0,
                      ),
                      blurRadius: 10.0,
                      spreadRadius: -6.0,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    catName,
                    style: GoogleFonts.montserrat(
                      color: widget.i == index ? iconCatBKG : mainColor,
                      fontSize: widget.i == index ? 12 : 10,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Search extends StatelessWidget {
  Search({
    super.key,
    required this.screenWidth,
    this.text,
    required this.control,
  });

  String? text;
  final double screenWidth;
  final TextEditingController control;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      width: screenWidth,
      // padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: iconCatBKG,
        borderRadius: BorderRadius.circular(11),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            offset: const Offset(
              1.0,
              3.0,
            ),
            blurRadius: 5.0,
            spreadRadius: -6.0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 50,
            width: 200,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: control,
              onChanged: (v) {
                text = v;
              },
              decoration: InputDecoration(
                hintText: "Search a keyword",
                hintStyle: GoogleFonts.montserrat(
                  fontSize: 15,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: ((context) => SearchPage(
                        search: text,
                      )),
                ),
              );
              control.clear();
            },
            child: Container(
              height: 50,
              width: 50,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 51, 128, 82),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Center(
                child: Icon(
                  Icons.search_outlined,
                  color: iconColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

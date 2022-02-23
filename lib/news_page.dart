import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';


class NewsPageApp extends StatefulWidget {
  const NewsPageApp({Key? key, required this.gameTitle, required this.gameId, required this.newsCount}) : super(key: key);

  final String gameTitle;
  final String gameId;
  final String newsCount;

  @override
  _NewsPageAppState createState() => _NewsPageAppState();
}

class _NewsPageAppState extends State<NewsPageApp> {
  late Future<Model> futureModel;


  @override
  void initState() {
    super.initState();
    // Välitetään fetchNews funktiolle pelin tunnus ja uutisten lukumäärä.
    futureModel = fetchNews(widget.gameId, widget.newsCount);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('News for ' + widget.gameTitle),
        ),
        body: Center(
          child: FutureBuilder<Model>(
            future: futureModel,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                 return ListView.builder(
                  itemCount: snapshot.data!.articles.length,
                  itemBuilder: (context, index) {
                    var article = snapshot.data!.articles[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                              children: <Widget>[

                                Container(height: 10),
                                Text(article.newsTitle, textScaleFactor: 2,),
                                //Text(article.newsContent),                             
                                Html(data: article.newsContent)                                                                                             
                              ],
                            ),
                          );
                  });
           
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              
                // By default, show a loading spinner.
              return const CircularProgressIndicator();
              
            },
          ),
        ),
      ),
    );
  }
}


// Future funktio, jonka avulla haetaan webbidata netistä
Future<Model> fetchNews(gameId, newsCount) async {
  final response = await http
      .get(Uri.parse('https://api.steampowered.com/ISteamNews/GetNewsForApp/v0002/?appid=$gameId&count=$newsCount&maxlength=2500&format=json'));
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Model.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Model');
  }
}

// Dataluokka articles taulukkoa varten
class Model {
  Model({
    required this.articles,
  });

  List<NewsItem> articles;

  // Model-dataluokan luonti json datan pohjalta
  factory Model.fromJson(Map<String, dynamic> json) => Model(
        articles: List<NewsItem>.from(
            json["appnews"]["newsitems"].map((x) => NewsItem.fromJson(x))),
      );

  // articles taulukon muutos takaisin json-muotoon
  Map<String, dynamic> toJson() => {
        "articles": List<dynamic>.from(articles.map((x) => x.toJson())),
      };
}

// Dataluokka articles taulukon yksittäisille uutisille
class NewsItem {
  final String newsTitle;
  final String newsContent;

  const NewsItem({
    required this.newsTitle,
    required this.newsContent,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      newsTitle: json['title'],
      newsContent: json['contents'],
    );
  }
  Map<String, dynamic> toJson() => {
    "newsTitle": newsTitle,
    "newsContent": newsContent,
  };

}

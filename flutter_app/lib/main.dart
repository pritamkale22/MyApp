import 'package:flutter/material.dart';

import 'movie_detail.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';

import 'package:dio/dio.dart';

import 'package:retrofit/http.dart';


// @RestApi(baseUrl: "https://api.androidhive.info/")
// abstract class ApiClient {
//   factory ApiClient( String baseUrl) = _ApiClient;
//
//   @GET('json/movies.json')
//   Future<List<dynamic>> getMovees();
// }


var movies;
List<dynamic> _searchResult = [];
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  Color mainColor = const Color(0xff3C3261);
  @override
  Widget build(BuildContext context) {


      return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(

          primarySwatch: Colors.blue,
        ),
        home: MovieList(),
      );

      ;

  }
}
 Future<bool> checkConnection() async {
  var connection = false;
   var connectivityResult =  await (Connectivity().checkConnectivity());
   if (connectivityResult == ConnectivityResult.none) {
     connection = false;

   }
   else if (connectivityResult == ConnectivityResult.mobile) {
     connection =  true;
   }
   else if (connectivityResult == ConnectivityResult.wifi) {
     connection = true;
   }
   return connection;
 }

class MovieList extends StatefulWidget {


  @override
  MovieListState createState() {


      return new MovieListState();



  }
}

var one = 0;
class MovieListState extends State<MovieList> {


  TextEditingController controller = new TextEditingController();

  Color mainColor = const Color(0xff3C3261);

  void getData() async {
    var data = await getJson();

    setState(() {
      movies = data;
      if(one == 0) {
        one = 2;
        _searchResult = data;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    getData();

    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        elevation: 0.3,
        centerTitle: true,
        backgroundColor: Colors.white,

        title: new Text(
          'Movies',
          style: new TextStyle(
              color: mainColor,
              fontFamily: 'Arvo',
              fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          new Icon(
            Icons.menu,
            color: mainColor,
          )
        ],
      ),
      body: new Padding(
        padding: const EdgeInsets.all(16.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            new Container(
              color: Theme.of(context).primaryColor,
              child: new Padding(
                padding: const EdgeInsets.all(3.0),
                child: new Card(
                  child: new ListTile(
                    leading: new Icon(Icons.search),
                    title: new TextField(
                      controller: controller,
                      decoration: new InputDecoration(
                          hintText: 'Search', border: InputBorder.none),
                      onChanged: onSearchTextChanged,
                    ),
                    trailing: new IconButton(icon: new Icon(Icons.cancel), onPressed: () {
                      controller.clear();
                      onSearchTextChanged('');
                    },),
                  ),
                ),
              ),
            ),

            new Expanded(
              child: new ListView.builder(
                  itemCount: _searchResult == null ? 0 : _searchResult.length,
                  itemBuilder: (context, i) {
                    return new FlatButton(
                      child: new MovieCell(_searchResult, i),
                      padding: const EdgeInsets.all(0.0),
                      onPressed: () {
                        Navigator.push(context,
                            new MaterialPageRoute(builder: (context) {
                              return new MovieDetail(_searchResult[i]);
                            }));
                      },
                      color: Colors.white,
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult = [];
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {
        _searchResult = movies;
      });
      return;
    }


    setState(() {

      if(movies == null)
        for (var i in movies) {
          if (movies[i]['releaseYear'].contains(text) || movies[i]['title'].contains(text))
            _searchResult.add(movies[i]);
        };
    });
  }



}


Future<List<dynamic>> getJson() async {
  //var apiKey = getApiKey();
  Uri url = Uri.parse( 'https://api.androidhive.info/json/movies.json' );
  var response = await http.get(url );
  return json.decode(response.body);
}



class MovieCell extends StatelessWidget {
  final movies;
  final i;
  Color mainColor = const Color(0xff3C3261);
  var image_url = '';
  MovieCell(this.movies, this.i);

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Row(
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.all(0.0),
              child: new Container(
                margin: const EdgeInsets.all(16.0),
//                                child: new Image.network(image_url+movies[i]['poster_path'],width: 100.0,height: 100.0),
                child: new Container(
                  width: 70.0,
                  height: 70.0,
                ),
                decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.circular(10.0),
                  color: Colors.grey,
                  image: new DecorationImage(
                      image: new NetworkImage(
                          image_url + movies[i]['image']),
                      fit: BoxFit.cover),
                  boxShadow: [
                    new BoxShadow(
                        color: mainColor,
                        blurRadius: 5.0,
                        offset: new Offset(2.0, 5.0))
                  ],
                ),
              ),
            ),
            new Expanded(
                child: new Container(
                  margin: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                  child: new Column(
                    children: [
                      new Text(
                        movies[i]['title'],
                        style: new TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'Arvo',
                            fontWeight: FontWeight.bold,
                            color: mainColor),
                      ),
                      new Padding(padding: const EdgeInsets.all(2.0)),
                      new Text(
                        movies[i]['rating'].toString(),
                        maxLines: 3,
                        style: new TextStyle(
                            color: const Color(0xff8785A4), fontFamily: 'Arvo'),
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                )),
          ],
        ),
        new Container(
          width: 300.0,
          height: 0.5,
          color: const Color(0xD2D2E1ff),
          margin: const EdgeInsets.all(16.0),
        )
      ],
    );
  }

}


// class _ApiClient implements ApiClient {
//   _ApiClient(  this.baseUrl) {
//
//     baseUrl ??= 'https://gorest.co.in/public-api/';
//   }
//
//
//
//   String baseUrl;
//
//   @override
//   Future<List<dynamic>> getMovees() async {
//     Const _extra = <String, dynamic>{};
//
//     final _data = <String, dynamic>{};
//     final _result = await _dio.request<Map<String, dynamic>>('/users',
//         queryParameters: queryParameters,
//         options: RequestOptions(
//             method: 'GET',
//             headers: <String, dynamic>{},
//             extra: _extra,
//             baseUrl: baseUrl),
//         data: _data);
//     final value = ResponseData.fromJson(_result.data);
//     return value;
//
//   }
// }
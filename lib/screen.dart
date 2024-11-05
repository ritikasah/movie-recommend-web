import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<String>> getMovieRecommendations(String movieName) async {
  final url = Uri.parse(
      'https://movie-recommend-backend.onrender.com/recommend/?movie=$movieName');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    // Assuming the API returns a list of recommended movies in JSON format
    List<dynamic> recommendations = jsonDecode(response.body);
    return List<String>.from(recommendations);
  } else {
    throw Exception('Failed to fetch recommendations');
  }
}

class MovieRecommendations extends StatefulWidget {
  @override
  _MovieRecommendationsState createState() => _MovieRecommendationsState();
}

class _MovieRecommendationsState extends State<MovieRecommendations> {
  List<String> _recommendations = [];

  @override
  void initState() {
    super.initState();
    fetchRecommendations();
  }

  void fetchRecommendations() async {
    try {
      List<String> recommendations = await getMovieRecommendations('Inception');
      setState(() {
        _recommendations = recommendations;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Movie Recommendations')),
      body: ListView.builder(
        itemCount: _recommendations.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_recommendations[index]),
          );
        },
      ),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart'; // Add Google Fonts for better text appearance

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyCGXqieQTarkGB8Kaoa5u8U6GcEU8kcJwg",
          appId: "1:733389182480:web:011063215f30cac5e05c95",
          messagingSenderId: "733389182480",
          projectId: "movie-recommend-86f9b"));
  runApp(MovieRecommendationApp());
}

class MovieRecommendationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.deepPurple, // App-wide color scheme
        textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
      ),
      home: MovieRecommendationScreen(),
    );
  }
}

class MovieRecommendationScreen extends StatefulWidget {
  @override
  _MovieRecommendationScreenState createState() =>
      _MovieRecommendationScreenState();
}

class _MovieRecommendationScreenState extends State<MovieRecommendationScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _recommendations = [];
  bool _isLoading = false;
  String? _error;

  // Function to make an API request
  Future<void> fetchRecommendations(String movieName) async {
    setState(() {
      _isLoading = true;
      _recommendations = [];
      _error = null;
    });

    try {
      final url = Uri.parse(
          'https://movie-recommend-backend.onrender.com/recommend/?movie=$movieName');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Decode the response
        List<dynamic> recommendations = jsonDecode(response.body);
        setState(() {
          _recommendations = List<String>.from(recommendations);
        });
      } else {
        setState(() {
          _error = 'Failed to fetch recommendations';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Movie Recommendations',
          style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image to enhance the UI
          Image.network(
            'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.5),
            colorBlendMode: BlendMode.darken,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // TextField for user input
                TextField(
                  controller: _controller,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Enter a movie name',
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.deepPurple.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Button to fetch recommendations
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    String movieName = _controller.text.trim();
                    if (movieName.isNotEmpty) {
                      fetchRecommendations(movieName);
                    }
                  },
                  child: Text('Get Recommendations',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                SizedBox(height: 20),
                // Display a loading indicator
                if (_isLoading) Center(child: CircularProgressIndicator()),
                // Display error if any
                if (_error != null)
                  Text(_error!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                // Display recommendations in a ListView
                Expanded(
                  child: ListView.builder(
                    itemCount: _recommendations.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.deepPurple.withOpacity(0.8),
                        child: ListTile(
                          leading: Icon(
                            Icons.movie,
                            color: Colors.white,
                            size: 30,
                          ),
                          title: Text(
                            _recommendations[index],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

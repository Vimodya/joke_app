import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class JokeService {
  final Dio _dio = Dio();

  Future<List<Map<String, dynamic>>> fetchJokesRaw() async {
    try {
      final response =
          await _dio.get('https://v2.jokeapi.dev/joke/Any?amount=5');
      if (response.statusCode == 200) {
        final List<dynamic> jokesJsonList = response.data['jokes'];
        final jokes = jokesJsonList.cast<Map<String, dynamic>>();
        await _cacheJokes(jokes);
        return jokes;
      } else {
        throw Exception("Failed to load jokes");
      }
    } catch (e) {
      print("Error fetching jokes: $e");
      return await loadCachedJokes();
    }
  }

  Future<void> _cacheJokes(List<Map<String, dynamic>> jokes) async {
    final prefs = await SharedPreferences.getInstance();
    final jokesJson = jsonEncode(jokes);
    await prefs.setString('cached_jokes', jokesJson);
  }

  Future<List<Map<String, dynamic>>> loadCachedJokes() async {
    final prefs = await SharedPreferences.getInstance();
    final jokesJson = prefs.getString('cached_jokes');
    if (jokesJson != null) {
      final List<dynamic> jokesList = jsonDecode(jokesJson);
      return jokesList.cast<Map<String, dynamic>>();
    } else {
      return [];
    }
  }
}

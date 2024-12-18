import 'package:flutter/material.dart';
import 'joke_service.dart';

class JokeListPage extends StatefulWidget {
  const JokeListPage({Key? key}) : super(key: key);

  @override
  State<JokeListPage> createState() => _JokeListPageState();
}

class _JokeListPageState extends State<JokeListPage> {
  final JokeService _jokeService = JokeService();
  List<Map<String, dynamic>> _jokes = [];
  int _currentIndex = 0;
  bool _isLoading = false;

  Future<void> _fetchJokes() async {
    setState(() => _isLoading = true);
    try {
      _jokes =
          (await _jokeService.fetchJokesRaw()).cast<Map<String, dynamic>>();
      _currentIndex = 0;
    } catch (e) {
      print('Error fetching jokes: $e');

      if (_jokes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("Unable to fetch jokes and no cached jokes available!")),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();

    _loadCachedJokes();
  }

  Future<void> _loadCachedJokes() async {
    final cachedJokes = await _jokeService.loadCachedJokes();
    if (cachedJokes.isNotEmpty) {
      setState(() {
        _jokes = cachedJokes.cast<Map<String, dynamic>>();
        _currentIndex = 0;
      });
    }
  }

  void _nextJoke() {
    if (_currentIndex < _jokes.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  void _previousJoke() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final joke = _jokes.isNotEmpty ? _jokes[_currentIndex] : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Joke App"),
        backgroundColor: const Color.fromARGB(255, 190, 154, 173),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFeac7c7), Color(0xffe8a2a2), Color(0xFFC06C84)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Feeling bored ? or sad ?",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 196, 60, 101)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchJokes,
              label: const Text("Let's fetch jokes 🥳"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFeae0da),
                padding:
                    const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white))
                : _jokes.isEmpty
                    ? const Text(
                        "No jokes fetched yet! Click the button above.",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      )
                    : Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: JokeCard(
                            setup: joke!['setup'] ?? '',
                            delivery: joke['delivery'] ?? '',
                            currentIndex: _currentIndex + 1,
                            total: _jokes.length,
                          ),
                        ),
                      ),
            if (_jokes.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _previousJoke,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white54,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  ElevatedButton(
                    onPressed: _nextJoke,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white54,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Icon(Icons.arrow_forward, color: Colors.black),
                  ),
                ],
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class JokeCard extends StatelessWidget {
  final String setup;
  final String delivery;
  final int currentIndex;
  final int total;

  const JokeCard({
    Key? key,
    required this.setup,
    required this.delivery,
    required this.currentIndex,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFE3E3),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "😂",
            style: TextStyle(fontSize: 60),
          ),
          const SizedBox(height: 20),
          Text(
            setup,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(221, 61, 29, 29),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            delivery,
            style: const TextStyle(
              fontSize: 18,
              color: Color.fromARGB(136, 225, 133, 133),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            "Joke $currentIndex of $total",
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: JokeListPage(),
  ));
}

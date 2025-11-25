import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

void main() {
  runApp(const QuotesApp());
}

class QuotesApp extends StatelessWidget {
  const QuotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quotes API Viewer',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const QuotesPage(),
    );
  }
}

class QuotesPage extends StatefulWidget {
  const QuotesPage({super.key});

  @override
  State<QuotesPage> createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  // List API endpoints yang lebih reliable
  final List<String> apiUrls = [
    "https://api.quotable.io/random",
    "https://dummyjson.com/quotes/random",
    "https://type.fit/api/quotes",
  ];

  Future<Map<String, dynamic>> fetchQuote() async {
    // Coba API pertama (Quotable)
    try {
      final response = await http
          .get(Uri.parse(apiUrls[0]))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'content': data['content'],
          'author': data['author'],
          'source': 'Quotable API',
        };
      }
    } catch (e) {
      print("API 1 error: $e");
    }

    // Coba API kedua (DummyJSON)
    try {
      final response = await http
          .get(Uri.parse(apiUrls[1]))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'content': data['quote'],
          'author': data['author'],
          'source': 'DummyJSON API',
        };
      }
    } catch (e) {
      print("API 2 error: $e");
    }

    // Coba API ketiga (Type.fit) - returns array of quotes
    try {
      final response = await http
          .get(Uri.parse(apiUrls[2]))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> quotes = json.decode(response.body);
        if (quotes.isNotEmpty) {
          final randomIndex = Random().nextInt(quotes.length);
          final quote = quotes[randomIndex];
          return {
            'content': quote['text'],
            'author': quote['author'] ?? 'Unknown',
            'source': 'Type.fit API',
          };
        }
      }
    } catch (e) {
      print("API 3 error: $e");
    }

    // Jika semua API gagal, gunakan quotes lokal
    return _getRandomLocalQuote();
  }

  // Quotes lokal sebagai fallback
  final List<Map<String, String>> _localQuotes = [
    {
      'content': 'The only way to do great work is to love what you do.',
      'author': 'Steve Jobs',
      'source': 'Local',
    },
    {
      'content': 'Innovation distinguishes between a leader and a follower.',
      'author': 'Steve Jobs',
      'source': 'Local',
    },
    {
      'content':
          'Your time is limited, so don\'t waste it living someone else\'s life.',
      'author': 'Steve Jobs',
      'source': 'Local',
    },
    {
      'content': 'Be yourself; everyone else is already taken.',
      'author': 'Oscar Wilde',
      'source': 'Local',
    },
    {
      'content': 'So many books, so little time.',
      'author': 'Frank Zappa',
      'source': 'Local',
    },
    {
      'content': 'You only live once, but if you do it right, once is enough.',
      'author': 'Mae West',
      'source': 'Local',
    },
  ];

  Map<String, dynamic> _getRandomLocalQuote() {
    final random = Random();
    final quote = _localQuotes[random.nextInt(_localQuotes.length)];
    return {
      'content': quote['content'],
      'author': quote['author'],
      'source': quote['source'],
    };
  }

  late Future<Map<String, dynamic>> _quoteFuture;

  @override
  void initState() {
    super.initState();
    _quoteFuture = fetchQuote();
  }

  void _reloadQuote() {
    setState(() {
      _quoteFuture = fetchQuote();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Random Quotes API Viewer"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reloadQuote),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _quoteFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingWidget();
          } else if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          } else if (snapshot.hasData) {
            return _buildQuoteWidget(snapshot.data!);
          } else {
            return _buildErrorWidget("Tidak ada data yang diterima");
          }
        },
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Memuat quote..."),
        ],
      ),
    );
  }

  Widget _buildQuoteWidget(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Source indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  data['source'] ?? 'API',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Quote content
              Text(
                '"${data['content']}"',
                style: const TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Author
              Text(
                "- ${data['author']}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              "Gagal Memuat Quote",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getUserFriendlyError(error),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _reloadQuote,
              icon: const Icon(Icons.refresh),
              label: const Text("Coba Lagi"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                setState(() {
                  _quoteFuture = Future.value(_getRandomLocalQuote());
                });
              },
              child: const Text("Gunakan Quote Offline"),
            ),
          ],
        ),
      ),
    );
  }

  String _getUserFriendlyError(String error) {
    if (error.contains('ClientException') ||
        error.contains('Failed to fetch')) {
      return 'Koneksi internet bermasalah. Periksa koneksi Anda dan coba lagi.';
    } else if (error.contains('timeout')) {
      return 'Permintaan timeout. Server mungkin sibuk.';
    } else if (error.contains('404')) {
      return 'API tidak ditemukan.';
    } else {
      return 'Terjadi kesalahan: $error';
    }
  }
}

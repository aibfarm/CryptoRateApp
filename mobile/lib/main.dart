import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Exchange Rate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ExchangeRateScreen(),
    );
  }
}

class ExchangeRateData {
  final String symbol;
  final String price;
  final double rate;
  final String time;

  ExchangeRateData({
    required this.symbol,
    required this.price,
    required this.rate,
    required this.time,
  });

  factory ExchangeRateData.fromJson(Map<String, dynamic> json) {
    return ExchangeRateData(
      symbol: json['symbol'],
      price: json['price'],
      rate: json['rate'].toDouble(),
      time: json['time'],
    );
  }
}

class ExchangeRateScreen extends StatefulWidget {
  const ExchangeRateScreen({super.key});

  @override
  State<ExchangeRateScreen> createState() => _ExchangeRateScreenState();
}

class _ExchangeRateScreenState extends State<ExchangeRateScreen> {
  ExchangeRateData? _exchangeRateData;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _timer;
  String _apiUrl = 'http://192.168.2.227:8080/api/exchange-rate/usdt-btc'; // Default to port 8080

  @override
  void initState() {
    super.initState();
    _fetchExchangeRate();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateApiUrl(String url) {
    setState(() {
      _apiUrl = url;
    });
  }

  void _startAutoRefresh() {
    _timer?.cancel(); // Cancel existing timer
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchExchangeRate();
    });
  }

  Future<void> _fetchExchangeRate() async {
    print('[Flutter] Starting API request to: $_apiUrl');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('[Flutter] Making HTTP GET request...');
      final response = await http.get(Uri.parse(_apiUrl));
      
      print('[Flutter] Response received:');
      print('[Flutter]   Status Code: ${response.statusCode}');
      print('[Flutter]   Headers: ${response.headers}');
      print('[Flutter]   Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('[Flutter] Successfully parsed JSON data: $data');
        setState(() {
          _exchangeRateData = ExchangeRateData.fromJson(data);
          _isLoading = false;
        });
        print('[Flutter] State updated successfully');
      } else {
        final errorMsg = 'Failed to fetch data: ${response.statusCode} - ${response.body}';
        print('[Flutter] Error: $errorMsg');
        setState(() {
          _errorMessage = errorMsg;
          _isLoading = false;
        });
      }
    } catch (e) {
      final errorMsg = 'Error: $e';
      print('[Flutter] Exception caught: $errorMsg');
      print('[Flutter] Stack trace: ${StackTrace.current}');
      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
      });
    }
  }

  void _showSettingsDialog() {
    final TextEditingController controller = TextEditingController(text: _apiUrl);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('API Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter API URL:'),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'http://192.168.2.227:8080/api/exchange-rate/usdt-btc',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              const Text(
                'Common URLs:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildQuickUrlButton(
                controller, 
                'Local (Port 8080)', 
                'http://192.168.2.227:8080/api/exchange-rate/usdt-btc'
              ),
              _buildQuickUrlButton(
                controller, 
                'Docker Mapped (Port 63980)', 
                'http://192.168.2.227:63980/api/exchange-rate/usdt-btc'
              ),
              _buildQuickUrlButton(
                controller, 
                'Localhost', 
                'http://localhost:8080/api/exchange-rate/usdt-btc'
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newUrl = controller.text.trim();
                if (newUrl.isNotEmpty) {
                  _updateApiUrl(newUrl);
                  _fetchExchangeRate();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('API URL updated to: $newUrl')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickUrlButton(TextEditingController controller, String label, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {
            controller.text = url;
          },
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('USDT/BTC Exchange Rate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
            tooltip: 'API Settings',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchExchangeRate,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_errorMessage != null)
                Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _fetchExchangeRate,
                          child: const Text('Retry'),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: _showSettingsDialog,
                          icon: const Icon(Icons.settings),
                          label: const Text('Settings'),
                        ),
                      ],
                    ),
                  ],
                )
              else if (_exchangeRateData != null)
                Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.currency_bitcoin,
                          size: 64,
                          color: Colors.orange[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _exchangeRateData!.symbol,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'BTC Price: \$${_exchangeRateData!.price}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'USDT to BTC Rate: ${_exchangeRateData!.rate.toStringAsFixed(8)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Last Updated: ${DateTime.parse(_exchangeRateData!.time).toLocal().toString().substring(0, 19)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Current API URL:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _apiUrl,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Auto-refreshes every 30 seconds • Tap Settings to change URL',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
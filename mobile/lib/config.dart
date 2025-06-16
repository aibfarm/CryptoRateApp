class Config {
  static const String apiBaseUrl = 'http://localhost:8080';
  static const String exchangeRateEndpoint = '/api/exchange-rate/usdt-btc';
  
  static String get apiUrl => '$apiBaseUrl$exchangeRateEndpoint';
}

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service for fetching and caching real-time currency exchange rates
/// using Fawazahmed0 Exchange API (https://github.com/fawazahmed0/exchange-api)
class CurrencyService {
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // API URLs (with fallback)
  static const String _primaryUrl =
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1';
  static const String _fallbackUrl = 'https://latest.currency-api.pages.dev/v1';

  // Cache
  Map<String, double>? _cachedRates;
  DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(hours: 1);

  /// Get all exchange rates with USD as base currency
  Future<Map<String, double>> getExchangeRates({
    bool forceRefresh = false,
  }) async {
    // Check memory cache first
    if (!forceRefresh && _cachedRates != null && _cacheTime != null) {
      if (DateTime.now().difference(_cacheTime!) < _cacheDuration) {
        return _cachedRates!;
      }
    }

    // Check Firestore cache
    if (!forceRefresh) {
      final firestoreRates = await _getFirestoreCache();
      if (firestoreRates != null) {
        _cachedRates = firestoreRates;
        _cacheTime = DateTime.now();
        return firestoreRates;
      }
    }

    // Fetch from API
    final rates = await _fetchFromApi();
    if (rates != null) {
      _cachedRates = rates;
      _cacheTime = DateTime.now();
      await _saveToFirestore(rates);
      return rates;
    }

    // Return cached if API fails
    if (_cachedRates != null) {
      return _cachedRates!;
    }

    throw Exception('Failed to fetch exchange rates');
  }

  /// Fetch rates from API with fallback
  Future<Map<String, double>?> _fetchFromApi() async {
    try {
      // Try primary URL first
      var response = await http
          .get(Uri.parse('$_primaryUrl/currencies/usd.json'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        // Try fallback URL
        debugPrint('CurrencyService: Primary failed, trying fallback...');
        response = await http
            .get(Uri.parse('$_fallbackUrl/currencies/usd.json'))
            .timeout(const Duration(seconds: 10));
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final usdRates = data['usd'] as Map<String, dynamic>;

        // Convert to Map<String, double>
        final rates = <String, double>{};
        usdRates.forEach((key, value) {
          if (value is num) {
            rates[key.toUpperCase()] = value.toDouble();
          }
        });

        debugPrint('CurrencyService: Fetched ${rates.length} exchange rates');
        return rates;
      }
    } catch (e) {
      debugPrint('CurrencyService: API fetch failed: $e');
    }
    return null;
  }

  /// Get cached rates from Firestore
  Future<Map<String, double>?> _getFirestoreCache() async {
    try {
      final doc = await _firestore
          .collection('app_config')
          .doc('exchange_rates')
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      final lastUpdated = (data['last_updated'] as Timestamp?)?.toDate();

      // Check if cache is still valid (less than 24 hours old)
      if (lastUpdated != null &&
          DateTime.now().difference(lastUpdated) < const Duration(hours: 24)) {
        final ratesData = data['rates'] as Map<String, dynamic>?;
        if (ratesData != null) {
          final rates = <String, double>{};
          ratesData.forEach((key, value) {
            if (value is num) {
              rates[key] = value.toDouble();
            }
          });
          debugPrint(
            'CurrencyService: Loaded ${rates.length} rates from Firestore cache',
          );
          return rates;
        }
      }
    } catch (e) {
      debugPrint('CurrencyService: Firestore cache read failed: $e');
    }
    return null;
  }

  /// Save rates to Firestore for caching
  Future<void> _saveToFirestore(Map<String, double> rates) async {
    try {
      await _firestore.collection('app_config').doc('exchange_rates').set({
        'base': 'USD',
        'rates': rates,
        'last_updated': FieldValue.serverTimestamp(),
        'source': 'fawazahmed0/exchange-api',
      });
      debugPrint('CurrencyService: Saved rates to Firestore');
    } catch (e) {
      debugPrint('CurrencyService: Firestore save failed: $e');
    }
  }

  /// Convert amount from one currency to another
  Future<double> convert({
    required double amount,
    required String from,
    required String to,
  }) async {
    if (from.toUpperCase() == to.toUpperCase()) {
      return amount;
    }

    final rates = await getExchangeRates();
    final fromRate = rates[from.toUpperCase()];
    final toRate = rates[to.toUpperCase()];

    if (fromRate == null || toRate == null) {
      debugPrint(
        'CurrencyService: Rate not found for $from or $to, returning original',
      );
      return amount;
    }

    // Convert: amount in FROM -> USD -> TO
    // fromRate = how many FROM per 1 USD
    // toRate = how many TO per 1 USD
    final usdAmount = amount / fromRate;
    final result = usdAmount * toRate;

    debugPrint(
      'CurrencyService: $amount $from = $result $to (rates: $from=$fromRate, $to=$toRate)',
    );
    return result;
  }

  /// Convert amount to USD (for storage normalization)
  Future<double> toUSD(double amount, String fromCurrency) async {
    return convert(amount: amount, from: fromCurrency, to: 'USD');
  }

  /// Convert USD amount to target currency
  Future<double> fromUSD(double usdAmount, String toCurrency) async {
    return convert(amount: usdAmount, from: 'USD', to: toCurrency);
  }

  /// Get exchange rate for a specific currency (relative to USD)
  Future<double?> getRate(String currencyCode) async {
    final rates = await getExchangeRates();
    return rates[currencyCode.toUpperCase()];
  }

  /// Get list of all supported currency codes
  Future<List<String>> getSupportedCurrencies() async {
    final rates = await getExchangeRates();
    final codes = rates.keys.toList()..sort();
    return codes;
  }

  /// Check if a currency is supported
  Future<bool> isSupported(String currencyCode) async {
    final rates = await getExchangeRates();
    return rates.containsKey(currencyCode.toUpperCase());
  }

  /// Get last update time from Firestore
  Future<DateTime?> getLastUpdateTime() async {
    try {
      final doc = await _firestore
          .collection('app_config')
          .doc('exchange_rates')
          .get();
      if (doc.exists) {
        return (doc.data()?['last_updated'] as Timestamp?)?.toDate();
      }
    } catch (e) {
      debugPrint('CurrencyService: Failed to get last update time: $e');
    }
    return null;
  }

  /// Force refresh rates from API
  Future<void> refreshRates() async {
    await getExchangeRates(forceRefresh: true);
  }

  /// Get currency symbol from code (simple helper)
  static String getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'IDR':
        return 'Rp';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      default:
        return currencyCode.toUpperCase();
    }
  }
}

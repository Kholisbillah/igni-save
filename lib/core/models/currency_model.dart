/// Currency model with world currencies
class CurrencyModel {
  final String code;
  final String name;
  final String symbol;
  final String flag;

  const CurrencyModel({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
  });

  /// Comprehensive list of world currencies
  static const List<CurrencyModel> currencies = [
    // Major Currencies
    CurrencyModel(
      code: 'IDR',
      name: 'Indonesia Rupiah',
      symbol: 'Rp',
      flag: '🇮🇩',
    ),
    CurrencyModel(code: 'USD', name: 'US Dollar', symbol: '\$', flag: '🇺🇸'),
    CurrencyModel(code: 'EUR', name: 'Euro', symbol: '€', flag: '🇪🇺'),
    CurrencyModel(
      code: 'GBP',
      name: 'British Pound',
      symbol: '£',
      flag: '🇬🇧',
    ),
    CurrencyModel(code: 'JPY', name: 'Japanese Yen', symbol: '¥', flag: '🇯🇵'),
    CurrencyModel(code: 'CNY', name: 'Chinese Yuan', symbol: '¥', flag: '🇨🇳'),
    CurrencyModel(code: 'CHF', name: 'Swiss Franc', symbol: 'Fr', flag: '🇨🇭'),
    CurrencyModel(
      code: 'CAD',
      name: 'Canadian Dollar',
      symbol: 'C\$',
      flag: '🇨🇦',
    ),
    CurrencyModel(
      code: 'AUD',
      name: 'Australian Dollar',
      symbol: 'A\$',
      flag: '🇦🇺',
    ),
    CurrencyModel(
      code: 'NZD',
      name: 'New Zealand Dollar',
      symbol: 'NZ\$',
      flag: '🇳🇿',
    ),

    // Asian Currencies
    CurrencyModel(
      code: 'SGD',
      name: 'Singapore Dollar',
      symbol: 'S\$',
      flag: '🇸🇬',
    ),
    CurrencyModel(
      code: 'MYR',
      name: 'Malaysian Ringgit',
      symbol: 'RM',
      flag: '🇲🇾',
    ),
    CurrencyModel(code: 'THB', name: 'Thai Baht', symbol: '฿', flag: '🇹🇭'),
    CurrencyModel(code: 'KRW', name: 'Korean Won', symbol: '₩', flag: '🇰🇷'),
    CurrencyModel(code: 'INR', name: 'Indian Rupee', symbol: '₹', flag: '🇮🇳'),
    CurrencyModel(
      code: 'PHP',
      name: 'Philippine Peso',
      symbol: '₱',
      flag: '🇵🇭',
    ),
    CurrencyModel(
      code: 'VND',
      name: 'Vietnamese Dong',
      symbol: '₫',
      flag: '🇻🇳',
    ),
    CurrencyModel(
      code: 'TWD',
      name: 'Taiwan Dollar',
      symbol: 'NT\$',
      flag: '🇹🇼',
    ),
    CurrencyModel(
      code: 'HKD',
      name: 'Hong Kong Dollar',
      symbol: 'HK\$',
      flag: '🇭🇰',
    ),
    CurrencyModel(
      code: 'PKR',
      name: 'Pakistani Rupee',
      symbol: '₨',
      flag: '🇵🇰',
    ),
    CurrencyModel(
      code: 'BDT',
      name: 'Bangladeshi Taka',
      symbol: '৳',
      flag: '🇧🇩',
    ),
    CurrencyModel(
      code: 'LKR',
      name: 'Sri Lankan Rupee',
      symbol: 'Rs',
      flag: '🇱🇰',
    ),
    CurrencyModel(
      code: 'NPR',
      name: 'Nepalese Rupee',
      symbol: 'Rs',
      flag: '🇳🇵',
    ),
    CurrencyModel(code: 'MMK', name: 'Myanmar Kyat', symbol: 'K', flag: '🇲🇲'),
    CurrencyModel(
      code: 'KHR',
      name: 'Cambodian Riel',
      symbol: '៛',
      flag: '🇰🇭',
    ),
    CurrencyModel(code: 'LAK', name: 'Lao Kip', symbol: '₭', flag: '🇱🇦'),
    CurrencyModel(
      code: 'BND',
      name: 'Brunei Dollar',
      symbol: 'B\$',
      flag: '🇧🇳',
    ),
    CurrencyModel(
      code: 'MNT',
      name: 'Mongolian Tugrik',
      symbol: '₮',
      flag: '🇲🇳',
    ),

    // Middle East Currencies
    CurrencyModel(code: 'SAR', name: 'Saudi Riyal', symbol: '﷼', flag: '🇸🇦'),
    CurrencyModel(code: 'AED', name: 'UAE Dirham', symbol: 'د.إ', flag: '🇦🇪'),
    CurrencyModel(code: 'QAR', name: 'Qatari Riyal', symbol: '﷼', flag: '🇶🇦'),
    CurrencyModel(
      code: 'KWD',
      name: 'Kuwaiti Dinar',
      symbol: 'د.ك',
      flag: '🇰🇼',
    ),
    CurrencyModel(
      code: 'BHD',
      name: 'Bahraini Dinar',
      symbol: '.د.ب',
      flag: '🇧🇭',
    ),
    CurrencyModel(code: 'OMR', name: 'Omani Rial', symbol: '﷼', flag: '🇴🇲'),
    CurrencyModel(
      code: 'JOD',
      name: 'Jordanian Dinar',
      symbol: 'د.ا',
      flag: '🇯🇴',
    ),
    CurrencyModel(
      code: 'ILS',
      name: 'Israeli Shekel',
      symbol: '₪',
      flag: '🇮🇱',
    ),
    CurrencyModel(code: 'TRY', name: 'Turkish Lira', symbol: '₺', flag: '🇹🇷'),
    CurrencyModel(code: 'IRR', name: 'Iranian Rial', symbol: '﷼', flag: '🇮🇷'),
    CurrencyModel(
      code: 'IQD',
      name: 'Iraqi Dinar',
      symbol: 'ع.د',
      flag: '🇮🇶',
    ),
    CurrencyModel(
      code: 'LBP',
      name: 'Lebanese Pound',
      symbol: 'ل.ل',
      flag: '🇱🇧',
    ),
    CurrencyModel(
      code: 'EGP',
      name: 'Egyptian Pound',
      symbol: 'E£',
      flag: '🇪🇬',
    ),

    // European Currencies (non-Euro)
    CurrencyModel(
      code: 'SEK',
      name: 'Swedish Krona',
      symbol: 'kr',
      flag: '🇸🇪',
    ),
    CurrencyModel(
      code: 'NOK',
      name: 'Norwegian Krone',
      symbol: 'kr',
      flag: '🇳🇴',
    ),
    CurrencyModel(
      code: 'DKK',
      name: 'Danish Krone',
      symbol: 'kr',
      flag: '🇩🇰',
    ),
    CurrencyModel(
      code: 'PLN',
      name: 'Polish Zloty',
      symbol: 'zł',
      flag: '🇵🇱',
    ),
    CurrencyModel(
      code: 'CZK',
      name: 'Czech Koruna',
      symbol: 'Kč',
      flag: '🇨🇿',
    ),
    CurrencyModel(
      code: 'HUF',
      name: 'Hungarian Forint',
      symbol: 'Ft',
      flag: '🇭🇺',
    ),
    CurrencyModel(
      code: 'RON',
      name: 'Romanian Leu',
      symbol: 'lei',
      flag: '🇷🇴',
    ),
    CurrencyModel(
      code: 'BGN',
      name: 'Bulgarian Lev',
      symbol: 'лв',
      flag: '🇧🇬',
    ),
    CurrencyModel(
      code: 'HRK',
      name: 'Croatian Kuna',
      symbol: 'kn',
      flag: '🇭🇷',
    ),
    CurrencyModel(
      code: 'RSD',
      name: 'Serbian Dinar',
      symbol: 'дин.',
      flag: '🇷🇸',
    ),
    CurrencyModel(
      code: 'UAH',
      name: 'Ukrainian Hryvnia',
      symbol: '₴',
      flag: '🇺🇦',
    ),
    CurrencyModel(
      code: 'RUB',
      name: 'Russian Ruble',
      symbol: '₽',
      flag: '🇷🇺',
    ),
    CurrencyModel(
      code: 'ISK',
      name: 'Icelandic Krona',
      symbol: 'kr',
      flag: '🇮🇸',
    ),

    // Americas Currencies
    CurrencyModel(
      code: 'MXN',
      name: 'Mexican Peso',
      symbol: '\$',
      flag: '🇲🇽',
    ),
    CurrencyModel(
      code: 'BRL',
      name: 'Brazilian Real',
      symbol: 'R\$',
      flag: '🇧🇷',
    ),
    CurrencyModel(
      code: 'ARS',
      name: 'Argentine Peso',
      symbol: '\$',
      flag: '🇦🇷',
    ),
    CurrencyModel(
      code: 'CLP',
      name: 'Chilean Peso',
      symbol: '\$',
      flag: '🇨🇱',
    ),
    CurrencyModel(
      code: 'COP',
      name: 'Colombian Peso',
      symbol: '\$',
      flag: '🇨🇴',
    ),
    CurrencyModel(
      code: 'PEN',
      name: 'Peruvian Sol',
      symbol: 'S/',
      flag: '🇵🇪',
    ),
    CurrencyModel(
      code: 'UYU',
      name: 'Uruguayan Peso',
      symbol: '\$U',
      flag: '🇺🇾',
    ),
    CurrencyModel(
      code: 'VES',
      name: 'Venezuelan Bolivar',
      symbol: 'Bs',
      flag: '🇻🇪',
    ),
    CurrencyModel(
      code: 'BOB',
      name: 'Bolivian Boliviano',
      symbol: 'Bs.',
      flag: '🇧🇴',
    ),
    CurrencyModel(
      code: 'PYG',
      name: 'Paraguayan Guarani',
      symbol: '₲',
      flag: '🇵🇾',
    ),
    CurrencyModel(
      code: 'CRC',
      name: 'Costa Rican Colon',
      symbol: '₡',
      flag: '🇨🇷',
    ),
    CurrencyModel(
      code: 'DOP',
      name: 'Dominican Peso',
      symbol: 'RD\$',
      flag: '🇩🇴',
    ),
    CurrencyModel(
      code: 'GTQ',
      name: 'Guatemalan Quetzal',
      symbol: 'Q',
      flag: '🇬🇹',
    ),
    CurrencyModel(
      code: 'HNL',
      name: 'Honduran Lempira',
      symbol: 'L',
      flag: '🇭🇳',
    ),
    CurrencyModel(
      code: 'NIO',
      name: 'Nicaraguan Cordoba',
      symbol: 'C\$',
      flag: '🇳🇮',
    ),
    CurrencyModel(
      code: 'PAB',
      name: 'Panamanian Balboa',
      symbol: 'B/.',
      flag: '🇵🇦',
    ),
    CurrencyModel(
      code: 'JMD',
      name: 'Jamaican Dollar',
      symbol: 'J\$',
      flag: '🇯🇲',
    ),
    CurrencyModel(
      code: 'TTD',
      name: 'Trinidad Dollar',
      symbol: 'TT\$',
      flag: '🇹🇹',
    ),

    // African Currencies
    CurrencyModel(
      code: 'ZAR',
      name: 'South African Rand',
      symbol: 'R',
      flag: '🇿🇦',
    ),
    CurrencyModel(
      code: 'NGN',
      name: 'Nigerian Naira',
      symbol: '₦',
      flag: '🇳🇬',
    ),
    CurrencyModel(
      code: 'KES',
      name: 'Kenyan Shilling',
      symbol: 'KSh',
      flag: '🇰🇪',
    ),
    CurrencyModel(
      code: 'GHS',
      name: 'Ghanaian Cedi',
      symbol: '₵',
      flag: '🇬🇭',
    ),
    CurrencyModel(
      code: 'TZS',
      name: 'Tanzanian Shilling',
      symbol: 'TSh',
      flag: '🇹🇿',
    ),
    CurrencyModel(
      code: 'UGX',
      name: 'Ugandan Shilling',
      symbol: 'USh',
      flag: '🇺🇬',
    ),
    CurrencyModel(
      code: 'MAD',
      name: 'Moroccan Dirham',
      symbol: 'د.م.',
      flag: '🇲🇦',
    ),
    CurrencyModel(
      code: 'DZD',
      name: 'Algerian Dinar',
      symbol: 'دج',
      flag: '🇩🇿',
    ),
    CurrencyModel(
      code: 'TND',
      name: 'Tunisian Dinar',
      symbol: 'د.ت',
      flag: '🇹🇳',
    ),
    CurrencyModel(
      code: 'XAF',
      name: 'CFA Franc BEAC',
      symbol: 'FCFA',
      flag: '🇨🇲',
    ),
    CurrencyModel(
      code: 'XOF',
      name: 'CFA Franc BCEAO',
      symbol: 'CFA',
      flag: '🇸🇳',
    ),
    CurrencyModel(
      code: 'ETB',
      name: 'Ethiopian Birr',
      symbol: 'Br',
      flag: '🇪🇹',
    ),
    CurrencyModel(
      code: 'RWF',
      name: 'Rwandan Franc',
      symbol: 'FRw',
      flag: '🇷🇼',
    ),
    CurrencyModel(
      code: 'ZMW',
      name: 'Zambian Kwacha',
      symbol: 'ZK',
      flag: '🇿🇲',
    ),
    CurrencyModel(
      code: 'BWP',
      name: 'Botswana Pula',
      symbol: 'P',
      flag: '🇧🇼',
    ),
    CurrencyModel(
      code: 'MUR',
      name: 'Mauritian Rupee',
      symbol: '₨',
      flag: '🇲🇺',
    ),

    // Oceania Currencies
    CurrencyModel(
      code: 'FJD',
      name: 'Fijian Dollar',
      symbol: 'FJ\$',
      flag: '🇫🇯',
    ),
    CurrencyModel(
      code: 'PGK',
      name: 'Papua New Guinean Kina',
      symbol: 'K',
      flag: '🇵🇬',
    ),
    CurrencyModel(
      code: 'WST',
      name: 'Samoan Tala',
      symbol: 'WS\$',
      flag: '🇼🇸',
    ),
    CurrencyModel(
      code: 'TOP',
      name: 'Tongan Paʻanga',
      symbol: 'T\$',
      flag: '🇹🇴',
    ),
    CurrencyModel(
      code: 'VUV',
      name: 'Vanuatu Vatu',
      symbol: 'VT',
      flag: '🇻🇺',
    ),

    // Others
    CurrencyModel(
      code: 'XAU',
      name: 'Gold (Troy Ounce)',
      symbol: 'XAU',
      flag: '🥇',
    ),
    CurrencyModel(
      code: 'XAG',
      name: 'Silver (Troy Ounce)',
      symbol: 'XAG',
      flag: '🥈',
    ),
    CurrencyModel(code: 'BTC', name: 'Bitcoin', symbol: '₿', flag: '🪙'),
    CurrencyModel(code: 'ETH', name: 'Ethereum', symbol: 'Ξ', flag: '💎'),
  ];

  /// Get currency by code
  static CurrencyModel getByCode(String code) {
    return currencies.firstWhere(
      (c) => c.code == code,
      orElse: () => currencies.first, // Default to IDR
    );
  }

  /// Display string for dropdown
  String get displayName => '$flag  $name ( $symbol )';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyModel &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

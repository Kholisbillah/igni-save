import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme_colors.dart';
import '../../../../core/models/currency_model.dart';
import '../../../../services/currency_service.dart';

/// Shows a bottom sheet modal for selecting currency with search
/// Now fetches available currencies from the exchange rate API
Future<CurrencyModel?> showCurrencyPicker(
  BuildContext context, {
  CurrencyModel? selected,
}) async {
  return showModalBottomSheet<CurrencyModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CurrencyPickerModal(selected: selected),
  );
}

class CurrencyPickerModal extends StatefulWidget {
  final CurrencyModel? selected;

  const CurrencyPickerModal({super.key, this.selected});

  @override
  State<CurrencyPickerModal> createState() => _CurrencyPickerModalState();
}

class _CurrencyPickerModalState extends State<CurrencyPickerModal> {
  final _searchController = TextEditingController();
  final _currencyService = CurrencyService();

  List<CurrencyModel> _allCurrencies = [];
  List<CurrencyModel> _filteredCurrencies = [];
  String _searchQuery = '';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrencies() async {
    try {
      // Get supported currencies from API
      final supportedCodes = await _currencyService.getSupportedCurrencies();

      // Filter our currency model list to only include supported currencies
      final supported = CurrencyModel.currencies
          .where((c) => supportedCodes.contains(c.code.toUpperCase()))
          .toList();

      // Sort by popular currencies first
      final popularCodes = ['IDR', 'USD', 'EUR', 'GBP', 'JPY', 'SGD', 'MYR'];
      supported.sort((a, b) {
        final aPopular = popularCodes.indexOf(a.code);
        final bPopular = popularCodes.indexOf(b.code);
        if (aPopular != -1 && bPopular != -1) {
          return aPopular.compareTo(bPopular);
        } else if (aPopular != -1) {
          return -1;
        } else if (bPopular != -1) {
          return 1;
        }
        return a.name.compareTo(b.name);
      });

      setState(() {
        _allCurrencies = supported;
        _filteredCurrencies = supported;
        _isLoading = false;
      });
    } catch (e) {
      // Fallback to static list if API fails
      setState(() {
        _allCurrencies = CurrencyModel.currencies;
        _filteredCurrencies = CurrencyModel.currencies;
        _isLoading = false;
        _error = 'Could not load live rates. Showing all currencies.';
      });
    }
  }

  void _filterCurrencies(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredCurrencies = _allCurrencies;
      } else {
        _filteredCurrencies = _allCurrencies.where((currency) {
          return currency.code.toLowerCase().contains(_searchQuery) ||
              currency.name.toLowerCase().contains(_searchQuery) ||
              currency.symbol.toLowerCase().contains(_searchQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppThemeColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppThemeColors.textTertiary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Currency',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppThemeColors.textPrimary,
                      ),
                    ),
                    if (_allCurrencies.isNotEmpty)
                      Text(
                        '${_allCurrencies.length} currencies with live rates',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppThemeColors.textTertiary,
                        ),
                      ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: AppThemeColors.textSecondary,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Error message if any
          if (_error != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppThemeColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppThemeColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppThemeColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCurrencies,
              style: const TextStyle(color: AppThemeColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search currency...',
                hintStyle: TextStyle(color: AppThemeColors.textTertiary),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppThemeColors.textTertiary,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _filterCurrencies('');
                        },
                        icon: const Icon(
                          Icons.clear,
                          color: AppThemeColors.textTertiary,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: AppThemeColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Currency List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppThemeColors.primary,
                    ),
                  )
                : _filteredCurrencies.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: AppThemeColors.textTertiary.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No currency found',
                          style: TextStyle(color: AppThemeColors.textTertiary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(bottom: bottomPadding + 16),
                    itemCount: _filteredCurrencies.length,
                    itemBuilder: (context, index) {
                      final currency = _filteredCurrencies[index];
                      final isSelected = widget.selected?.code == currency.code;

                      return ListTile(
                        onTap: () => Navigator.pop(context, currency),
                        leading: Text(
                          currency.flag,
                          style: const TextStyle(fontSize: 28),
                        ),
                        title: Text(
                          currency.name,
                          style: TextStyle(
                            color: AppThemeColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          '${currency.code} • ${currency.symbol}',
                          style: const TextStyle(
                            color: AppThemeColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: AppThemeColors.primary,
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

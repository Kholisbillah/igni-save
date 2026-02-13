import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/user_profile_provider.dart';
import '../../../services/currency_service.dart';

import '../data/models/mission_model.dart';
import '../data/repositories/mission_repository.dart';

// Repository Provider
final missionRepositoryProvider = Provider<MissionRepository>((ref) {
  return MissionRepository();
});

// Stream of active missions for the current user
final activeMissionsStreamProvider =
    StreamProvider.autoDispose<List<MissionModel>>((ref) {
      final user = ref.watch(currentUserProvider);
      if (user == null) return const Stream.empty();

      final repository = ref.watch(missionRepositoryProvider);
      return repository.getUserActiveMissions(user.uid);
    });

// Stream of all missions for the current user
final userMissionsStreamProvider =
    StreamProvider.autoDispose<List<MissionModel>>((ref) {
      final user = ref.watch(currentUserProvider);
      if (user == null) return const Stream.empty();

      final repository = ref.watch(missionRepositoryProvider);
      return repository.getAllUserMissions(user.uid);
    });

/// Provider for total savings converted to user's preferred currency
/// This properly converts each goal's currentAmount to the preferred currency before summing
final convertedTotalSavingsProvider = FutureProvider.autoDispose<double>((
  ref,
) async {
  final profile = ref.watch(currentUserProfileProvider);
  final missionsAsync = ref.watch(userMissionsStreamProvider);

  if (profile == null) return 0.0;

  final targetCurrency = profile.preferredCurrency;
  final missions = missionsAsync.valueOrNull ?? [];

  if (missions.isEmpty) {
    // Fallback to profile's totalSavings if no missions
    return profile.totalSavings;
  }

  double totalConverted = 0.0;
  final currencyService = CurrencyService();

  for (final mission in missions) {
    if (mission.currentAmount <= 0) continue;

    if (mission.currency == targetCurrency) {
      // Same currency, no conversion needed
      totalConverted += mission.currentAmount;
    } else {
      // Convert to target currency
      try {
        final converted = await currencyService.convert(
          amount: mission.currentAmount,
          from: mission.currency,
          to: targetCurrency,
        );
        totalConverted += converted;
      } catch (e) {
        // On error, just add original amount (best effort)
        totalConverted += mission.currentAmount;
      }
    }
  }

  return totalConverted;
});

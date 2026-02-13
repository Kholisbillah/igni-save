import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/mission_model.dart';

/// Sort options for goals list
enum GoalSortOption {
  newest,
  oldest,
  progressHighToLow,
  progressLowToHigh,
  amountHighToLow,
  amountLowToHigh,
  deadlineNearest,
  deadlineFarthest,
  alphabeticalAZ,
  alphabeticalZA,
}

/// Filter state for goals
class GoalsFilterState {
  final String searchQuery;
  final GoalSortOption sortOption;
  final Set<String> selectedColors;

  const GoalsFilterState({
    this.searchQuery = '',
    this.sortOption = GoalSortOption.newest,
    this.selectedColors = const {},
  });

  GoalsFilterState copyWith({
    String? searchQuery,
    GoalSortOption? sortOption,
    Set<String>? selectedColors,
  }) {
    return GoalsFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      selectedColors: selectedColors ?? this.selectedColors,
    );
  }

  /// Check if any filters are active
  bool get hasActiveFilters =>
      searchQuery.isNotEmpty || selectedColors.isNotEmpty;

  /// Apply filters and sorting to missions list
  List<MissionModel> apply(List<MissionModel> missions) {
    var filtered = missions.toList();

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((m) {
        return m.title.toLowerCase().contains(query) ||
            m.description.toLowerCase().contains(query);
      }).toList();
    }

    // Filter by color
    if (selectedColors.isNotEmpty) {
      filtered = filtered.where((m) {
        return selectedColors.contains(m.colorTheme);
      }).toList();
    }

    // Apply sorting
    switch (sortOption) {
      case GoalSortOption.newest:
        filtered.sort((a, b) {
          final aDate = a.createdAt ?? DateTime(2000);
          final bDate = b.createdAt ?? DateTime(2000);
          return bDate.compareTo(aDate);
        });
        break;
      case GoalSortOption.oldest:
        filtered.sort((a, b) {
          final aDate = a.createdAt ?? DateTime(2000);
          final bDate = b.createdAt ?? DateTime(2000);
          return aDate.compareTo(bDate);
        });
        break;
      case GoalSortOption.progressHighToLow:
        filtered.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      case GoalSortOption.progressLowToHigh:
        filtered.sort((a, b) => a.progress.compareTo(b.progress));
        break;
      case GoalSortOption.amountHighToLow:
        filtered.sort((a, b) => b.targetAmount.compareTo(a.targetAmount));
        break;
      case GoalSortOption.amountLowToHigh:
        filtered.sort((a, b) => a.targetAmount.compareTo(b.targetAmount));
        break;
      case GoalSortOption.deadlineNearest:
        filtered.sort((a, b) => a.deadline.compareTo(b.deadline));
        break;
      case GoalSortOption.deadlineFarthest:
        filtered.sort((a, b) => b.deadline.compareTo(a.deadline));
        break;
      case GoalSortOption.alphabeticalAZ:
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case GoalSortOption.alphabeticalZA:
        filtered.sort((a, b) => b.title.compareTo(a.title));
        break;
    }

    return filtered;
  }
}

/// Provider for goals filter state
class GoalsFilterNotifier extends StateNotifier<GoalsFilterState> {
  GoalsFilterNotifier() : super(const GoalsFilterState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSortOption(GoalSortOption option) {
    state = state.copyWith(sortOption: option);
  }

  void toggleColor(String color) {
    final colors = Set<String>.from(state.selectedColors);
    if (colors.contains(color)) {
      colors.remove(color);
    } else {
      colors.add(color);
    }
    state = state.copyWith(selectedColors: colors);
  }

  void clearColorFilters() {
    state = state.copyWith(selectedColors: {});
  }

  void clearAllFilters() {
    state = const GoalsFilterState();
  }
}

final goalsFilterProvider =
    StateNotifierProvider<GoalsFilterNotifier, GoalsFilterState>((ref) {
      return GoalsFilterNotifier();
    });

/// Get display name for sort option
String getSortOptionDisplayName(GoalSortOption option) {
  switch (option) {
    case GoalSortOption.newest:
      return 'Newest First';
    case GoalSortOption.oldest:
      return 'Oldest First';
    case GoalSortOption.progressHighToLow:
      return 'Progress: High to Low';
    case GoalSortOption.progressLowToHigh:
      return 'Progress: Low to High';
    case GoalSortOption.amountHighToLow:
      return 'Amount: High to Low';
    case GoalSortOption.amountLowToHigh:
      return 'Amount: Low to High';
    case GoalSortOption.deadlineNearest:
      return 'Deadline: Nearest';
    case GoalSortOption.deadlineFarthest:
      return 'Deadline: Farthest';
    case GoalSortOption.alphabeticalAZ:
      return 'A to Z';
    case GoalSortOption.alphabeticalZA:
      return 'Z to A';
  }
}

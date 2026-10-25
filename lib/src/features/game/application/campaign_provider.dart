import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Configuration chosen before a new career starts.
class CampaignDefinition {
  const CampaignDefinition({
    required this.id,
    required this.leagueName,
    required this.franchiseName,
    required this.difficulty,
    required this.initialPurseCr,
  });

  final String id;
  final String leagueName;
  final String franchiseName;
  final String difficulty;
  final double initialPurseCr;

  Map<String, dynamic> toJson() => {
        'id': id,
        'leagueName': leagueName,
        'franchiseName': franchiseName,
        'difficulty': difficulty,
        'initialPurseCr': initialPurseCr,
      };

  factory CampaignDefinition.fromJson(Map<String, dynamic> json) =>
      CampaignDefinition(
        id: json['id'] as String,
        leagueName: json['leagueName'] as String? ?? 'Premier League',
        franchiseName: json['franchiseName'] as String? ?? 'My Franchise',
        difficulty: json['difficulty'] as String? ?? 'Normal',
        initialPurseCr: (json['initialPurseCr'] as num?)?.toDouble() ?? 120,
      );
}

final campaignProvider = StateProvider<CampaignDefinition?>((ref) => null);

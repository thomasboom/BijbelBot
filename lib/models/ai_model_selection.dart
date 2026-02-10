import '../l10n/app_localizations.dart';

/// AI model cost tier for Ollama models
enum AiModelCost {
  low,
  medium,
  high,
}

/// Represents an Ollama AI model with its configuration
class AiModel {
  final String id;
  final String name;
  final AiModelCost cost;
  final String description;

  const AiModel({
    required this.id,
    required this.name,
    required this.cost,
    required this.description,
  });

  /// Returns the display label for this model
  String getLabel(AppLocalizations localizations) {
    switch (cost) {
      case AiModelCost.low:
        return '${localizations.lowCostModel} - $name';
      case AiModelCost.medium:
        return '${localizations.mediumCostModel} - $name';
      case AiModelCost.high:
        return '${localizations.highCostModel} - $name';
    }
  }

  /// Returns the cost label for this model
  String getCostLabel(AppLocalizations localizations) {
    switch (cost) {
      case AiModelCost.low:
        return localizations.lowCostModel;
      case AiModelCost.medium:
        return localizations.mediumCostModel;
      case AiModelCost.high:
        return localizations.highCostModel;
    }
  }
}

/// Available Ollama models for the BijbelBot app
class AiModels {
  /// Low cost model - smaller, faster, less expensive
  static const AiModel lowCost = AiModel(
    id: 'ministral-3:14b-cloud',
    name: 'Ministral-3 14B',
    cost: AiModelCost.low,
    description: 'Fast and efficient model for quick responses',
  );

  /// Medium cost model - balanced performance and cost
  static const AiModel mediumCost = AiModel(
    id: 'deepseek-v3.1:671b-cloud',
    name: 'DeepSeek V3.1 671B',
    cost: AiModelCost.medium,
    description: 'Balanced model for good quality responses',
  );

  /// High cost model - best quality, more expensive
  static const AiModel highCost = AiModel(
    id: 'kimi-k2.5:cloud',
    name: 'Kimi K2.5',
    cost: AiModelCost.high,
    description: 'High quality model for detailed responses',
  );

  /// All available models
  static const List<AiModel> allModels = [
    lowCost,
    mediumCost,
    highCost,
  ];

  /// Get model by ID
  static AiModel? getModelById(String id) {
    for (final model in allModels) {
      if (model.id == id) {
        return model;
      }
    }
    return null;
  }

  /// Get model by cost tier
  static AiModel getModelByCost(AiModelCost cost) {
    for (final model in allModels) {
      if (model.cost == cost) {
        return model;
      }
    }
    return mediumCost; // Default to medium cost
  }

  /// Parse cost tier from string
  static AiModelCost parseCost(String? value) {
    switch (value) {
      case 'low':
        return AiModelCost.low;
      case 'medium':
        return AiModelCost.medium;
      case 'high':
        return AiModelCost.high;
      default:
        return AiModelCost.medium; // Default to medium cost
    }
  }
}

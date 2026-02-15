import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/context_mapping.dart';

class ContextService {
  List<ContextMapping> _mappings = [];

  Future<void> init() async {
    final jsonStr =
        await rootBundle.loadString('assets/data/context_mappings.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final list = data['mappings'] as List;
    _mappings = list
        .map((m) => ContextMapping.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  List<String> getSuggestions(List<String> detectedObjects) {
    final suggestions = <String>{};
    for (final mapping in _mappings) {
      for (final obj in detectedObjects) {
        final lower = obj.toLowerCase();
        if (mapping.objects.any((o) => lower.contains(o))) {
          suggestions.addAll(mapping.suggestions);
        }
      }
    }
    return suggestions.toList();
  }
}

class ContextMapping {
  final List<String> objects;
  final List<String> suggestions;

  const ContextMapping({
    required this.objects,
    required this.suggestions,
  });

  factory ContextMapping.fromJson(Map<String, dynamic> json) {
    return ContextMapping(
      objects: List<String>.from(json['objects'] as List),
      suggestions: List<String>.from(json['suggestions'] as List),
    );
  }
}

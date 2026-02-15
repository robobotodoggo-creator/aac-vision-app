class AacSymbol {
  final String id;
  final String label;
  final String speakText;
  final String category;
  final String emoji;

  const AacSymbol({
    required this.id,
    required this.label,
    required this.speakText,
    required this.category,
    required this.emoji,
  });

  factory AacSymbol.fromJson(Map<String, dynamic> json) {
    return AacSymbol(
      id: json['id'] as String,
      label: json['label'] as String,
      speakText: json['speakText'] as String,
      category: json['category'] as String,
      emoji: json['emoji'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'speakText': speakText,
        'category': category,
        'emoji': emoji,
      };
}

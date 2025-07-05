class BibleVerse {
  final String reference;
  final String text;
  final String translation;

  BibleVerse({
    required this.reference,
    required this.text,
    required this.translation,
  });

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      reference: json['reference'],
      text: json['verses'][0]['text'],
      translation: json['translation_name'],
    );
  }
}

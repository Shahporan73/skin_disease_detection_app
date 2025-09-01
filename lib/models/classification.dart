class Classification {
  final String label;
  final double confidence;

  Classification({required this.label, required this.confidence});

  @override
  String toString() {
    return 'Classification{label: $label, confidence: $confidence}';
  }
}

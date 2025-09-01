import 'package:flutter/material.dart';
import '../models/classification.dart';

class ResultWidget extends StatelessWidget {
  final List<Classification> classifications;

  const ResultWidget({super.key, required this.classifications});

  Color _getConfidenceColor(double confidence) {
    if (confidence > 0.8) return Colors.green;
    if (confidence > 0.6) return Colors.orange;
    return Colors.red;
  }

  IconData _getConfidenceIcon(double confidence) {
    if (confidence > 0.8) return Icons.check_circle;
    if (confidence > 0.6) return Icons.warning;
    return Icons.error;
  }

  String _getConfidenceText(double confidence) {
    if (confidence > 0.8) return 'উচ্চ নির্ভরযোগ্যতা';
    if (confidence > 0.6) return 'মধ্যম নির্ভরযোগ্যতা';
    return 'কম নির্ভরযোগ্যতা';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Result Card
        if (classifications.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getConfidenceColor(classifications.first.confidence).withOpacity(0.1),
                  _getConfidenceColor(classifications.first.confidence).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getConfidenceColor(classifications.first.confidence),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getConfidenceIcon(classifications.first.confidence),
                      color: _getConfidenceColor(classifications.first.confidence),
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'প্রধান শনাক্তকরণ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  classifications.first.label,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'নির্ভরযোগ্যতা: ${(classifications.first.confidence * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      _getConfidenceText(classifications.first.confidence),
                      style: TextStyle(
                        fontSize: 14,
                        color: _getConfidenceColor(classifications.first.confidence),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        // Other Results
        if (classifications.length > 1) ...[
          const Text(
            'অন্যান্য সম্ভাবনা:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...classifications.skip(1).map((result) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getConfidenceColor(result.confidence).withOpacity(0.2),
                child: Icon(
                  _getConfidenceIcon(result.confidence),
                  color: _getConfidenceColor(result.confidence),
                  size: 20,
                ),
              ),
              title: Text(
                result.label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                'নির্ভরযোগ্যতা: ${(result.confidence * 100).toStringAsFixed(1)}%',
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(result.confidence).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(result.confidence * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: _getConfidenceColor(result.confidence),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )).toList(),
        ],

        // Disclaimer
        if (classifications.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'দ্রষ্টব্য: এটি একটি প্রাথমিক শনাক্তকরণ। চূড়ান্ত নির্ণয়ের জন্য অবশ্যই চিকিৎসকের পরামর্শ নিন।',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
// import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/classification.dart';

class MLService {
  // Interpreter? _interpreter;
  List<String>? _labels;
  bool _isModelLoaded = false;



  Future<void> _loadModel() async {
    if (_isModelLoaded) return;

    try {
      // মডেল লোড করা
      // _interpreter = await Interpreter.fromAsset('assets/model.tflite');

      // লেবেল ফাইল লোড করা
      final labelsData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsData.split('\n')
          .map((line) => line.trim())
          .where((label) => label.isNotEmpty)
          .toList();

      _isModelLoaded = true;
      print('Model loaded successfully with ${_labels!.length} labels');
    } catch (e) {
      print('Error loading model: $e');
      throw Exception('মডেল লোড করতে ব্যর্থ: $e');
    }
  }

/*  Future<List<Classification>> classify(File imageFile) async {
    try {
      if (!_isModelLoaded) {
        await _loadModel();
      }

      if (_interpreter == null || _labels == null) {
        throw Exception('মডেল এখনও লোড হয়নি');
      }

      // ইমেজ প্রি-প্রসেসিং
      final inputData = await _preprocessImage(imageFile);

      // Input tensor: [1, 224, 224, 3]
      final input = [inputData];

      // Output tensor setup
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final outputData = List.filled(outputShape[1], 0.0);
      final output = [outputData];

      // ইনফারেন্স চালানো
      _interpreter!.run(input, output);

      // রেজাল্ট প্রসেসিং
      final results = <Classification>[];
      final probabilities = output[0];

      for (int i = 0; i < probabilities.length && i < _labels!.length; i++) {
        results.add(Classification(
          label: _labels![i],
          confidence: probabilities[i],
        ));
      }

      // কনফিডেন্স অনুযায়ী সর্ট করা
      results.sort((a, b) => b.confidence.compareTo(a.confidence));

      // টপ ৩টি রেজাল্ট রিটার্ন করা
      return results.take(3).toList();

    } catch (e) {
      print('Classification error: $e');
      throw Exception('ইমেজ ক্লাসিফাই করতে ব্যর্থ: $e');
    }
  }*/

  Future<List<Classification>> classify(File imageFile) async {
    // Dummy results for testing
    await Future.delayed(Duration(seconds: 2)); // Simulate processing time

    final diseases = [
      'Acne (ব্রণ)',
      'Eczema (একজিমা)',
      'Psoriasis (সোরিয়াসিস)',
      'Normal Skin (স্বাভাবিক ত্বক)',
      'Melanoma (মেলানোমা)',
    ];

    final random = Random();
    final results = diseases.map((disease) =>
        Classification(
          label: disease,
          confidence: random.nextDouble(),
        )
    ).toList();

    results.sort((a, b) => b.confidence.compareTo(a.confidence));
    return results.take(3).toList();
  }

  Future<List<List<List<double>>>> _preprocessImage(File imageFile) async {
    try {
      // ইমেজ পড়া
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('ইমেজ ডিকোড করতে ব্যর্থ');
      }

      // ইমেজ রিসাইজ করা (224x224)
      img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

      // 3D List তৈরি করা [224, 224, 3]
      final imageMatrix = List.generate(224, (y) =>
          List.generate(224, (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [
              img.getRed(pixel) / 255.0,   // Red channel
              img.getGreen(pixel) / 255.0, // Green channel
              img.getBlue(pixel) / 255.0,  // Blue channel
            ];
          }));

      return imageMatrix;
    } catch (e) {
      throw Exception('ইমেজ প্রি-প্রসেসিং এ ত্রুটি: $e');
    }
  }

  void dispose() {
    // _interpreter?.close();
    _isModelLoaded = false;
  }
}
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/classification.dart';

class MLService {
  Interpreter? _interpreter;
  List<String>? _labels;
  bool _isModelLoaded = false;

  MLService() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    if (_isModelLoaded) {
      print('মডেল ইতিমধ্যে লোড করা হয়েছে');
      return;
    }

    try {
      print('মডেল লোড শুরু হচ্ছে...');
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      final labelsData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsData
          .split('\n')
          .map((line) => line.trim())
          .where((label) => label.isNotEmpty)
          .toList();

      // ডিবাগিং: লোড করা লেবেলগুলো প্রিন্ট করুন
      print('লোড করা লেবেল: $_labels');

      if (_interpreter == null) {
        throw Exception('ইন্টারপ্রেটার লোড করা যায়নি');
      }

      print('ইনপুট টেনসর শেপ: ${_interpreter!.getInputTensor(0).shape}');
      print('আউটপুট টেনসর শেপ: ${_interpreter!.getOutputTensor(0).shape}');
      print('লোড করা লেবেল সংখ্যা: ${_labels!.length}');

      _isModelLoaded = true;
    } catch (e) {
      _isModelLoaded = false;
      print('মডেল লোড করতে ত্রুটি: $e');
      throw Exception('মডেল লোড করতে ব্যর্থ: $e');
    }
  }

  Future<List<Classification>> classify(File imageFile) async {
    try {
      print('ইমেজ শ্রেণীবিভাগ শুরু হচ্ছে...');
      if (!_isModelLoaded || _interpreter == null || _labels == null) {
        print('মডেল লোড হয়নি, পুনরায় লোড করা হচ্ছে...');
        await _loadModel();
      }

      if (_interpreter == null || _labels == null) {
        throw Exception('মডেল বা লেবেল লোড করা যায়নি');
      }

      final inputData = await _preprocessImage(imageFile);
      print('ইনপুট ডেটা তৈরি হয়েছে: ${inputData.length}');

      final outputShape = _interpreter!.getOutputTensor(0).shape;
      print('আউটপুট শেপ: $outputShape');
      final output = List.generate(1, (_) => List<double>.filled(outputShape[1], 0.0));

      _interpreter!.run(inputData, output);
      print('ইনফারেন্স সম্পন্ন হয়েছে');

      final probabilities = output[0];
      print('প্রোবাবিলিটি: $probabilities');

      if (probabilities.isEmpty) {
        throw Exception('মডেল থেকে কোনো প্রোবাবিলিটি পাওয়া যায়নি');
      }

      final results = <Classification>[];
      for (int i = 0; i < probabilities.length && i < _labels!.length; i++) {
        // লেবেলকে lowercase-এ কনভার্ট করুন
        final label = _labels![i].toLowerCase().trim();
        results.add(Classification(
          label: label,
          confidence: probabilities[i].clamp(0.0, 1.0),
        ));
      }

      if (results.isEmpty) {
        throw Exception('কোনো শ্রেণীবিভাগ ফলাফল তৈরি হয়নি');
      }

      results.sort((a, b) => b.confidence.compareTo(a.confidence));
      print('শ্রেণীবিভাগ ফলাফল: $results');
      return results.take(3).toList();
    } catch (e) {
      print('শ্রেণীবিভাগে ত্রুটি: $e');
      throw Exception('ইমেজ শ্রেণীবিভাগে ব্যর্থ: $e');
    }
  }

  Future<List<List<List<List<double>>>>> _preprocessImage(File imageFile) async {
    try {
      print('ইমেজ প্রিপ্রসেসিং শুরু হচ্ছে...');
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('ইমেজ ডিকোড করা যায়নি');
      }

      print('ইমেজ ডিকোড করা হয়েছে: ${image.width}x${image.height}');

      // রিসাইজ এবং নরমালাইজ
      img.Image resizedImage = img.copyResize(image, width: 224, height: 224);
      print('ইমেজ রিসাইজ করা হয়েছে: 224x224');

      // নরমালাইজ পিক্সেল মান [-1, 1]
      final imageMatrix = List.generate(224, (y) => List.generate(224, (x) {
        final pixel = resizedImage.getPixel(x, y);
        return [
          (img.getRed(pixel) / 127.5) - 1.0,
          (img.getGreen(pixel) / 127.5) - 1.0,
          (img.getBlue(pixel) / 127.5) - 1.0,
        ];
      }));

      print('ইমেজ ম্যাট্রিক্স তৈরি হয়েছে');
      return [imageMatrix];
    } catch (e) {
      print('ইমেজ প্রিপ্রসেসিং ত্রুটি: $e');
      throw Exception('ইমেজ প্রিপ্রসেসিং ব্যর্থ: $e');
    }
  }

  void dispose() {
    print('মডেল ডিসপোজ করা হচ্ছে...');
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
    _isModelLoaded = false;
  }
}
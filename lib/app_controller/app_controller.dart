import 'dart:io';
import 'package:get/get.dart';
import '../models/classification.dart';
import '../services/ml_service.dart';

class AppController extends GetxController {
  final MLService _mlService = MLService();
  final _selectedImage = Rxn<File>();
  final _classifications = <Classification>[].obs;
  final _isLoading = false.obs;
  final _error = ''.obs;

  // Getters
  File? get selectedImage => _selectedImage.value;
  List<Classification> get classifications => _classifications;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  Future<void> classifyImage() async {
    if (_selectedImage.value == null) {
      _error.value = 'কোনো ছবি নির্বাচন করা হয়নি';
      return;
    }

    _isLoading.value = true;
    _error.value = '';

    try {
      _classifications.value = await _mlService.classify(_selectedImage.value!);
      if (_classifications.isEmpty) {
        _error.value = 'মডেল থেকে কোনো ফলাফল পাওয়া যায়নি';
      }
    } catch (e) {
      _error.value = 'শ্রেণীবিভাগ ব্যর্থ: $e';
      _classifications.clear();
    }

    _isLoading.value = false;
  }

  void setImage(File image) {
    _selectedImage.value = image;
    _classifications.clear();
    _error.value = '';
  }

  void clearAll() {
    _selectedImage.value = null;
    _classifications.clear();
    _error.value = '';
  }

  @override
  void onClose() {
    _mlService.dispose();
    super.onClose();
  }
}
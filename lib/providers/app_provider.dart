import 'dart:io';
import 'package:flutter/material.dart';
import '../models/classification.dart';
import '../services/ml_service.dart';

class AppProvider extends ChangeNotifier {
  File? _selectedImage;
  List<Classification> _classifications = [];
  bool _isLoading = false;
  String _error = '';

  final MLService _mlService = MLService();

  // Getters
  File? get selectedImage => _selectedImage;
  List<Classification> get classifications => _classifications;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> classifyImage() async {
    if (_selectedImage == null) return;

    _setLoading(true);
    _clearError();

    try {
      _classifications = await _mlService.classify(_selectedImage!);
    } catch (e) {
      _setError(e.toString());
      _classifications = [];
    }

    _setLoading(false);
  }

  void setImage(File image) {
    _selectedImage = image;
    _classifications = [];
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  void _clearError() {
    _error = '';
    notifyListeners();
  }

  void clearAll() {
    _selectedImage = null;
    _classifications = [];
    _clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    _mlService.dispose();
    super.dispose();
  }
}
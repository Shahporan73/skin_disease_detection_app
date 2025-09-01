import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/result_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      // Check permissions
      bool hasPermission = await _requestPermissions(source);
      if (!hasPermission) {
        _showPermissionDialog(context, source);
        return;
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        Provider.of<AppProvider>(context, listen: false).setImage(File(pickedFile.path));
      } else {
        _showErrorDialog(context, 'কোনো ইমেজ নির্বাচন করা হয়নি।');
      }
    } catch (e) {
      _showErrorDialog(context, 'ইমেজ নির্বাচন করতে ব্যর্থ: $e');
    }
  }

  Future<bool> _requestPermissions(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      return status.isGranted;
    } else {
      if (Platform.isAndroid) {
        // For Android 13+ (API 33+), use Permission.photos
        if (await Permission.photos.isDenied || await Permission.photos.isPermanentlyDenied) {
          final status = await Permission.photos.request();
          return status.isGranted;
        }
        // For older Android versions, fallback to storage
        if (await Permission.storage.isDenied || await Permission.storage.isPermanentlyDenied) {
          final status = await Permission.storage.request();
          return status.isGranted;
        }
        return true;
      } else {
        // iOS
        final status = await Permission.photos.request();
        return status.isGranted;
      }
    }
  }

  void _showPermissionDialog(BuildContext context, ImageSource source) async {
    final isPermanentlyDenied = source == ImageSource.camera
        ? await Permission.camera.isPermanentlyDenied
        : (Platform.isAndroid
        ? await Permission.photos.isPermanentlyDenied || await Permission.storage.isPermanentlyDenied
        : await Permission.photos.isPermanentlyDenied);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('অনুমতি প্রয়োজন'),
        content: Text(
          isPermanentlyDenied
              ? 'আপনি এই ফিচারের জন্য অনুমতি প্রত্যাখ্যান করেছেন। দয়া করে সেটিংস থেকে ${source == ImageSource.camera ? "ক্যামেরা" : "গ্যালারি"} অনুমতি দিন।'
              : 'এই ফিচার ব্যবহার করতে ${source == ImageSource.camera ? "ক্যামেরা" : "গ্যালারি"} অনুমতি দিন।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ঠিক আছে'),
          ),
          if (isPermanentlyDenied)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('সেটিংস'),
            ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ত্রুটি'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ঠিক আছে'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ত্বকের রোগ শনাক্তকারী',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.medical_services, size: 48, color: Colors.teal),
                      SizedBox(height: 8),
                      Text(
                        'ত্বকের রোগ শনাক্ত করুন',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'একটি ছবি তুলুন বা গ্যালারি থেকে নির্বাচন করুন',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Image Display Section
                if (provider.selectedImage != null) ...[
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        provider.selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: provider.isLoading ? null : () => provider.classifyImage(),
                        icon: const Icon(Icons.search),
                        label: const Text('রোগ শনাক্ত করুন'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: provider.clearAll,
                        icon: const Icon(Icons.clear),
                        label: const Text('পরিষ্কার করুন'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Image Selection Buttons
                if (provider.selectedImage == null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _pickImage(context, ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('ছবি তুলুন'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _pickImage(context, ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('গ্যালারি থেকে'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Loading Indicator
                if (provider.isLoading) ...[
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('ইমেজ বিশ্লেষণ করা হচ্ছে...'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Error Display
                if (provider.error.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            provider.error,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Results Display
                if (provider.classifications.isNotEmpty) ...[
                  const Text(
                    'শনাক্তকরণ ফলাফল:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ResultWidget(classifications: provider.classifications),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
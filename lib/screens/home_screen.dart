import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../app_controller/app_controller.dart';
import '../widgets/result_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _pickImage(ImageSource source) async {
    final controller = Get.find<AppController>();
    try {
      print('Picking image from $source');
      bool hasPermission = await _requestPermissions(source);
      if (!hasPermission) {
        print('Permission denied for $source');
        Get.snackbar('অনুমতি প্রত্যাখ্যান', 'অনুগ্রহ করে $source এর জন্য অনুমতি দিন');
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
        print('Image picked: ${pickedFile.path}');
        controller.setImage(File(pickedFile.path));
      } else {
        print('No image selected');
        Get.snackbar('ত্রুটি', 'কোনো ছবি নির্বাচন করা হয়নি');
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar('ত্রুটি', 'ছবি নির্বাচনে ব্যর্থ: $e');
    }
  }

  Future<bool> _requestPermissions(ImageSource source) async {
    Permission permission = source == ImageSource.camera ? Permission.camera : Permission.photos;
    final status = await permission.request();
    return status.isGranted;
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
      body: GetBuilder<AppController>(
        init: AppController(),
        builder: (controller) => SingleChildScrollView(
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
              Obx(() => controller.selectedImage != null
                  ? Column(
                children: [
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        controller.selectedImage!,
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
                        onPressed: controller.isLoading ? null : controller.classifyImage,
                        icon: const Icon(Icons.search),
                        label: const Text('রোগ শনাক্ত করুন'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: controller.clearAll,
                        icon: const Icon(Icons.clear),
                        label: const Text('পরিষ্কার করুন'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              )
                  : Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
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
                      onPressed: () => _pickImage(ImageSource.gallery),
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
              )),

              // Loading Indicator
              Obx(() => controller.isLoading
                  ? const Column(
                children: [
                  Center(child: CircularProgressIndicator()),
                  SizedBox(height: 16),
                  Text('ইমেজ বিশ্লেষণ করা হচ্ছে...'),
                ],
              )
                  : const SizedBox.shrink()),

              // Error Display
              Obx(() => controller.error.isNotEmpty
                  ? Container(
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
                        controller.error,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              )
                  : const SizedBox.shrink()),

              // Results Display
              Obx(() => controller.classifications.isNotEmpty
                  ? Column(
                children: [
                  const Text(
                    'শনাক্তকরণ ফলাফল:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ResultWidget(classifications: controller.classifications),
                ],
              )
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}
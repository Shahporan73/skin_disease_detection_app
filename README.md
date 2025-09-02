

# Skin Disease Detection App

A Flutter-based mobile application designed to assist users in identifying potential skin diseases through image analysis. The **Skin Disease Detection App** leverages machine learning and image processing to provide preliminary skin condition assessments, offering a user-friendly interface for capturing or uploading images and displaying classification results. The app supports both English and Bengali languages and ensures robust permission handling for camera and gallery access across Android and iOS platforms.

## Overview

The **Skin Disease Detection App** empowers users to monitor their skin health by analyzing images of skin conditions. Users can capture photos using their device camera or select images from their gallery, which are then processed using a machine learning model to detect and classify potential skin diseases. The app is built with a focus on accessibility, modern design principles, and seamless user experience, addressing common issues like gallery access permissions with robust error handling.

## Features

- **Image Capture and Upload**: Capture images via the device camera or select from the gallery with optimized resolution (800x800 pixels) and quality (85%).
- **Advanced Permission Handling**: Manages camera and gallery permissions, supporting modern Android (API 33+ with `READ_MEDIA_IMAGES`) and iOS platforms, with fallbacks for older Android versions (`READ_EXTERNAL_STORAGE`).
- **Real-time Analysis**: Processes images to classify potential skin diseases using a pre-trained machine learning model (assumed to be integrated via TensorFlow Lite or a custom API).
- **Localized Interface**: Supports English and Bengali with clear instructions, error messages, and user feedback.
- **Error Handling**: Displays informative dialogs for permission denials, image selection failures, and processing errors.
- **Responsive Design**: Optimized for various screen sizes and orientations across Android and iOS devices.
- **State Management**: Utilizes the `provider` package for efficient state management across the app.

## Getting Started

Follow these steps to set up and run the **Skin Disease Detection App** locally.

### Prerequisites

- **Flutter SDK**: Install Flutter by following the [official installation guide](https://docs.flutter.dev/get-started/install).
- **Dart**: Included with Flutter; ensure compatibility with the version specified in `pubspec.yaml`.
- **IDE**: Use Visual Studio Code or Android Studio with Flutter plugins installed.
- **Device/Emulator**: A physical Android (API 30+) or iOS device, or an emulator for testing.

### Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Shahporan73/skin_disease_detection_app.git
   cd skin_disease_app

import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mydairy/app/core/widgets/shareable_card.dart';
import 'package:mydairy/domain/entities/diary_entry.dart';

class ImageShareService {
  static final ScreenshotController _screenshotController =
      ScreenshotController();

  /// Capture widget as image and save to gallery
  static Future<bool> captureAndSaveToGallery({
    required DiaryEntry entry,
    required ShareCardStyle style,
    bool useGradient = true,
    String? customTheme,
  }) async {
    try {
      // Request storage permission
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        return false;
      }

      // Create the widget to capture with proper MediaQuery context
      final widget = MediaQuery(
        data: const MediaQueryData(
          size: Size(400, 600),
          devicePixelRatio: 3.0,
          textScaler: TextScaler.linear(1.0),
          padding: EdgeInsets.zero,
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            color: Colors.transparent,
            child: ShareableCard(
              entry: entry,
              style: style,
              useGradient: useGradient,
              customTheme: customTheme,
            ),
          ),
        ),
      );

      // Capture the screenshot
      final Uint8List imageBytes = await _screenshotController
          .captureFromWidget(widget, pixelRatio: 3.0);

      // Save to gallery
      final result = await ImageGallerySaverPlus.saveImage(
        imageBytes,
        quality: 100,
        name: 'diary_${entry.id}_${DateTime.now().millisecondsSinceEpoch}',
      );
      return result.isSuccess;
    } catch (e) {
      debugPrint('Error saving image to gallery: $e');
      return false;
    }
  }

  /// Capture widget and return as bytes (for sharing via other apps)
  static Future<Uint8List?> captureAsBytes({
    required DiaryEntry entry,
    required ShareCardStyle style,
    bool useGradient = true,
    String? customTheme,
  }) async {
    try {
      final widget = MediaQuery(
        data: const MediaQueryData(
          size: Size(400, 600),
          devicePixelRatio: 3.0,
          textScaler: TextScaler.linear(1.0),
          padding: EdgeInsets.zero,
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            color: Colors.transparent,
            child: ShareableCard(
              entry: entry,
              style: style,
              useGradient: useGradient,
              customTheme: customTheme,
            ),
          ),
        ),
      );

      final Uint8List imageBytes = await _screenshotController
          .captureFromWidget(widget, pixelRatio: 3.0);

      return imageBytes;
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return null;
    }
  }

  /// Request storage permission
  static Future<bool> _requestStoragePermission() async {
    if (await Permission.storage.isGranted) {
      return true;
    }

    if (await Permission.photos.isGranted) {
      return true;
    }

    // Request permission
    final storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) {
      return true;
    }

    final photosStatus = await Permission.photos.request();
    return photosStatus.isGranted;
  }

  /// Check if permissions are granted
  static Future<bool> hasStoragePermission() async {
    return await Permission.storage.isGranted ||
        await Permission.photos.isGranted;
  }

  /// Share image directly to social media apps (Native share sheet)
  static Future<bool> shareToSocialMedia({
    required DiaryEntry entry,
    required ShareCardStyle style,
    bool useGradient = true,
    String? customTheme,
  }) async {
    try {
      // Capture the image
      final Uint8List? imageBytes = await captureAsBytes(
        entry: entry,
        style: style,
        useGradient: useGradient,
        customTheme: customTheme,
      );

      if (imageBytes == null) {
        return false;
      }

      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/diary_card_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await file.writeAsBytes(imageBytes);

      // Share using native share sheet
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out my diary entry! 📝',
        subject: 'My Diary Entry',
      );

      // Clean up temp file after sharing
      if (result.status == ShareResultStatus.success ||
          result.status == ShareResultStatus.dismissed) {
        await file.delete();
      }

      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('Error sharing to social media: $e');
      return false;
    }
  }

  /// Share image with custom text
  static Future<bool> shareImageWithText({
    required DiaryEntry entry,
    required ShareCardStyle style,
    required String customText,
    bool useGradient = true,
    String? customTheme,
  }) async {
    try {
      final Uint8List? imageBytes = await captureAsBytes(
        entry: entry,
        style: style,
        useGradient: useGradient,
        customTheme: customTheme,
      );

      if (imageBytes == null) {
        return false;
      }

      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/diary_card_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await file.writeAsBytes(imageBytes);

      final result = await Share.shareXFiles([
        XFile(file.path),
      ], text: customText);

      if (result.status == ShareResultStatus.success ||
          result.status == ShareResultStatus.dismissed) {
        await file.delete();
      }

      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('Error sharing image with text: $e');
      return false;
    }
  }
}

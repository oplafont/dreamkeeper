import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ImageAttachmentWidget extends StatefulWidget {
  final List<XFile> attachedImages;
  final Function(List<XFile>) onImagesChanged;

  const ImageAttachmentWidget({
    Key? key,
    required this.attachedImages,
    required this.onImagesChanged,
  }) : super(key: key);

  @override
  State<ImageAttachmentWidget> createState() => _ImageAttachmentWidgetState();
}

class _ImageAttachmentWidgetState extends State<ImageAttachmentWidget> {
  final ImagePicker _picker = ImagePicker();

  Future<bool> _requestPermissions() async {
    if (kIsWeb) return true;

    final cameraStatus = await Permission.camera.request();
    final storageStatus = await Permission.photos.request();

    return cameraStatus.isGranted && storageStatus.isGranted;
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(6.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Add Image to Dream',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSourceOption(
                      icon: 'camera_alt',
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    _buildSourceOption(
                      icon: 'photo_library',
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
              ],
            ),
          ),
    );
  }

  Widget _buildSourceOption({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 25.w,
        padding: EdgeInsets.symmetric(vertical: 3.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: icon,
                  color: Colors.white,
                  size: 6.w,
                ),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (!await _requestPermissions()) {
        _showPermissionDialog();
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        List<XFile> updatedImages = List.from(widget.attachedImages);
        updatedImages.add(image);
        widget.onImagesChanged(updatedImages);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      _showErrorMessage('Failed to select image');
    }
  }

  void _removeImage(int index) {
    List<XFile> updatedImages = List.from(widget.attachedImages);
    updatedImages.removeAt(index);
    widget.onImagesChanged(updatedImages);
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Permissions Required',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            content: Text(
              'Please grant camera and photo library permissions to attach images to your dreams.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
                child: const Text('Settings'),
              ),
            ],
          ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Dream Images',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'add_a_photo',
                        color: Colors.white,
                        size: 4.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Add Image',
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          widget.attachedImages.isEmpty
              ? Container(
                width: double.infinity,
                height: 15.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline,
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'image',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 8.w,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'No images attached',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Tap "Add Image" to attach photos or sketches',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : Container(
                height: 25.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.attachedImages.length,
                  itemBuilder: (context, index) {
                    final image = widget.attachedImages[index];
                    return Container(
                      width: 40.w,
                      margin: EdgeInsets.only(right: 3.w),
                      child: Stack(
                        children: [
                          Container(
                            width: 40.w,
                            height: 25.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.lightTheme.colorScheme.outline,
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child:
                                  kIsWeb
                                      ? Image.network(
                                        image.path,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            color:
                                                AppTheme
                                                    .lightTheme
                                                    .colorScheme
                                                    .surface,
                                            child: Center(
                                              child: CustomIconWidget(
                                                iconName: 'broken_image',
                                                color:
                                                    AppTheme
                                                        .lightTheme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                size: 8.w,
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                      : Image.file(
                                        File(image.path),
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            color:
                                                AppTheme
                                                    .lightTheme
                                                    .colorScheme
                                                    .surface,
                                            child: Center(
                                              child: CustomIconWidget(
                                                iconName: 'broken_image',
                                                color:
                                                    AppTheme
                                                        .lightTheme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                size: 8.w,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                            ),
                          ),
                          Positioned(
                            top: 1.h,
                            right: 2.w,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                width: 8.w,
                                height: 8.w,
                                decoration: BoxDecoration(
                                  color: AppTheme.lightTheme.colorScheme.error,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: CustomIconWidget(
                                    iconName: 'close',
                                    color: Colors.white,
                                    size: 4.w,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}

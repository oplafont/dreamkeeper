import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DreamImageGalleryWidget extends StatefulWidget {
  final List<Map<String, dynamic>> images;

  const DreamImageGalleryWidget({Key? key, required this.images})
    : super(key: key);

  @override
  State<DreamImageGalleryWidget> createState() =>
      _DreamImageGalleryWidgetState();
}

class _DreamImageGalleryWidgetState extends State<DreamImageGalleryWidget> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: 30.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 2.h),
            child: Text(
              'Dream Images',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: widget.images.length,
                  itemBuilder: (context, index) {
                    final image = widget.images[index];
                    return GestureDetector(
                      onTap: () => _showFullScreenImage(context, image),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 2.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CustomImageWidget(
                            imageUrl: image['url'] as String? ?? '',
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            semanticLabel:
                                image['semanticLabel'] as String? ??
                                'Dream sketch or image',
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (widget.images.length > 1) ...[
                  Positioned(
                    bottom: 2.h,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.images.length,
                        (index) => Container(
                          width: _currentIndex == index ? 8.w : 2.w,
                          height: 1.h,
                          margin: EdgeInsets.symmetric(horizontal: 1.w),
                          decoration: BoxDecoration(
                            color:
                                _currentIndex == index
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : AppTheme.lightTheme.colorScheme.outline
                                        .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, Map<String, dynamic> image) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: EdgeInsets.all(4.w),
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: CustomImageWidget(
                    imageUrl: image['url'] as String? ?? '',
                    width: 90.w,
                    height: 70.h,
                    fit: BoxFit.contain,
                    semanticLabel:
                        image['semanticLabel'] as String? ??
                        'Full screen dream image',
                  ),
                ),
              ),
              Positioned(
                top: 4.h,
                right: 4.w,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

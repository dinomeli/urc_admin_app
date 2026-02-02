// فایل: lib/features/common/widgets/loading_widget.dart
// ویجت لودینگ ساده، شیک و قابل استفاده در تمام پروژه
// می‌تونی این فایل رو در مسیر widgets بسازی و import کنی

import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message; // پیام اختیاری زیر لودینگ (مثل "در حال بارگذاری...")

  const LoadingWidget({
    super.key,
    this.size = 48.0,
    this.color,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 4.0,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// نسخه‌های مختلف برای استفاده راحت‌تر (اختیاری - می‌تونی از این‌ها هم استفاده کنی)

class SmallLoadingWidget extends StatelessWidget {
  const SmallLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoadingWidget(size: 32.0);
  }
}

class LoadingWithMessage extends StatelessWidget {
  final String message;

  const LoadingWithMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return LoadingWidget(message: message);
  }
}
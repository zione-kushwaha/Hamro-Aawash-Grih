import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class AppNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? fallbackUrl;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackUrl,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => _shimmer(),
      errorWidget: (_, __, ___) => fallbackUrl != null
          ? CachedNetworkImage(imageUrl: fallbackUrl!, width: width, height: height, fit: fit)
          : _errorPlaceholder(),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }

  Widget _shimmer() => Shimmer.fromColors(
        baseColor: AppColors.grey200,
        highlightColor: AppColors.grey100,
        child: Container(width: width, height: height, color: AppColors.grey200),
      );

  Widget _errorPlaceholder() => Container(
        width: width,
        height: height,
        color: AppColors.grey200,
        child: const Icon(Icons.broken_image_outlined, color: AppColors.grey400),
      );
}

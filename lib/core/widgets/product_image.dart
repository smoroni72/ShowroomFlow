import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../cache/image_cache_service.dart';

class ProductImage extends StatelessWidget {
  final String image;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  const ProductImage({
    super.key,
    required this.image,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.backgroundColor,
  });

  bool get isNetwork {
    final img = image.trim().toLowerCase();
    return img.startsWith('http');
  }

  @override
  Widget build(BuildContext context) {
    if (image.trim().isEmpty) {
      return _fallback();
    }
    Widget img;

    if (isNetwork) {
      img = FutureBuilder<File?>(
        future: ImageCacheService.getImage(image),
        builder: (context, snapshot) {

          /// 📦 FILE LOCALE (SUPER VELOCE)
          if (snapshot.hasData && snapshot.data != null) {
            return _wrap(
              Image.file(
                snapshot.data!,
                fit: fit,
                width: width,
                height: height,
              ),
            );
          }

          /// 🌐 NETWORK (fallback normale)
          return CachedNetworkImage(
            imageUrl: image,
            fit: fit,
            width: width,
            height: height,

            memCacheWidth: 800,
            maxWidthDiskCache: 800,
            fadeInDuration: const Duration(milliseconds: 250),
            fadeOutDuration: const Duration(milliseconds: 150),

            placeholder: (context, url) => _placeholder(),

            errorWidget: (context, url, error) => _fallback(),

            /// 🔥 DOWNLOAD IN BACKGROUND
            imageBuilder: (context, imageProvider) {
              ImageCacheService.downloadImage(image);
              return _wrap(
                Image(
                  image: imageProvider,
                  fit: fit,
                  width: width,
                  height: height,
                ),
              );
            },
          );
        },
      );
    } else {
      img = _wrap(
        Image.asset(
          image.trim(),
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }

    /// 🔥 BORDER RADIUS (manteniamo pulito)
    if (borderRadius != null) {
      img = ClipRRect(
        borderRadius: borderRadius!,
        child: img,
      );
    }

    /// 🔥 BACKGROUND (utile per trasparenze)
    return Container(
      color: backgroundColor,
      child: img,
    );
  }
  Widget _placeholder() {
    return Image.asset(
      'assets/images/placeholder.png',
      fit: fit,
      width: width,
      height: height,
    );
  }
  /// 🎯 FALLBACK ELEGANTE (fashion style)
  Widget _fallback() {
    return Image.asset(
      'assets/images/placeholder.png', // 👈 usa il tuo placeholder
      fit: fit,
      width: width,
      height: height,
    );
  }
  Widget _wrap(Widget child) {
    if (borderRadius != null) {
      child = ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }

    return Container(
      color: backgroundColor,
      child: child,
    );
  }
}
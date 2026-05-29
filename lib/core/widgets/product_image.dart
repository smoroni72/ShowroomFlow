import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'shimmer_loader.dart';

enum ImageSize {
  small,  // Per le miniature delle griglie (300px)
  medium, // Per le card o le liste medie (600px)
  large,  // Per i dettagli prodotto (1200px)
  original // Senza restrizioni
}

class ProductImage extends StatelessWidget {
  final String image;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final ImageSize size; // 👈 Nuovo parametro fondamentale

  const ProductImage({
    super.key,
    required this.image,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.size = ImageSize.medium, // Default equilibrato
  });

  /// 🛠️ LOGICA CLOUDINARY OTTIMIZZATA
  String _optimizeUrl(String url) {
    if (!url.contains('cloudinary.com') || !url.contains('/upload/')) {
      return url;
    }

    // Definiamo la larghezza in base al contesto
    int widthPx;
    switch (size) {
      case ImageSize.small: widthPx = 300; break;
      case ImageSize.medium: widthPx = 600; break;
      case ImageSize.large: widthPx = 1200; break;
      case ImageSize.original: return url.replaceFirst('/upload/', '/upload/f_auto,q_auto/');
    }

    // Inseriamo f_auto (formato smart), q_auto (qualità smart) e la larghezza precisa
    // Questo riduce il peso dell'immagine dell'80% senza perdita visibile
    return url.replaceFirst('/upload/', '/upload/f_auto,q_auto,w_$widthPx,c_limit/');
  }

  @override
  Widget build(BuildContext context) {
    var cleanedUrl = image.trim();
    if (cleanedUrl.isEmpty) return _fallback();

    if (cleanedUrl.startsWith('/')) {
      cleanedUrl = "https://fashion-app-ed9d3.web.app$cleanedUrl";
    }

    final isNetwork = cleanedUrl.startsWith('http');
    final effectiveUrl = isNetwork ? _optimizeUrl(cleanedUrl) : cleanedUrl;

    Widget img;

    if (isNetwork) {
      img = CachedNetworkImage(
        imageUrl: effectiveUrl,
        fit: fit,
        width: width,
        height: height,

        // Impostiamo la cache di memoria solo per le miniature per risparmiare RAM
        // Per Medium/Large lasciamo che Flutter gestisca il decode nativo
        memCacheWidth: size == ImageSize.small ? 300 : null,

        // Usiamo lo Skeleton Loader dedicato per un caricamento fluido
        placeholder: (context, url) => (width != null && height != null)
            ? ShimmerLoader(
          width: width!,
          height: height!,
          borderRadius: borderRadius,
        )
            : const Center(child: CircularProgressIndicator(strokeWidth: 1)),

        // Fallback in caso di errore
        errorWidget: (context, url, error) => _fallback(),

        // Migliora la fluidità di apparizione
        fadeInDuration: const Duration(milliseconds: 400),
      );
    } else {
      img = Image.asset(
        cleanedUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    // Applichiamo il raggio se presente
    if (borderRadius != null) {
      img = ClipRRect(
        borderRadius: borderRadius!,
        child: img,
      );
    }

    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey[950], // Look dark premium
      child: img,
    );
  }

  Widget _shimmerPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.white.withOpacity(0.05),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 1,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white24),
          ),
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade900,
      child: const Icon(Icons.broken_image_outlined, color: Colors.white12, size: 20),
    );
  }
}
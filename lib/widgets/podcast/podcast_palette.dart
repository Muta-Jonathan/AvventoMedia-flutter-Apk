import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Colours for the podcast feed and Downloads, in both themes. Explicit
/// because the dark theme's onSurface matches its background.
class PodcastPalette {
  PodcastPalette(BuildContext context)
      : dark = Theme.of(context).brightness == Brightness.dark;
  final bool dark;

  static const accent = Color(0xFFFFB300);

  Color get title => dark ? Colors.white : const Color(0xFF161424);
  Color get subtitle => dark ? const Color(0xFFBDBDBD) : Colors.black54;
  Color get muted => dark ? const Color(0xFF9E9E9E) : Colors.black45;
  Color get summary => dark ? const Color(0xFF9E9CB0) : Colors.black54;
  Color get played => dark ? const Color(0xFF9E9E9E) : Colors.black38;

  /// Current episode's title and the NEW tag; darker in light for contrast.
  Color get highlight =>
      dark ? const Color(0xFFFFCA28) : const Color(0xFFB26A00);
  Color get button => dark ? const Color(0xFF2E2C3D) : Colors.white;
  Color get card => dark ? const Color(0xFF221F33) : Colors.white;
  Color get divider => dark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.08);
  Color get track => dark
      ? Colors.white.withValues(alpha: 0.2)
      : Colors.black.withValues(alpha: 0.15);
  Color get headerGlow => accent.withValues(alpha: dark ? 0.28 : 0.22);
  Color get sheet => dark ? const Color(0xFF221F33) : Colors.white;
}

/// AzuraCast artwork (needs the API key), with a tinted placeholder.
class PodcastArt extends StatelessWidget {
  const PodcastArt(
      {super.key, required this.url, required this.size, this.radius = 10});

  final String url;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      color: PodcastPalette.accent.withValues(alpha: 0.15),
      child: Icon(Icons.podcasts_rounded,
          size: size * 0.4, color: PodcastPalette.accent),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url.isEmpty
          ? placeholder
          : CachedNetworkImage(
              imageUrl: url,
              httpHeaders: {
                'Authorization':
                    'Bearer ${dotenv.isInitialized ? dotenv.env['AZURACAST_APIKEY'] : ''}',
              },
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (_, __) => placeholder,
              errorWidget: (_, __, ___) => placeholder,
            ),
    );
  }
}

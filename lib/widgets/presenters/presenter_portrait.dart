import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../themes/avvento_colors.dart';

/// "Pr. Okello Samuel" → "OS": skips titles like Pr., Ev., Dr.
String presenterInitials(String name) {
  final words = name
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty && !w.endsWith('.'))
      .toList();
  if (words.isEmpty) return '?';
  final first = words.first[0];
  return (words.length == 1 ? first : '$first${words.last[0]}').toUpperCase();
}

/// Circular portrait cropped from sermon art. Aligned high so the AVVENTO
/// RADIO band at the bottom of most covers stays out; initials when there's
/// no image. [ring] adds the accent ring used on the presenter page.
class PresenterPortrait extends StatelessWidget {
  const PresenterPortrait({
    super.key,
    required this.name,
    required this.image,
    required this.size,
    this.ring = false,
  });

  final String name;
  final String image;
  final double size;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final initials = Container(
      width: size,
      height: size,
      color: c.accentSoft,
      alignment: Alignment.center,
      child: Text(presenterInitials(name),
          style: TextStyle(
              color: c.accentText,
              fontSize: size * 0.34,
              fontWeight: FontWeight.w700)),
    );
    final portrait = ClipOval(
      child: image.isEmpty
          ? initials
          : CachedNetworkImage(
              imageUrl: image,
              width: size,
              height: size,
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.4),
              placeholder: (_, __) => initials,
              errorWidget: (_, __, ___) => initials,
            ),
    );
    if (!ring) return ExcludeSemantics(child: portrait);
    // 3px page-colored gap, then a 2px accent ring.
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: c.accent, width: 2),
        ),
        child: portrait,
      ),
    );
  }
}

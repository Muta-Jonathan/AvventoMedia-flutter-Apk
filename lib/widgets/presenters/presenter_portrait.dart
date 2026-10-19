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
/// no image.
///
/// [ring]: null draws no ring; false keeps the ring's space (so a row of
/// portraits lines up) and true draws the accent "new sermon" ring.
class PresenterPortrait extends StatelessWidget {
  const PresenterPortrait({
    super.key,
    required this.name,
    required this.image,
    required this.size,
    this.ring,
    this.ringGap = 2.5,
    this.ringWidth = 2.5,
  });

  final String name;
  final String image;
  final double size;
  final bool? ring;

  /// Page-colored gap and ring width around the portrait.
  final double ringGap;
  final double ringWidth;

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
    if (ring == null) return ExcludeSemantics(child: portrait);
    return ExcludeSemantics(
      child: Container(
        padding: EdgeInsets.all(ringGap + ringWidth),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: ring! ? c.accent : Colors.transparent, width: ringWidth),
        ),
        child: portrait,
      ),
    );
  }
}

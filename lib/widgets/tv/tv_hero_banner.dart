import 'dart:async';
import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/models/highlightmodel/highlight_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class TvHeroBanner extends StatefulWidget {
  final HighlightModel? highlightItem;
  final VoidCallback onPlayPressed;
  final VoidCallback? onMoreInfoPressed;
  final bool isActive;

  const TvHeroBanner({
    super.key,
    required this.highlightItem,
    required this.onPlayPressed,
    this.onMoreInfoPressed,
    this.isActive = true,
  });

  @override
  State<TvHeroBanner> createState() => _TvHeroBannerState();
}

class _TvHeroBannerState extends State<TvHeroBanner> {
  YoutubePlayerController? _youtubeController;
  bool _isMuted = true;
  bool _isVideoReady = false;
  Timer? _previewTimer;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _initVideoPreview();
    }
  }

  @override
  void didUpdateWidget(covariant TvHeroBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.highlightItem?.title != widget.highlightItem?.title) {
      _disposeVideoController();
      if (widget.isActive) _initVideoPreview();
    } else if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _initVideoPreview();
      } else {
        _disposeVideoController();
      }
    }
  }

  void _initVideoPreview() {
    final videoId = _extractVideoId(widget.highlightItem);
    if (videoId != null && videoId.isNotEmpty) {
      // Delay preview by 1 second to give smooth poster impression first
      _previewTimer = Timer(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: true, // Auto-preview muted by default
            loop: true,
            hideControls: true,
            forceHD: true,
          ),
        )..addListener(() {
            if (_youtubeController != null &&
                _youtubeController!.value.isReady &&
                !_isVideoReady) {
              if (mounted) {
                setState(() {
                  _isVideoReady = true;
                });
              }
            }
          });
      });
    }
  }

  String? _extractVideoId(HighlightModel? item) {
    if (item == null) return null;
    if (item.youtubePlaylistItem?.videoId != null) {
      return item.youtubePlaylistItem!.videoId;
    }
    return null;
  }

  void _toggleMute() {
    if (_youtubeController != null) {
      setState(() {
        _isMuted = !_isMuted;
        if (_isMuted) {
          _youtubeController!.mute();
        } else {
          _youtubeController!.unMute();
        }
      });
    }
  }

  void _disposeVideoController() {
    _previewTimer?.cancel();
    _youtubeController?.dispose();
    _youtubeController = null;
    _isVideoReady = false;
  }

  @override
  void dispose() {
    _disposeVideoController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.highlightItem;
    final title = item?.title ?? item?.name ?? AppConstants.appName;
    final description = item?.youtubePlaylistItem?.description ??
        'Experience uplifting media, live broadcasts, and audio podcasts.';
    final posterUrl = item?.imageUrl ?? '';

    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: screenHeight * 0.55,
      margin: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image Poster
            if (posterUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: posterUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(color: Colors.black87),
              )
            else
              Container(color: Colors.black),

            // Video Preview Overlay (Muted auto-play)
            if (_youtubeController != null && _isVideoReady)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: _isVideoReady ? 1.0 : 0.0,
                child: IgnorePointer(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width * 9 / 16,
                      child: YoutubePlayer(
                        controller: _youtubeController!,
                        showVideoProgressIndicator: false,
                      ),
                    ),
                  ),
                ),
              ),

            // Dark Vignette Overlay Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                    Theme.of(context).colorScheme.surface,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0.0, 0.4, 0.6, 0.9, 1.0],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                    Theme.of(context).colorScheme.surface,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.4, 0.7, 1.0],
                ),
              ),
            ),

            // Top Right Mute / Unmute Toggle Button (Apple TV Style)
            if (_youtubeController != null && _isVideoReady)
              Positioned(
                top: 80,
                right: 40,
                child: _TvMuteButton(
                  isMuted: _isMuted,
                  onPressed: _toggleMute,
                ),
              ),

            // Content Typography & Action Buttons (Bottom-Left)
            Positioned(
              left: 48,
              bottom: 40,
              width: MediaQuery.of(context).size.width * 0.45,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Featured Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade700,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'FEATURED',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Action Buttons
                  Row(
                    children: [
                      _TvActionButton(
                        label: 'Watch Now',
                        icon: CupertinoIcons.play_fill,
                        isPrimary: true,
                        onPressed: widget.onPlayPressed,
                      ),
                      if (widget.onMoreInfoPressed != null) ...[
                        const SizedBox(width: 16),
                        _TvActionButton(
                          label: 'More Info',
                          icon: CupertinoIcons.info_circle,
                          isPrimary: false,
                          onPressed: widget.onMoreInfoPressed!,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TvMuteButton extends StatefulWidget {
  final bool isMuted;
  final VoidCallback onPressed;

  const _TvMuteButton({required this.isMuted, required this.onPressed});

  @override
  State<_TvMuteButton> createState() => _TvMuteButtonState();
}

class _TvMuteButtonState extends State<_TvMuteButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isFocused = true),
          onExit: (_) => setState(() => _isFocused = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _isFocused ? Colors.white : Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isMuted ? CupertinoIcons.volume_off : CupertinoIcons.volume_up,
                  color: _isFocused ? Colors.black : Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.isMuted ? 'UNMUTE' : 'MUTE',
                  style: TextStyle(
                    color: _isFocused ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TvActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _TvActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  State<_TvActionButton> createState() => _TvActionButtonState();
}

class _TvActionButtonState extends State<_TvActionButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isFocused = true),
          onExit: (_) => setState(() => _isFocused = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: _isFocused ? (Matrix4.identity()..scale(1.08)) : Matrix4.identity(),
            transformAlignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isPrimary
                  ? (_isFocused ? Colors.white : Colors.amber.shade600)
                  : (_isFocused ? Colors.white.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.15)),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isFocused ? Colors.white : Colors.transparent,
                width: 2,
              ),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.4),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  size: 20,
                  color: widget.isPrimary
                      ? (_isFocused ? Colors.black : Colors.black)
                      : Colors.white,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: widget.isPrimary
                        ? (_isFocused ? Colors.black : Colors.black)
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'avvento_colors.dart';
import 'avvento_tokens.dart';

/// Themes for the redesigned screens. The app still runs on the old themes;
/// redesigned screens opt in with [AvventoThemeScope].
abstract final class AvventoTheme {
  static final ThemeData dark = _build(Brightness.dark, AvventoColors.dark);
  static final ThemeData light = _build(Brightness.light, AvventoColors.light);

  static ThemeData of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  /// Bundled serif (see pubspec.yaml). Only for page titles, the live song
  /// title and Bible book headers; everything else uses the system font.
  static const newsreader = 'Newsreader';

  static TextTheme textTheme(AvventoColors c) {
    TextStyle ui(double size, double lh, FontWeight w, Color color) =>
        TextStyle(
            fontSize: size,
            height: lh / size,
            fontWeight: w,
            color: color);
    TextStyle display(double size, double lh) => TextStyle(
        fontFamily: newsreader,
        fontSize: size,
        height: lh / size,
        fontWeight: FontWeight.w600,
        color: c.text);

    return TextTheme(
      displaySmall: display(28, 34),
      headlineSmall: display(22, 28),
      titleLarge: ui(18, 24, FontWeight.w700, c.text),
      titleMedium: ui(16, 21, FontWeight.w700, c.text),
      bodyMedium: ui(14, 21, FontWeight.w400, c.text),
      bodySmall: ui(13, 19, FontWeight.w400, c.text2),
      labelMedium: ui(12, 16, FontWeight.w700, c.text2),
      labelSmall:
          ui(11, 14, FontWeight.w700, c.text2).copyWith(letterSpacing: 0.6),
    );
  }

  static ThemeData _build(Brightness brightness, AvventoColors c) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: c.onAccent,
      secondary: c.accent,
      onSecondary: c.onAccent,
      // Old widgets read tertiary as the playback accent.
      tertiary: c.accent,
      onTertiary: c.onAccent,
      error: c.liveDot,
      onError: Colors.white,
      surface: c.surface,
      onSurface: c.text,
      onSurfaceVariant: c.text2,
      surfaceContainerLow: c.surface,
      surfaceContainer: c.surface,
      surfaceContainerHigh: c.surface2,
      surfaceContainerHighest: c.surface2,
      outline: c.text3,
      outlineVariant: c.line,
    );
    final text = textTheme(c);
    final overlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: c.nav,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: brightness,
    );
    const pillShape = StadiumBorder();

    return ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      dividerColor: c.line,
      textTheme: text,
      iconTheme: IconThemeData(color: c.text2),
      extensions: [c],
      appBarTheme: AppBarTheme(
        backgroundColor: c.bg,
        foregroundColor: c.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: text.headlineSmall,
        systemOverlayStyle: overlay,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.nav,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.accentSoft,
        labelTextStyle: WidgetStatePropertyAll(text.labelMedium),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: c.text3,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AvventoRadii.xl)),
        ),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AvventoRadii.md),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: c.onAccent,
          minimumSize: const Size(AvventoSpacing.minTap, AvventoSpacing.minTap),
          textStyle: text.titleMedium,
          shape: pillShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.text,
          side: BorderSide(color: c.line),
          minimumSize: const Size(AvventoSpacing.minTap, AvventoSpacing.minTap),
          textStyle: text.titleMedium,
          shape: pillShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accentText,
          minimumSize: const Size(AvventoSpacing.minTap, AvventoSpacing.minTap),
          textStyle: text.labelMedium,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: c.text,
          minimumSize: const Size(AvventoSpacing.minTap, AvventoSpacing.minTap),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? c.onAccent : c.text3),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? c.accent : c.surface2),
        trackOutlineColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? c.accent : c.line),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? c.accent : c.text3),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.accent,
        linearTrackColor: c.surface2,
        circularTrackColor: c.surface2,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.text,
        contentTextStyle: text.bodyMedium?.copyWith(color: c.bg),
        // Inverse surface, so use the opposite mode's accent.
        actionTextColor: isDark
            ? AvventoColors.light.accentText
            : AvventoColors.dark.accentText,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AvventoRadii.sm),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.accent,
        selectionHandleColor: c.accent,
        selectionColor: c.accentSoft,
      ),
    );
  }
}

/// Applies [AvventoTheme] to a redesigned screen, following the app's
/// current brightness.
class AvventoThemeScope extends StatelessWidget {
  const AvventoThemeScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AvventoTheme.of(Theme.of(context).brightness),
      child: child,
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design system tokens directly matching the approved LocaLink HTML UI/UX spec.
class UiColors {
  // Neutrals from the HTML design specification
  static const Color bg = Color(0xFFF6F9F8);
  static const Color ink = Color(0xFF14262B);
  static const Color muted = Color(0xFF66777A);
  static const Color line = Color(0xFFDDE6E5);
  static const Color card = Colors.white;

  // Feature Accents
  static const Color teal = Color(0xFF0E5E63); // Requests, customer, primary
  static const Color indigo = Color(0xFF3D4F9F); // Service provider
  static const Color amber = Color(0xFFB97800); // Shop and place owner
  static const Color red = Color(0xFFC0392B); // SOS only
  static const Color redLight = Color(0xFFE5493A);
  static const Color redDark = Color(0xFFB02A1E);
  static const Color star = Color(0xFFE8A317);
}

/// Plus Jakarta Sans typography helper function.
Text uiText(
  String text, {
  double size = 13.5,
  FontWeight weight = FontWeight.w600,
  Color? color,
  TextAlign? align,
  int? maxLines,
  TextOverflow? overflow,
  double? height,
}) {
  return Text(
    text,
    textAlign: align,
    maxLines: maxLines,
    overflow: overflow,
    style: GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color ?? UiColors.ink,
      height: height,
    ),
  );
}

/// Helper method to build a feature-scoped Theme with the given accent color.
ThemeData uiFeatureTheme(BuildContext context, Color accent) {
  final base = Theme.of(context);
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: accent,
      surface: UiColors.card,
    ),
    scaffoldBackgroundColor: UiColors.bg,
  );
}

/// Standard LocaLink Header Scaffold with circular white back button and title.
class UiScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? trailing;
  final VoidCallback? onBack;
  final Widget? bottomNavigationBar;
  final Widget? bottomButton;
  final bool showBackButton;
  final EdgeInsetsGeometry padding;

  const UiScaffold({
    super.key,
    required this.title,
    required this.body,
    this.trailing,
    this.onBack,
    this.bottomNavigationBar,
    this.bottomButton,
    this.showBackButton = true,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UiColors.bg,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        child: Column(
          children: [
            // Header bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: [
                  if (showBackButton)
                    GestureDetector(
                      onTap: onBack ?? () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          size: 22,
                          color: UiColors.ink,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 4),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: UiColors.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ? trailing,
                ],
              ),
            ),
            // Body contents
            Expanded(
              child: Padding(
                padding: padding,
                child: body,
              ),
            ),
            // Optional pinned bottom button
            if (bottomButton != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: bottomButton,
              ),
          ],
        ),
      ),
    );
  }
}

/// Main Action Button with accent gradient, shadow, and disabled state.
class UiMainButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? customAccent;
  final IconData? icon;

  const UiMainButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.customAccent,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final accent = customAccent ?? Theme.of(context).colorScheme.primary;
    final isEnabled = onPressed != null && !isLoading;

    // Disabled styling: grey #DDE6E5 with muted text #66777A
    if (!isEnabled && !isLoading) {
      return Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: UiColors.line,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: UiColors.muted,
          ),
        ),
      );
    }

    // Gradient from accent to accent mixed 35% with black
    final darkMix = Color.lerp(accent, Colors.black, 0.35) ?? accent;

    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, darkMix],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isEnabled ? onPressed : null,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
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

/// Ghost Button: White background, radius 14, 1.5 px border (accent at 45%), accent text.
class UiGhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? customAccent;
  final IconData? icon;

  const UiGhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.customAccent,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final accent = customAccent ?? Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent.withValues(alpha: 0.45),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: accent, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: accent,
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

/// Styled Text Input: White, radius 12, 1 px #DDE6E5 border, focus 1.6 px accent, label 13.5 px muted.
class UiTextInput extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final bool enabled;
  final String? hintText;

  const UiTextInput({
    super.key,
    required this.label,
    this.controller,
    this.onChanged,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: UiColors.muted,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          enabled: enabled,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: UiColors.ink,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: UiColors.muted,
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: UiColors.line, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accent, width: 1.6),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: UiColors.red, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: UiColors.red, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}

/// Pill Chip: Pill shape, white with 1 px line border; selected = filled accent with white text; 13 px weight 600.
class UiChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? customAccent;

  const UiChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
    this.customAccent,
  });

  @override
  Widget build(BuildContext context) {
    final accent = customAccent ?? Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? accent : Colors.white,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: isSelected ? accent : UiColors.line,
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : UiColors.ink,
          ),
        ),
      ),
    );
  }
}

/// List Tile: White, radius 14, soft shadow, 36 px icon square (radius 11, accent at 14% tint), title 13.5 px weight 700, sub text 11.5 px muted, chevron.
class UiListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? customAccent;

  const UiListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.onTap,
    this.customAccent,
  });

  @override
  Widget build(BuildContext context) {
    final accent = customAccent ?? Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(icon, size: 18, color: accent),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: UiColors.ink,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: UiColors.muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing!
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: Color(0xFF9AA9AB),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Upload Card: 130 px tall, radius 16, soft accent gradient, centered icon and label, shows picked image with white caption tag.
class UiUploadCard extends StatelessWidget {
  final String label;
  final File? pickedFile;
  final String? existingUrl;
  final VoidCallback onTap;
  final IconData icon;

  const UiUploadCard({
    super.key,
    required this.label,
    this.pickedFile,
    this.existingUrl,
    required this.onTap,
    this.icon = Icons.camera_alt_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final hasImage = pickedFile != null || (existingUrl != null && existingUrl!.isNotEmpty);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              accent.withValues(alpha: 0.12),
              accent.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: accent.withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (pickedFile != null)
              Positioned.fill(
                child: Image.file(
                  pickedFile!,
                  fit: BoxFit.cover,
                ),
              )
            else if (existingUrl != null && existingUrl!.isNotEmpty)
              Positioned.fill(
                child: Image.network(
                  existingUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),
            if (!hasImage)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 24, color: accent),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ],
              )
            else
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 14, color: accent),
                      const SizedBox(width: 4),
                      Text(
                        label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: UiColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Map Placeholder: #E6EDEA rounded box, soft green and blue circles, two white road lines, accent pin icon, white label tag bottom-left.
class UiMapPlaceholder extends StatelessWidget {
  final String label;
  final double height;
  final VoidCallback? onTap;

  const UiMapPlaceholder({
    super.key,
    this.label = 'Map area',
    this.height = 120,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE6EDEA),
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Soft green circle
            Positioned(
              left: 20,
              top: 15,
              child: Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Color(0xFFCFE6D6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Soft blue circle
            Positioned(
              right: 25,
              bottom: 10,
              child: Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFFCFE0EE),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Road line 1
            Positioned(
              top: 0,
              bottom: 0,
              left: 80,
              child: Container(
                width: 8,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            // Road line 2
            Positioned(
              left: 0,
              right: 0,
              top: 50,
              child: Container(
                height: 8,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            // Accent pin center
            Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            // White label tag bottom-left
            Positioned(
              left: 8,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: UiColors.ink,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Warning Banner: Red gradient (#E5493A to #B02A1E), white bold text, radius 13.
class UiWarningBanner extends StatelessWidget {
  final String text;
  final IconData icon;

  const UiWarningBanner({
    super.key,
    required this.text,
    this.icon = Icons.warning_amber_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [UiColors.redLight, UiColors.redDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: UiColors.red.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cover Screen: Full gradient (accent to accent mixed 45% with black), centered 84 px translucent white circle with a white icon, white title 22 px weight 800, white 80% subtitle, white or outlined buttons.
class UiCoverScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final Color? customAccent;

  const UiCoverScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.primaryButtonText,
    this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.customAccent,
  });

  @override
  Widget build(BuildContext context) {
    final accent = customAccent ?? Theme.of(context).colorScheme.primary;
    final darkMix = Color.lerp(accent, Colors.black, 0.45) ?? accent;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accent, darkMix],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                if (primaryButtonText != null) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: onPrimaryPressed,
                      child: Text(
                        primaryButtonText!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (secondaryButtonText != null) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: onSecondaryPressed,
                      child: Text(
                        secondaryButtonText!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Stepper: Row of 6 px rounded bars (accent when reached) with 10.5 px labels.
class UiStepper extends StatelessWidget {
  final int totalSteps;
  final int currentStep; // 1-indexed
  final List<String>? stepLabels;
  final Color? customAccent;

  const UiStepper({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.stepLabels,
    this.customAccent,
  });

  @override
  Widget build(BuildContext context) {
    final accent = customAccent ?? Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        Row(
          children: [
            for (int i = 1; i <= totalSteps; i++) ...[
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: i <= currentStep ? accent : UiColors.line,
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
              if (i < totalSteps) const SizedBox(width: 4),
            ],
          ],
        ),
        if (stepLabels != null && stepLabels!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 0; i < stepLabels!.length; i++)
                Expanded(
                  child: Text(
                    stepLabels![i],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: (i + 1) <= currentStep ? accent : UiColors.muted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Star Rating display (e.g., 4.6 from 38 reviews).
class UiStarRating extends StatelessWidget {
  final double rating;
  final int? reviewCount;

  const UiStarRating({
    super.key,
    required this.rating,
    this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 1; i <= 5; i++)
          Icon(
            i <= rating
                ? Icons.star_rounded
                : (i - rating <= 0.5 ? Icons.star_half_rounded : Icons.star_outline_rounded),
            size: 16,
            color: UiColors.star,
          ),
        const SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: UiColors.ink,
          ),
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: UiColors.muted,
            ),
          ),
        ],
      ],
    );
  }
}

/// Bottom Sheet Frame: rounded top corners, drag handle, title, body.
class UiBottomSheetFrame extends StatelessWidget {
  final String title;
  final Widget child;

  const UiBottomSheetFrame({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: UiColors.line,
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: UiColors.ink,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

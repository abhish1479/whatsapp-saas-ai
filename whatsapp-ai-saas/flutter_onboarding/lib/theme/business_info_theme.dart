import 'package:flutter/material.dart';

/// Theme extension to keep design tokens consistent across BusinessInfo UI.
@immutable
class BusinessInfoTheme extends ThemeExtension<BusinessInfoTheme> {
  final Gradient formGradient;
  final Gradient buttonGradient;
  final BoxShadow cardShadow;
  final BorderRadius borderRadius;
  final EdgeInsets screenPadding;

  const BusinessInfoTheme({
    required this.formGradient,
    required this.buttonGradient,
    required this.cardShadow,
    required this.borderRadius,
    required this.screenPadding,
  });

  @override
  BusinessInfoTheme copyWith({
    Gradient? formGradient,
    Gradient? buttonGradient,
    BoxShadow? cardShadow,
    BorderRadius? borderRadius,
    EdgeInsets? screenPadding,
  }) {
    return BusinessInfoTheme(
      formGradient: formGradient ?? this.formGradient,
      buttonGradient: buttonGradient ?? this.buttonGradient,
      cardShadow: cardShadow ?? this.cardShadow,
      borderRadius: borderRadius ?? this.borderRadius,
      screenPadding: screenPadding ?? this.screenPadding,
    );
  }

  @override
  BusinessInfoTheme lerp(ThemeExtension<BusinessInfoTheme>? other, double t) {
    if (other is! BusinessInfoTheme) return this;
    return BusinessInfoTheme(
      formGradient: Gradient.lerp(formGradient, other.formGradient, t)!,
      buttonGradient: Gradient.lerp(buttonGradient, other.buttonGradient, t)!,
      cardShadow: BoxShadow.lerp(cardShadow, other.cardShadow, t)!,
      borderRadius: BorderRadius.lerp(borderRadius, other.borderRadius, t)!,
      screenPadding: EdgeInsets.lerp(screenPadding, other.screenPadding, t)!,
    );
  }

  /// Default theme values
  static final light = BusinessInfoTheme(
    formGradient: LinearGradient(
      colors: [Colors.blue[50]!, Colors.purple[50]!],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    buttonGradient: LinearGradient(
      colors: [Colors.blue[600]!, Colors.purple[600]!],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    cardShadow: BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    borderRadius: BorderRadius.circular(12),
    screenPadding: const EdgeInsets.all(24),
  );
}

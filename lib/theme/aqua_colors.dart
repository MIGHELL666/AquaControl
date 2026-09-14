import 'package:flutter/material.dart';

class AquaColors {
  // ============================================================
  // PALETA OFICIAL AQUACONTROL 2026
  // ============================================================

  // Color Principal — Turquoise
  static const Color turquoise = Color(0xFF447F98);

  // Color Secundario — Slate Blue
  static const Color slateBlue = Color(0xFF629BB5);

  // Superficies Neutras — Platinum
  static const Color platinum = Color(0xFFDADEE1);

  // Superficies Glass — Glacier
  static const Color glacier = Color(0xFFB9D8E1);

  // Fondo Principal — Ice Blue
  static const Color iceBlue = Color(0xFFD6EBF3);

  // ============================================================
  // VARIACIONES TRANSLÚCIDAS — GLASSMORPHISM
  // ============================================================

  // Fondo de tarjetas glass (blanco translúcido)
  static const Color glassSurface = Color(0x7AFFFFFF);

  // Fondo glass alternativo (glacier translúcido)
  static const Color glassSurfaceGlacier = Color(0x61B9D8E1);

  // Fondo glass suave (para paneles flotantes)
  static const Color glassSurfaceLight = Color(0xB3D6EBF3);

  // Borde glass principal (blanco translúcido brillante)
  static const Color glassBorder = Color(0xBFFFFFFF);

  // Borde glass sutil (platinum translúcido)
  static const Color glassBorderSubtle = Color(0x80DADEE1);

  // Borde glass turquoise (para elementos activos)
  static const Color glassBorderActive = Color(0x66447F98);

  // ============================================================
  // TEXTOS — ALTO CONTRASTE PARA FONDOS CLAROS
  // ============================================================

  // Texto principal — petróleo profundo
  static const Color textPrimary = Color(0xFF132D3B);

  // Texto secundario — pizarra medio
  static const Color textSecondary = Color(0xFF355668);

  // Texto atenuado — pizarra suave (placeholders, metadata)
  static const Color textMuted = Color(0xFF648494);

  // Texto sobre fondos oscuros/turquoise (botones primarios)
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ============================================================
  // ESTADOS DEL SISTEMA
  // ============================================================

  // Abastecido / Correcto
  static const Color statusSupplied = Color(0xFF2A7A5C);
  static const Color statusSuppliedBg = Color(0x332A7A5C);
  static const Color statusSuppliedBorder = Color(0x662A7A5C);

  // Pendiente / Advertencia
  static const Color statusPending = Color(0xFFC47A1A);
  static const Color statusPendingBg = Color(0x33C47A1A);
  static const Color statusPendingBorder = Color(0x66C47A1A);

  // Error / Peligro
  static const Color statusError = Color(0xFFC45347);
  static const Color statusErrorBg = Color(0x33C45347);
  static const Color statusErrorBorder = Color(0x66C45347);

  // Información
  static const Color statusInfo = Color(0xFF447F98);
  static const Color statusInfoBg = Color(0x33447F98);

  // ============================================================
  // SOMBRAS
  // ============================================================

  // Sombra principal de cards (turquoise muy suave)
  static const Color shadowCard = Color(0x14447F98);

  // Sombra de elementos flotantes (más pronunciada)
  static const Color shadowFloat = Color(0x22447F98);

  // Sombra de botón primario (turquoise glow)
  static const Color shadowButton = Color(0x44447F98);

  // ============================================================
  // COMPATIBILIDAD HACIA ATRÁS (aliases)
  // ============================================================

  /// @deprecated Usar [turquoise]
  static const Color cornflowerBlue = turquoise;

  /// @deprecated Usar [slateBlue]
  static const Color icyBlue = slateBlue;

  /// @deprecated Usar [textPrimary] o [iceBlue]
  static const Color deepNavy = Color(0xFF132D3B);

  /// @deprecated Usar [glassSurface]
  static const Color surfaceCard = Color(0x7AFFFFFF);

  /// @deprecated Usar [glassBorderSubtle]
  static const Color glassBorderOld = Color(0x80DADEE1);

  /// @deprecated Usar [iceBlue]
  static const Color backgroundDark = iceBlue;

  /// @deprecated Usar [iceBlue]
  static const Color surfaceNavy = glacier;

  /// @deprecated Usar [slateBlue]
  static const Color persianBlue = slateBlue;

  /// @deprecated Usar [turquoise]
  static const Color duskBlue = turquoise;
}


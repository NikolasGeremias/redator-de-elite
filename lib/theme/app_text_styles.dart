import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fonteTitulo = 'Galyon';
  static const String fonteSubtitulo = 'Century751';

  static const TextStyle tituloGrande = TextStyle(
    fontFamily: fonteTitulo,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,
    color: AppColors.textoForte,
    height: 1.2,
  );

  static const TextStyle tituloMedio = TextStyle(
    fontFamily: fonteSubtitulo,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,
    color: AppColors.textoForte,
    height: 1.2,
  );

  static const TextStyle tituloPequeno = TextStyle(
    fontFamily: fonteSubtitulo,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,
    color: AppColors.textoForte,
    height: 1.3,
  );

  static const TextStyle subtituloDestaque = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textoForte,
    height: 1.4,
  );

  static const TextStyle corpo = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textoSuave,
    height: 1.5,
  );

  static const TextStyle corpoMedio = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textoSuave,
    height: 1.5,
  );

  static const TextStyle legenda = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textoApagado,
    height: 1.4,
  );

  static const TextStyle botao = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.branco,
    letterSpacing: 0.3,
  );
}

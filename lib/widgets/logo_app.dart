import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';

class LogoApp extends StatelessWidget {
  final double tamanho;
  final Color? corFundo;

  const LogoApp({super.key, this.tamanho = 140, this.corFundo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        color: corFundo,
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          AppConstants.logoPath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

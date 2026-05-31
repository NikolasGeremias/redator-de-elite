import 'dart:io';

import 'package:flutter/material.dart';

import '../core/utils/carregador_imagem.dart';
import '../theme/app_colors.dart';

class ImagemInteligente extends StatelessWidget {
  final String? caminho;
  final BoxFit fit;
  final Widget? placeholder;

  const ImagemInteligente({
    super.key,
    required this.caminho,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  Widget _placeholderPadrao() {
    return placeholder ??
        Container(
          color: AppColors.superficieElevada,
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_outlined,
            size: 48,
            color: AppColors.textoApagado,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final c = caminho;
    if (c == null || c.isEmpty) return _placeholderPadrao();
    if (CarregadorImagem.ehUrlRemota(c)) {
      return Image.network(
        c,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: AppColors.superficieElevada,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        },
        errorBuilder: (context, e, _) => _placeholderPadrao(),
      );
    }
    if (CarregadorImagem.ehArquivoLocalValido(c)) {
      return Image.file(
        File(c),
        fit: fit,
        errorBuilder: (context, e, _) => _placeholderPadrao(),
      );
    }
    return _placeholderPadrao();
  }
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'imagem_inteligente.dart';

class VisualizadorImagem extends StatelessWidget {
  final String caminho;
  final String? titulo;

  const VisualizadorImagem({
    super.key,
    required this.caminho,
    this.titulo,
  });

  static Future<void> abrir(
    BuildContext context, {
    required String caminho,
    String? titulo,
  }) {
    return Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: VisualizadorImagem(caminho: caminho, titulo: titulo),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.branco),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Voltar',
        ),
        title: titulo == null
            ? null
            : Text(
                titulo!,
                style: const TextStyle(color: AppColors.branco, fontSize: 16),
              ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: ImagemInteligente(
                caminho: caminho,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MensagemErro extends StatelessWidget {
  final String mensagem;
  final VoidCallback? aoTentarNovamente;

  const MensagemErro({
    super.key,
    required this.mensagem,
    this.aoTentarNovamente,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.erro),
            const SizedBox(height: 12),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            if (aoTentarNovamente != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: aoTentarNovamente,
                child: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

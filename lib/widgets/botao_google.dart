import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BotaoGoogle extends StatelessWidget {
  final VoidCallback? aoPressionar;
  final bool carregando;

  const BotaoGoogle({super.key, this.aoPressionar, this.carregando = false});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: carregando ? null : aoPressionar,
      icon: carregando
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.g_mobiledata, size: 28, color: AppColors.azul),
      label: const Text(
        'Entrar com Google',
        style: TextStyle(color: AppColors.textoForte),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/status_redacao.dart';
import '../theme/app_colors.dart';

class DistintivoStatus extends StatelessWidget {
  final StatusRedacao status;

  const DistintivoStatus({super.key, required this.status});

  Color get _cor {
    switch (status) {
      case StatusRedacao.rascunho:
        return AppColors.textoApagado;
      case StatusRedacao.enviada:
        return AppColors.azul;
      case StatusRedacao.corrigida:
        return AppColors.verde;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _cor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cor.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.rotulo,
        style: TextStyle(
          color: _cor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

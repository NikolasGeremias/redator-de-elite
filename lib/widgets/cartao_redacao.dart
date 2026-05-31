import 'package:flutter/material.dart';

import '../core/utils/formatador_data.dart';
import '../models/redacao.dart';
import '../models/status_redacao.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'distintivo_status.dart';
import 'imagem_inteligente.dart';

class CartaoRedacao extends StatelessWidget {
  final Redacao redacao;
  final VoidCallback aoTocar;

  const CartaoRedacao({
    super.key,
    required this.redacao,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final dataRefiltrada = redacao.enviadoEm ?? redacao.criadoEm;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: ImagemInteligente(
                    caminho: redacao.imagemUrl,
                    placeholder: Container(
                      color: AppColors.superficieElevada,
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.textoApagado,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      redacao.titulo.isEmpty ? 'Sem título' : redacao.titulo,
                      style: AppTextStyles.subtituloDestaque,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      redacao.tema,
                      style: AppTextStyles.legenda,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        DistintivoStatus(status: redacao.status),
                        const SizedBox(width: 8),
                        Text(
                          redacao.tipoProva.rotulo,
                          style: AppTextStyles.legenda.copyWith(
                            color: AppColors.textoSuave,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _rotuloData(redacao.status, dataRefiltrada),
                      style: AppTextStyles.legenda,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _rotuloData(StatusRedacao status, DateTime data) {
    final formatada = FormatadorData.data(data);
    switch (status) {
      case StatusRedacao.rascunho:
        return 'Criada em $formatada';
      case StatusRedacao.enviada:
        return 'Enviada em $formatada';
      case StatusRedacao.corrigida:
        return 'Enviada em $formatada';
    }
  }
}

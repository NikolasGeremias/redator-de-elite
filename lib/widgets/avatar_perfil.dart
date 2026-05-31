import 'package:flutter/material.dart';

import '../core/utils/carregador_imagem.dart';
import '../core/utils/saudacao_util.dart';
import '../theme/app_colors.dart';

class AvatarPerfil extends StatelessWidget {
  final String nomeCompleto;
  final String? fotoPath;
  final double raio;
  final VoidCallback? aoTocar;
  final Widget? sobreposicao;

  const AvatarPerfil({
    super.key,
    required this.nomeCompleto,
    this.fotoPath,
    this.raio = 28,
    this.aoTocar,
    this.sobreposicao,
  });

  @override
  Widget build(BuildContext context) {
    final imagem = CarregadorImagem.imagemPara(fotoPath);
    final avatar = CircleAvatar(
      radius: raio,
      backgroundColor: AppColors.bege,
      backgroundImage: imagem,
      child: imagem == null
          ? Text(
              SaudacaoUtil.iniciaisDoNome(nomeCompleto),
              style: TextStyle(
                color: AppColors.preto,
                fontWeight: FontWeight.bold,
                fontSize: raio * 0.6,
              ),
            )
          : null,
    );
    final conteudo = sobreposicao == null
        ? avatar
        : Stack(children: [avatar, sobreposicao!]);
    if (aoTocar == null) return conteudo;
    return InkWell(
      borderRadius: BorderRadius.circular(raio),
      onTap: aoTocar,
      child: conteudo,
    );
  }
}

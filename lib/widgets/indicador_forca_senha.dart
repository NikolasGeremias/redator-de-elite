import 'package:flutter/material.dart';

import '../core/utils/validador_senha.dart';
import '../theme/app_colors.dart';

class IndicadorForcaSenha extends StatelessWidget {
  final String senha;

  const IndicadorForcaSenha({super.key, required this.senha});

  @override
  Widget build(BuildContext context) {
    final nivel = ValidadorSenha.avaliarForca(senha);
    final dados = _dadosPara(nivel);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: dados.preenchimento,
            backgroundColor: AppColors.superficieElevada,
            color: dados.cor,
            minHeight: 6,
          ),
        ),
        if (senha.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            dados.texto,
            style: TextStyle(
              fontSize: 12,
              color: dados.cor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 8),
        _Requisito(
          texto: 'Mínimo de 8 caracteres',
          atendido: ValidadorSenha.temTamanhoMinimo(senha),
        ),
        _Requisito(
          texto: 'Pelo menos uma letra',
          atendido: ValidadorSenha.temLetra(senha),
        ),
        _Requisito(
          texto: 'Pelo menos um número',
          atendido: ValidadorSenha.temNumero(senha),
        ),
        _Requisito(
          texto: 'Pelo menos um caractere especial',
          atendido: ValidadorSenha.temEspecial(senha),
        ),
      ],
    );
  }

  _DadosForca _dadosPara(NivelForcaSenha nivel) {
    switch (nivel) {
      case NivelForcaSenha.vazia:
        return _DadosForca(
          texto: '',
          preenchimento: 0,
          cor: AppColors.borda,
        );
      case NivelForcaSenha.fraca:
        return _DadosForca(
          texto: 'Fraca',
          preenchimento: 0.25,
          cor: AppColors.erro,
        );
      case NivelForcaSenha.media:
        return _DadosForca(
          texto: 'Média',
          preenchimento: 0.5,
          cor: AppColors.aviso,
        );
      case NivelForcaSenha.boa:
        return _DadosForca(
          texto: 'Boa',
          preenchimento: 0.75,
          cor: AppColors.azul,
        );
      case NivelForcaSenha.forte:
        return _DadosForca(
          texto: 'Forte',
          preenchimento: 1,
          cor: AppColors.verde,
        );
    }
  }
}

class _DadosForca {
  final String texto;
  final double preenchimento;
  final Color cor;

  _DadosForca({
    required this.texto,
    required this.preenchimento,
    required this.cor,
  });
}

class _Requisito extends StatelessWidget {
  final String texto;
  final bool atendido;

  const _Requisito({required this.texto, required this.atendido});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(
            atendido ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: atendido ? AppColors.verde : AppColors.cinzaMedio,
          ),
          const SizedBox(width: 6),
          Text(
            texto,
            style: TextStyle(
              fontSize: 12,
              color: atendido ? AppColors.textoSuave : AppColors.textoApagado,
            ),
          ),
        ],
      ),
    );
  }
}

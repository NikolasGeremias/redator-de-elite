import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/criterios_avaliacao.dart';
import '../../core/utils/formatador_data.dart';
import '../../models/correcao.dart';
import '../../models/perfil_usuario.dart';
import '../../models/redacao.dart';
import '../../models/status_redacao.dart';
import '../../models/tipo_prova.dart';
import '../../routes/nomes_rotas.dart';
import '../../services/provedores_globais.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/carregando.dart';
import '../../widgets/distintivo_status.dart';
import '../../widgets/imagem_inteligente.dart';
import '../../widgets/mensagem_erro.dart';
import '../../widgets/visualizador_imagem.dart';

class PaginaDetalhesRedacao extends ConsumerWidget {
  final String redacaoId;

  const PaginaDetalhesRedacao({super.key, required this.redacaoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final redacaoAsync = ref.watch(redacaoPorIdProvider(redacaoId));
    final perfilAsync = ref.watch(perfilAtualProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da Redação')),
      body: redacaoAsync.when(
        loading: () => const Carregando(),
        error: (e, _) =>
            MensagemErro(mensagem: 'Falha ao carregar redação: $e'),
        data: (redacao) {
          if (redacao == null) {
            return const MensagemErro(mensagem: 'Redação não encontrada.');
          }
          return perfilAsync.when(
            loading: () => const Carregando(),
            error: (e, _) =>
                MensagemErro(mensagem: 'Falha ao carregar perfil: $e'),
            data: (perfil) {
              if (perfil == null) return const Carregando();
              return _ConteudoDetalhes(redacao: redacao, perfil: perfil);
            },
          );
        },
      ),
    );
  }
}

class _ConteudoDetalhes extends ConsumerWidget {
  final Redacao redacao;
  final PerfilUsuario perfil;

  const _ConteudoDetalhes({required this.redacao, required this.perfil});

  Future<void> _confirmarExclusao(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(repositorioRedacaoProvider);
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir rascunho'),
          content: const Text(
            'Tem certeza que deseja excluir este rascunho? Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.erro),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
    if (confirmar != true) return;
    try {
      router.pop();
      await repo.excluir(redacao.id);
      messenger.showSnackBar(
        const SnackBar(content: Text('Rascunho excluído.')),
      );
    } catch (erro) {
      messenger.showSnackBar(
        SnackBar(content: Text('Erro ao excluir: $erro')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final correcaoAsync = ref.watch(correcaoPorRedacaoProvider(redacao.id));
    final podeEditar = perfil.ehAluno &&
        redacao.usuarioId == perfil.id &&
        redacao.status == StatusRedacao.rascunho;
    final podeCorrigir = perfil.ehProfessor;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ImagemRedacao(caminho: redacao.imagemUrl),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    redacao.titulo.isEmpty ? 'Sem título' : redacao.titulo,
                    style: AppTextStyles.tituloMedio,
                  ),
                ),
                DistintivoStatus(status: redacao.status),
              ],
            ),
            const SizedBox(height: 12),
            _LinhaInfo(rotulo: 'Tema', valor: redacao.tema),
            _LinhaInfo(
              rotulo: 'Tipo de prova',
              valor: redacao.tipoProva.rotulo,
            ),
            _LinhaInfo(
              rotulo: 'Criada em',
              valor: FormatadorData.dataHora(redacao.criadoEm),
            ),
            if (redacao.enviadoEm != null)
              _LinhaInfo(
                rotulo: 'Enviada em',
                valor: FormatadorData.dataHora(redacao.enviadoEm!),
              ),
            const SizedBox(height: 24),
            if (podeEditar) ...[
              FilledButton.icon(
                onPressed: () => context.push(
                  NomesRotas.parametroEditarRedacao(redacao.id),
                ),
                icon: const Icon(Icons.edit),
                label: const Text('Editar rascunho'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _confirmarExclusao(context, ref),
                icon: const Icon(Icons.delete_outline, color: AppColors.erro),
                label: const Text(
                  'Excluir rascunho',
                  style: TextStyle(color: AppColors.erro),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppColors.erro.withValues(alpha: 0.4),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            correcaoAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Carregando(),
              ),
              error: (e, _) =>
                  MensagemErro(mensagem: 'Falha ao carregar correção: $e'),
              data: (correcao) {
                if (correcao == null) {
                  if (redacao.status == StatusRedacao.rascunho) {
                    return const SizedBox.shrink();
                  }
                  return _SemCorrecao(
                    mostrarBotao: podeCorrigir,
                    aoCorrigir: () => context.push(
                      NomesRotas.parametroCorrigirRedacao(redacao.id),
                    ),
                  );
                }
                return _BlocoCorrecao(
                  correcao: correcao,
                  podeEditar: podeCorrigir,
                  aoEditar: () => context.push(
                    NomesRotas.parametroCorrigirRedacao(redacao.id),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagemRedacao extends StatelessWidget {
  final String caminho;

  const _ImagemRedacao({required this.caminho});

  @override
  Widget build(BuildContext context) {
    final temImagem = caminho.isNotEmpty;
    final conteudo = AspectRatio(
      aspectRatio: 4 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ImagemInteligente(
          caminho: caminho,
          placeholder: Container(
            color: AppColors.superficieElevada,
            alignment: Alignment.center,
            child: const Icon(
              Icons.image_outlined,
              size: 64,
              color: AppColors.textoApagado,
            ),
          ),
        ),
      ),
    );
    if (!temImagem) return conteudo;
    return GestureDetector(
      onTap: () => VisualizadorImagem.abrir(
        context,
        caminho: caminho,
        titulo: 'Redação',
      ),
      child: conteudo,
    );
  }
}

class _LinhaInfo extends StatelessWidget {
  final String rotulo;
  final String valor;

  const _LinhaInfo({required this.rotulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              rotulo,
              style: AppTextStyles.legenda.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textoSuave,
              ),
            ),
          ),
          Expanded(
            child: Text(valor, style: AppTextStyles.corpo),
          ),
        ],
      ),
    );
  }
}

class _SemCorrecao extends StatelessWidget {
  final bool mostrarBotao;
  final VoidCallback aoCorrigir;

  const _SemCorrecao({
    required this.mostrarBotao,
    required this.aoCorrigir,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.superficie,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borda),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.hourglass_empty,
                size: 48,
                color: AppColors.textoApagado,
              ),
              const SizedBox(height: 8),
              Text(
                'Aguardando correção',
                style: AppTextStyles.subtituloDestaque,
              ),
              const SizedBox(height: 4),
              Text(
                'A correção aparecerá aqui assim que estiver pronta.',
                textAlign: TextAlign.center,
                style: AppTextStyles.corpoMedio,
              ),
            ],
          ),
        ),
        if (mostrarBotao) ...[
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: aoCorrigir,
            icon: const Icon(Icons.fact_check_outlined),
            label: const Text('Adicionar correção'),
          ),
        ],
      ],
    );
  }
}

class _BlocoCorrecao extends StatelessWidget {
  final Correcao correcao;
  final bool podeEditar;
  final VoidCallback aoEditar;

  const _BlocoCorrecao({
    required this.correcao,
    required this.podeEditar,
    required this.aoEditar,
  });

  Widget _itemCriterio({
    required int numero,
    required String titulo,
    required double nota,
    required TipoProva tipo,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.verde,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$numero',
              style: const TextStyle(
                color: AppColors.branco,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${CriteriosAvaliacao.rotuloItem(tipo)} $numero',
                  style: AppTextStyles.subtituloDestaque,
                ),
                const SizedBox(height: 2),
                Text(titulo, style: AppTextStyles.legenda),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            CriteriosAvaliacao.formatarNotaItem(nota, tipo),
            style: AppTextStyles.subtituloDestaque.copyWith(
              color: AppColors.verdeClaro,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tipo = correcao.tipoProva;
    final criterios = CriteriosAvaliacao.para(tipo);
    final maxTotal = CriteriosAvaliacao.notaMaximaTotal(tipo);
    final notas = [
      correcao.competencia1,
      correcao.competencia2,
      correcao.competencia3,
      correcao.competencia4,
      correcao.competencia5,
    ];
    final maxTotalFormatado = tipo == TipoProva.enem ? '1000' : '10';
    final urlCorrecao = correcao.imagemCorrecaoUrl;
    final temImagemCorrecao =
        urlCorrecao != null && urlCorrecao.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Text('Correção', style: AppTextStyles.tituloPequeno),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nota final', style: AppTextStyles.corpoMedio),
                        Text(
                          tipo.rotulo,
                          style: AppTextStyles.legenda.copyWith(
                            color: AppColors.bege,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          CriteriosAvaliacao.formatarNotaTotal(
                            correcao.notaFinal,
                            tipo,
                          ),
                          style: AppTextStyles.tituloGrande
                              .copyWith(color: AppColors.verde),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/ $maxTotalFormatado',
                          style: AppTextStyles.corpoMedio.copyWith(
                            color: AppColors.textoApagado,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: maxTotal == 0
                        ? 0
                        : (correcao.notaFinal / maxTotal).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: AppColors.superficieElevada,
                    color: AppColors.verde,
                  ),
                ),
                const Divider(height: 24),
                for (var i = 0; i < criterios.length; i++)
                  _itemCriterio(
                    numero: i + 1,
                    titulo: criterios[i],
                    nota: notas[i],
                    tipo: tipo,
                  ),
                if (correcao.comentario.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Comentário do professor',
                    style: AppTextStyles.subtituloDestaque,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.pretoSuave,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      correcao.comentario,
                      style: AppTextStyles.corpo,
                    ),
                  ),
                ],
                if (temImagemCorrecao) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Imagem da correção',
                    style: AppTextStyles.subtituloDestaque,
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => VisualizadorImagem.abrir(
                      context,
                      caminho: urlCorrecao,
                      titulo: 'Correção',
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: ImagemInteligente(caminho: urlCorrecao),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (podeEditar) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: aoEditar,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar correção'),
          ),
        ],
      ],
    );
  }
}

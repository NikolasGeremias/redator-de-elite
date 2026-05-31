import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart' show ImageSource;

import '../../core/constants/criterios_avaliacao.dart';
import '../../core/utils/formatador_nota.dart';
import '../../models/correcao.dart';
import '../../models/redacao.dart';
import '../../models/tipo_prova.dart';
import '../../services/provedores_globais.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/carregando.dart';
import '../../widgets/imagem_inteligente.dart';
import '../../widgets/mensagem_erro.dart';

class PaginaFormCorrecao extends ConsumerStatefulWidget {
  final String redacaoId;

  const PaginaFormCorrecao({super.key, required this.redacaoId});

  @override
  ConsumerState<PaginaFormCorrecao> createState() => _PaginaFormCorrecaoState();
}

class _PaginaFormCorrecaoState extends ConsumerState<PaginaFormCorrecao> {
  final _chaveForm = GlobalKey<FormState>();
  final _controladores =
      List.generate(5, (_) => TextEditingController());
  final _controladorComentario = TextEditingController();
  String? _imagemPath;
  bool _salvando = false;
  bool _inicializado = false;

  @override
  void dispose() {
    for (final c in _controladores) {
      c.dispose();
    }
    _controladorComentario.dispose();
    super.dispose();
  }

  void _inicializarComExistente(Correcao correcao) {
    if (_inicializado) return;
    _inicializado = true;
    final notas = [
      correcao.competencia1,
      correcao.competencia2,
      correcao.competencia3,
      correcao.competencia4,
      correcao.competencia5,
    ];
    for (var i = 0; i < _controladores.length; i++) {
      _controladores[i].text =
          FormatadoresNota.formatarValor(notas[i], correcao.tipoProva);
    }
    _controladorComentario.text = correcao.comentario;
    _imagemPath = correcao.imagemCorrecaoUrl;
  }

  void _inicializarParaNovaCorrecao(TipoProva tipo) {
    if (_inicializado) return;
    _inicializado = true;
    final inicial = FormatadoresNota.valorInicial(tipo);
    for (final c in _controladores) {
      c.text = inicial;
    }
  }

  Future<void> _selecionarImagem() async {
    final seletor = ref.read(servicoSeletorImagemProvider);
    final origem = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tirar foto'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da galeria'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
    if (origem == null) return;
    final path = origem == ImageSource.camera
        ? await seletor.tirarFoto()
        : await seletor.escolherDaGaleria();
    if (path != null) setState(() => _imagemPath = path);
  }

  double _notaAt(int indice, TipoProva tipo) {
    final texto = _controladores[indice].text.trim();
    if (texto.isEmpty) return 0.0;
    return double.tryParse(texto.replaceAll(',', '.')) ?? 0.0;
  }

  double _calcularNotaFinal(TipoProva tipo) {
    return Correcao.calcularNotaFinal(
      tipoProva: tipo,
      c1: _notaAt(0, tipo),
      c2: _notaAt(1, tipo),
      c3: _notaAt(2, tipo),
      c4: _notaAt(3, tipo),
      c5: _notaAt(4, tipo),
    );
  }

  Future<void> _salvar(Redacao redacao, Correcao? existente) async {
    if (!_chaveForm.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      final repoCorrecao = ref.read(repositorioCorrecaoProvider);
      final repoRedacao = ref.read(repositorioRedacaoProvider);
      final perfil = ref.read(perfilAtualProvider).value!;
      final tipo = redacao.tipoProva;
      final notas = [
        _notaAt(0, tipo),
        _notaAt(1, tipo),
        _notaAt(2, tipo),
        _notaAt(3, tipo),
        tipo == TipoProva.acafe ? 0.0 : _notaAt(4, tipo),
      ];
      if (existente == null) {
        final salva = await repoCorrecao.criar(
          redacaoId: widget.redacaoId,
          professorId: perfil.id,
          tipoProva: redacao.tipoProva,
          c1: notas[0],
          c2: notas[1],
          c3: notas[2],
          c4: notas[3],
          c5: notas[4],
          comentario: _controladorComentario.text,
          imagemUrl: _imagemPath,
        );
        await repoRedacao.marcarComoCorrigida(widget.redacaoId, salva.id);
      } else {
        await repoCorrecao.atualizar(
          existente.copiarCom(
            competencia1: notas[0],
            competencia2: notas[1],
            competencia3: notas[2],
            competencia4: notas[3],
            competencia5: notas[4],
            comentario: _controladorComentario.text,
            imagemCorrecaoUrl: _imagemPath,
          ),
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existente == null
                ? 'Correção salva com sucesso!'
                : 'Correção atualizada.',
          ),
          backgroundColor: AppColors.sucesso,
        ),
      );
      context.pop();
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar correção: $erro')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  FormFieldValidator<String> _validador(TipoProva tipo) {
    return (String? valor) {
      if (valor == null || valor.trim().isEmpty) return 'Obrigatório';
      return null;
    };
  }

  @override
  Widget build(BuildContext context) {
    final redacaoAsync = ref.watch(redacaoPorIdProvider(widget.redacaoId));
    return Scaffold(
      appBar: AppBar(title: const Text('Correção da Redação')),
      body: redacaoAsync.when(
        loading: () => const Carregando(),
        error: (e, _) =>
            MensagemErro(mensagem: 'Falha ao carregar redação: $e'),
        data: (redacao) {
          if (redacao == null) {
            return const MensagemErro(mensagem: 'Redação não encontrada.');
          }
          final correcaoAsync =
              ref.watch(correcaoPorRedacaoProvider(widget.redacaoId));
          return correcaoAsync.when(
            loading: () => const Carregando(),
            error: (e, _) =>
                MensagemErro(mensagem: 'Falha ao carregar correção: $e'),
            data: (correcao) {
              if (correcao != null) {
                _inicializarComExistente(correcao);
              } else {
                _inicializarParaNovaCorrecao(redacao.tipoProva);
              }
              return _ConteudoForm(
                redacao: redacao,
                chaveForm: _chaveForm,
                controladores: _controladores,
                controladorComentario: _controladorComentario,
                imagemPath: _imagemPath,
                notaFinal: _calcularNotaFinal(redacao.tipoProva),
                onSelecionarImagem: _selecionarImagem,
                onRemoverImagem: () => setState(() => _imagemPath = null),
                onSalvar: () => _salvar(redacao, correcao),
                salvando: _salvando,
                modoEdicao: correcao != null,
                validador: _validador(redacao.tipoProva),
                recalcular: () => setState(() {}),
              );
            },
          );
        },
      ),
    );
  }
}

class _ConteudoForm extends StatelessWidget {
  final Redacao redacao;
  final GlobalKey<FormState> chaveForm;
  final List<TextEditingController> controladores;
  final TextEditingController controladorComentario;
  final String? imagemPath;
  final double notaFinal;
  final VoidCallback onSelecionarImagem;
  final VoidCallback onRemoverImagem;
  final VoidCallback onSalvar;
  final bool salvando;
  final bool modoEdicao;
  final FormFieldValidator<String> validador;
  final VoidCallback recalcular;

  const _ConteudoForm({
    required this.redacao,
    required this.chaveForm,
    required this.controladores,
    required this.controladorComentario,
    required this.imagemPath,
    required this.notaFinal,
    required this.onSelecionarImagem,
    required this.onRemoverImagem,
    required this.onSalvar,
    required this.salvando,
    required this.modoEdicao,
    required this.validador,
    required this.recalcular,
  });

  Widget _campoCriterio(int indice) {
    final tipo = redacao.tipoProva;
    final titulos = CriteriosAvaliacao.para(tipo);
    final max = CriteriosAvaliacao.notaMaximaPorItem(tipo);
    final maxFormatado = tipo == TipoProva.enem ? '200' : '2,5';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${CriteriosAvaliacao.rotuloItem(tipo)} ${indice + 1}',
            style: AppTextStyles.subtituloDestaque,
          ),
          const SizedBox(height: 2),
          Text(titulos[indice], style: AppTextStyles.legenda),
          const SizedBox(height: 8),
          TextFormField(
            controller: controladores[indice],
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            inputFormatters: [FormatadoresNota.para(tipo)],
            decoration: InputDecoration(
              labelText: 'Nota (0 a $maxFormatado)',
              prefixIcon: const Icon(Icons.star_outline),
              suffixText:
                  '/ ${max.toStringAsFixed(max == max.roundToDouble() ? 0 : 1)}',
            ),
            validator: validador,
            onChanged: (_) => recalcular(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tipo = redacao.tipoProva;
    final quantidade = CriteriosAvaliacao.quantidade(tipo);
    final maxTotal = CriteriosAvaliacao.notaMaximaTotal(tipo);
    final notaFinalFormatada =
        CriteriosAvaliacao.formatarNotaTotal(notaFinal, tipo);
    final maxTotalFormatado = tipo == TipoProva.enem ? '1000' : '10';
    final temImagem = imagemPath != null && imagemPath!.isNotEmpty;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: chaveForm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: AppColors.preto,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.bege.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              tipo.rotulo,
                              style: AppTextStyles.legenda.copyWith(
                                color: AppColors.bege,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            '$quantidade critérios',
                            style: AppTextStyles.legenda,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            'Nota final',
                            style: AppTextStyles.subtituloDestaque,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                notaFinalFormatada,
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
                              : (notaFinal / maxTotal).clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: AppColors.superficieElevada,
                          color: AppColors.verde,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              for (var i = 0; i < quantidade; i++) _campoCriterio(i),
              const SizedBox(height: 8),
              Text('Comentário', style: AppTextStyles.subtituloDestaque),
              const SizedBox(height: 8),
              TextFormField(
                controller: controladorComentario,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Escreva observações para o aluno...',
                  alignLabelWithHint: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Adicione um comentário.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Imagem da correção (opcional)',
                style: AppTextStyles.subtituloDestaque,
              ),
              const SizedBox(height: 8),
              AspectRatio(
                aspectRatio: 4 / 3,
                child: GestureDetector(
                  onTap: onSelecionarImagem,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.superficie,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.bordaForte,
                        width: 2,
                      ),
                    ),
                    child: temImagem
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: ImagemInteligente(caminho: imagemPath),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_a_photo_outlined,
                                size: 48,
                                color: AppColors.textoApagado,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Toque para anexar imagem',
                                style: AppTextStyles.corpoMedio,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              if (temImagem) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: onRemoverImagem,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Remover'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.erro,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: salvando ? null : onSalvar,
                icon: salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.branco,
                        ),
                      )
                    : Icon(modoEdicao ? Icons.save : Icons.check),
                label:
                    Text(modoEdicao ? 'Atualizar correção' : 'Salvar correção'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

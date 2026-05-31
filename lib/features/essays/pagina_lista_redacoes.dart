import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/formatador_data.dart';
import '../../models/perfil_usuario.dart';
import '../../models/redacao.dart';
import '../../models/status_redacao.dart';
import '../../routes/nomes_rotas.dart';
import '../../services/provedores_globais.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/carregando.dart';
import '../../widgets/cartao_redacao.dart';
import '../../widgets/mensagem_erro.dart';

class FiltroRedacoes {
  final StatusRedacao? status;
  final DateTime? dataInicial;
  final DateTime? dataFinal;

  const FiltroRedacoes({this.status, this.dataInicial, this.dataFinal});

  bool get ativo => status != null || dataInicial != null || dataFinal != null;

  FiltroRedacoes copiarCom({
    StatusRedacao? status,
    DateTime? dataInicial,
    DateTime? dataFinal,
    bool limparStatus = false,
    bool limparDataInicial = false,
    bool limparDataFinal = false,
  }) {
    return FiltroRedacoes(
      status: limparStatus ? null : (status ?? this.status),
      dataInicial: limparDataInicial ? null : (dataInicial ?? this.dataInicial),
      dataFinal: limparDataFinal ? null : (dataFinal ?? this.dataFinal),
    );
  }
}

class PaginaListaRedacoes extends ConsumerStatefulWidget {
  const PaginaListaRedacoes({super.key});

  @override
  ConsumerState<PaginaListaRedacoes> createState() =>
      _PaginaListaRedacoesState();
}

class _PaginaListaRedacoesState extends ConsumerState<PaginaListaRedacoes> {
  FiltroRedacoes _filtro = const FiltroRedacoes();

  List<Redacao> _aplicarFiltro(List<Redacao> lista) {
    return lista.where((r) {
      if (_filtro.status != null && r.status != _filtro.status) {
        return false;
      }
      final dataReferencia = r.enviadoEm ?? r.criadoEm;
      if (_filtro.dataInicial != null &&
          dataReferencia.isBefore(_filtro.dataInicial!)) {
        return false;
      }
      if (_filtro.dataFinal != null &&
          dataReferencia
              .isAfter(_filtro.dataFinal!.add(const Duration(days: 1)))) {
        return false;
      }
      return true;
    }).toList();
  }

  List<Redacao> _ordenarParaProfessor(List<Redacao> lista) {
    final pendentes = <Redacao>[];
    final restantes = <Redacao>[];
    for (final r in lista) {
      if (r.status == StatusRedacao.enviada) {
        pendentes.add(r);
      } else {
        restantes.add(r);
      }
    }
    pendentes.sort((a, b) {
      final ea = a.enviadoEm ?? a.criadoEm;
      final eb = b.enviadoEm ?? b.criadoEm;
      return eb.compareTo(ea);
    });
    restantes.sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
    return [...pendentes, ...restantes];
  }

  Future<void> _abrirFiltro(bool ehProfessor) async {
    final novo = await showModalBottomSheet<FiltroRedacoes>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _BottomSheetFiltro(
        filtroAtual: _filtro,
        ehProfessor: ehProfessor,
      ),
    );
    if (novo != null) setState(() => _filtro = novo);
  }

  @override
  Widget build(BuildContext context) {
    final perfilAsync = ref.watch(perfilAtualProvider);
    return perfilAsync.when(
      loading: () => const Carregando(),
      error: (e, _) =>
          MensagemErro(mensagem: 'Falha ao carregar perfil: $e'),
      data: (perfil) {
        if (perfil == null) return const Carregando();
        return _ConteudoLista(
          perfil: perfil,
          filtro: _filtro,
          aplicarFiltro: _aplicarFiltro,
          ordenarParaProfessor: _ordenarParaProfessor,
          abrirFiltro: _abrirFiltro,
        );
      },
    );
  }
}

class _ConteudoLista extends ConsumerWidget {
  final PerfilUsuario perfil;
  final FiltroRedacoes filtro;
  final List<Redacao> Function(List<Redacao>) aplicarFiltro;
  final List<Redacao> Function(List<Redacao>) ordenarParaProfessor;
  final void Function(bool ehProfessor) abrirFiltro;

  const _ConteudoLista({
    required this.perfil,
    required this.filtro,
    required this.aplicarFiltro,
    required this.ordenarParaProfessor,
    required this.abrirFiltro,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final redacoesAsync = perfil.ehProfessor
        ? ref.watch(todasRedacoesProvider)
        : ref.watch(redacoesDoUsuarioProvider(perfil.id));

    return Scaffold(
      backgroundColor: AppColors.preto,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lista de Redações',
                          style: AppTextStyles.tituloGrande,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          perfil.ehProfessor
                              ? 'Todas as redações'
                              : perfil.nomeCompleto,
                          style: AppTextStyles.corpoMedio,
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton.filled(
                        onPressed: () => abrirFiltro(perfil.ehProfessor),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.preto,
                          foregroundColor: AppColors.branco,
                        ),
                        icon: const Icon(Icons.filter_list),
                        tooltip: 'Filtrar',
                      ),
                      if (filtro.ativo)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.verde,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: redacoesAsync.when(
                loading: () => const Carregando(),
                error: (e, _) =>
                    MensagemErro(mensagem: 'Falha ao carregar redações: $e'),
                data: (lista) {
                  var filtradas = aplicarFiltro(lista);
                  if (perfil.ehProfessor) {
                    filtradas = ordenarParaProfessor(filtradas);
                  }
                  if (filtradas.isEmpty) {
                    return _ListaVazia(filtroAtivo: filtro.ativo);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    itemCount: filtradas.length,
                    itemBuilder: (context, indice) {
                      final r = filtradas[indice];
                      return CartaoRedacao(
                        redacao: r,
                        aoTocar: () => context.push(
                          NomesRotas.parametroDetalhesRedacao(r.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: perfil.ehAluno
          ? FloatingActionButton.extended(
              onPressed: () => context.push(NomesRotas.novaRedacao),
              backgroundColor: AppColors.verde,
              foregroundColor: AppColors.branco,
              icon: const Icon(Icons.add),
              label: const Text('Nova redação'),
            )
          : null,
    );
  }
}

class _ListaVazia extends StatelessWidget {
  final bool filtroAtivo;

  const _ListaVazia({required this.filtroAtivo});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.article_outlined,
              size: 72,
              color: AppColors.textoApagado,
            ),
            const SizedBox(height: 12),
            Text(
              filtroAtivo
                  ? 'Nenhuma redação encontrada com os filtros aplicados.'
                  : 'Nenhuma redação por aqui ainda.',
              textAlign: TextAlign.center,
              style: AppTextStyles.corpoMedio,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomSheetFiltro extends StatefulWidget {
  final FiltroRedacoes filtroAtual;
  final bool ehProfessor;

  const _BottomSheetFiltro({
    required this.filtroAtual,
    required this.ehProfessor,
  });

  @override
  State<_BottomSheetFiltro> createState() => _BottomSheetFiltroState();
}

class _BottomSheetFiltroState extends State<_BottomSheetFiltro> {
  late FiltroRedacoes _filtro;

  @override
  void initState() {
    super.initState();
    _filtro = widget.filtroAtual;
  }

  Future<void> _selecionarData(bool inicial) async {
    final hoje = DateTime.now();
    final base = inicial
        ? (_filtro.dataInicial ?? DateTime(hoje.year, hoje.month - 1, hoje.day))
        : (_filtro.dataFinal ?? hoje);
    final escolhida = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2020),
      lastDate: hoje,
      locale: const Locale('pt', 'BR'),
    );
    if (escolhida == null) return;
    setState(() {
      _filtro = inicial
          ? _filtro.copiarCom(dataInicial: escolhida)
          : _filtro.copiarCom(dataFinal: escolhida);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borda,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Filtrar redações', style: AppTextStyles.tituloPequeno),
              const SizedBox(height: 20),
              Text('Status', style: AppTextStyles.subtituloDestaque),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Todos'),
                    selected: _filtro.status == null,
                    onSelected: (_) => setState(() {
                      _filtro = _filtro.copiarCom(limparStatus: true);
                    }),
                  ),
                  ...StatusRedacao.values
                      .where(
                        (s) => !(widget.ehProfessor &&
                            s == StatusRedacao.rascunho),
                      )
                      .map(
                        (s) => ChoiceChip(
                          label: Text(s.rotulo),
                          selected: _filtro.status == s,
                          onSelected: (_) => setState(() {
                            _filtro = _filtro.copiarCom(status: s);
                          }),
                        ),
                      ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Período', style: AppTextStyles.subtituloDestaque),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selecionarData(true),
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        _filtro.dataInicial == null
                            ? 'Data inicial'
                            : FormatadorData.data(_filtro.dataInicial!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selecionarData(false),
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        _filtro.dataFinal == null
                            ? 'Data final'
                            : FormatadorData.data(_filtro.dataFinal!),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context)
                          .pop(const FiltroRedacoes()),
                      child: const Text('Limpar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(_filtro),
                      child: const Text('Aplicar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

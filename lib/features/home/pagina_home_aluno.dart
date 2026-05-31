import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/criterios_avaliacao.dart';
import '../../core/utils/saudacao_util.dart';
import '../../models/perfil_usuario.dart';
import '../../models/redacao.dart';
import '../../models/status_redacao.dart';
import '../../routes/nomes_rotas.dart';
import '../../services/provedores_globais.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/carregando.dart';
import '../../widgets/mensagem_erro.dart';

class PaginaHomeAluno extends ConsumerStatefulWidget {
  final PerfilUsuario perfil;

  const PaginaHomeAluno({super.key, required this.perfil});

  @override
  ConsumerState<PaginaHomeAluno> createState() => _PaginaHomeAlunoState();
}

class _PaginaHomeAlunoState extends ConsumerState<PaginaHomeAluno> {
  bool _renovacaoVerificada = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarRenovacaoCreditos();
    });
  }

  Future<void> _verificarRenovacaoCreditos() async {
    if (_renovacaoVerificada) return;
    _renovacaoVerificada = true;
    await ref
        .read(repositorioUsuarioProvider)
        .renovarCreditosSeNecessario(widget.perfil);
  }

  @override
  Widget build(BuildContext context) {
    final redacoesAsync =
        ref.watch(redacoesDoUsuarioProvider(widget.perfil.id));
    final saudacao = SaudacaoUtil.porHora(DateTime.now());
    final primeiroNome = widget.perfil.nomeCompleto.split(' ').first;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$saudacao,', style: AppTextStyles.tituloMedio),
            Text(primeiroNome, style: AppTextStyles.tituloGrande),
            const SizedBox(height: 24),
            _CartaoCreditos(perfil: widget.perfil),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.push(NomesRotas.novaRedacao),
              icon: const Icon(Icons.add),
              label: const Text('Enviar nova redação'),
            ),
            const SizedBox(height: 28),
            Text('Evolução das notas', style: AppTextStyles.tituloPequeno),
            const SizedBox(height: 12),
            redacoesAsync.when(
              loading: () => const SizedBox(
                height: 200,
                child: Carregando(),
              ),
              error: (e, _) =>
                  MensagemErro(mensagem: 'Falha ao carregar redações: $e'),
              data: (lista) => _GraficoEvolucao(redacoes: lista),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartaoCreditos extends StatelessWidget {
  final PerfilUsuario perfil;

  const _CartaoCreditos({required this.perfil});

  @override
  Widget build(BuildContext context) {
    final total = AppConstants.creditosIniciais;
    final usados = (total - perfil.creditos).clamp(0, total);
    final disponiveis = perfil.creditos.clamp(0, total);
    final percentualUsado = total == 0 ? 0.0 : usados / total;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Créditos utilizados',
              style: AppTextStyles.subtituloDestaque,
            ),
            const SizedBox(height: 4),
            Text(
              'Usados $usados de $total',
              style: AppTextStyles.corpoMedio,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percentualUsado,
                      minHeight: 12,
                      backgroundColor: AppColors.superficieElevada,
                      color: AppColors.verde,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(percentualUsado * 100).round()}%',
                  style: AppTextStyles.subtituloDestaque,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Disponíveis: $disponiveis   •   Renovação no dia ${AppConstants.diaRenovacaoCreditos}',
              style: AppTextStyles.legenda,
            ),
          ],
        ),
      ),
    );
  }
}

class _GraficoEvolucao extends ConsumerWidget {
  final List<Redacao> redacoes;

  const _GraficoEvolucao({required this.redacoes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final corrigidas = redacoes
        .where((r) => r.status == StatusRedacao.corrigida)
        .where((r) => r.correcaoId != null)
        .toList();

    if (corrigidas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Text(
          'Suas notas vão aparecer aqui assim que as primeiras redações forem corrigidas.',
          textAlign: TextAlign.center,
          style: AppTextStyles.corpoMedio,
        ),
      );
    }

    return _GraficoNotasCarregavel(redacoesCorrigidas: corrigidas);
  }
}

class _GraficoNotasCarregavel extends ConsumerWidget {
  final List<Redacao> redacoesCorrigidas;

  const _GraficoNotasCarregavel({required this.redacoesCorrigidas});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
          child: _ListaPontos(redacoes: redacoesCorrigidas),
        ),
      ),
    );
  }
}

class _ListaPontos extends ConsumerWidget {
  final List<Redacao> redacoes;

  const _ListaPontos({required this.redacoes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordenadas = [...redacoes]
      ..sort((a, b) => a.criadoEm.compareTo(b.criadoEm));
    final pontos = <FlSpot>[];
    for (var i = 0; i < ordenadas.length; i++) {
      final correcao = ref.watch(
        correcaoPorRedacaoProvider(ordenadas[i].id),
      );
      final notaBruta = correcao.value?.notaFinal ?? 0;
      final maxTotal =
          CriteriosAvaliacao.notaMaximaTotal(ordenadas[i].tipoProva);
      final notaNormalizada =
          maxTotal == 0 ? 0.0 : (notaBruta / maxTotal) * 10.0;
      pontos.add(FlSpot(i.toDouble() + 1, notaNormalizada));
    }
    if (pontos.every((p) => p.y == 0)) {
      return const Center(child: CircularProgressIndicator());
    }
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 10,
        gridData: const FlGridData(show: true, horizontalInterval: 2),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppColors.borda),
        ),
        titlesData: const FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28, interval: 2),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 24),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: pontos,
            isCurved: true,
            color: AppColors.verde,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.verde.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}

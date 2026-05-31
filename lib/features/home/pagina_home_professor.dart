import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatador_data.dart';
import '../../core/utils/saudacao_util.dart';
import '../../models/correcao.dart';
import '../../models/perfil_usuario.dart';
import '../../services/provedores_globais.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/carregando.dart';
import '../../widgets/mensagem_erro.dart';

class PaginaHomeProfessor extends ConsumerWidget {
  final PerfilUsuario perfil;

  const PaginaHomeProfessor({super.key, required this.perfil});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saudacao = SaudacaoUtil.porHora(DateTime.now());
    final primeiroNome = perfil.nomeCompleto.split(' ').first;
    final correcoesAsync =
        ref.watch(correcoesDoProfessorProvider(perfil.id));

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$saudacao,', style: AppTextStyles.tituloMedio),
            Text(primeiroNome, style: AppTextStyles.tituloGrande),
            const SizedBox(height: 24),
            Text(
              'Redações corrigidas por dia',
              style: AppTextStyles.tituloPequeno,
            ),
            const SizedBox(height: 12),
            correcoesAsync.when(
              loading: () => const SizedBox(height: 220, child: Carregando()),
              error: (e, _) => MensagemErro(
                mensagem: 'Falha ao carregar correções: $e',
              ),
              data: (lista) => _GraficoCorrecoesPorDia(correcoes: lista),
            ),
            const SizedBox(height: 24),
            correcoesAsync.maybeWhen(
              data: (lista) => _ResumoCorrecoes(total: lista.length),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumoCorrecoes extends StatelessWidget {
  final int total;

  const _ResumoCorrecoes({required this.total});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.verde, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total corrigidas', style: AppTextStyles.legenda),
                  Text(
                    '$total',
                    style: AppTextStyles.tituloMedio,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GraficoCorrecoesPorDia extends StatelessWidget {
  final List<Correcao> correcoes;

  const _GraficoCorrecoesPorDia({required this.correcoes});

  @override
  Widget build(BuildContext context) {
    final agora = DateTime.now();
    final inicio = agora.subtract(const Duration(days: 6));
    final mapaPorDia = <DateTime, int>{};
    for (var i = 0; i < 7; i++) {
      final d = DateTime(inicio.year, inicio.month, inicio.day + i);
      mapaPorDia[d] = 0;
    }
    for (final c in correcoes) {
      final chave = DateTime(c.criadoEm.year, c.criadoEm.month, c.criadoEm.day);
      if (mapaPorDia.containsKey(chave)) {
        mapaPorDia[chave] = mapaPorDia[chave]! + 1;
      }
    }
    final dias = mapaPorDia.keys.toList();
    final grupos = <BarChartGroupData>[];
    for (var i = 0; i < dias.length; i++) {
      grupos.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: mapaPorDia[dias[i]]!.toDouble(),
              color: AppColors.verde,
              width: 18,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }
    final maxValor = mapaPorDia.values.fold<int>(
      0,
      (acc, v) => v > acc ? v : acc,
    );
    return SizedBox(
      height: 240,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (maxValor + 1).toDouble().clamp(2, double.infinity),
              barGroups: grupos,
              gridData: const FlGridData(show: true, horizontalInterval: 1),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: AppColors.borda),
              ),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 1,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (valor, _) {
                      final idx = valor.toInt();
                      if (idx < 0 || idx >= dias.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          FormatadorData.dataCurta(dias[idx]),
                          style: AppTextStyles.legenda,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

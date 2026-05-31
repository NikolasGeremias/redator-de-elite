import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/tradutor_erros_auth.dart';
import '../../core/utils/formatador_data.dart';
import '../../models/perfil_usuario.dart';
import '../../services/provedores_globais.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/avatar_perfil.dart';
import '../../widgets/carregando.dart';
import '../../widgets/mensagem_erro.dart';

class PaginaInfoConta extends ConsumerWidget {
  const PaginaInfoConta({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfilAsync = ref.watch(perfilAtualProvider);
    final userAsync = ref.watch(usuarioFirebaseProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Informações da Conta')),
      body: perfilAsync.when(
        loading: () => const Carregando(),
        error: (e, _) =>
            MensagemErro(mensagem: 'Falha ao carregar perfil: $e'),
        data: (perfil) {
          if (perfil == null) return const Carregando();
          return _Conteudo(perfil: perfil, firebaseUser: userAsync.value);
        },
      ),
    );
  }
}

class _Conteudo extends ConsumerStatefulWidget {
  final PerfilUsuario perfil;
  final User? firebaseUser;

  const _Conteudo({required this.perfil, required this.firebaseUser});

  @override
  ConsumerState<_Conteudo> createState() => _ConteudoState();
}

class _ConteudoState extends ConsumerState<_Conteudo> {
  bool _processando = false;

  bool get _googleVinculado {
    final user = widget.firebaseUser;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == 'google.com');
  }

  bool get _temSenha {
    final user = widget.firebaseUser;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == 'password');
  }

  Future<void> _vincular() async {
    setState(() => _processando = true);
    try {
      await ref.read(repositorioAuthProvider).vincularContaGoogle();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta Google vinculada com sucesso!'),
          backgroundColor: AppColors.sucesso,
        ),
      );
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(TradutorErrosAuth.traduzir(erro))),
      );
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AvatarPerfil(
              nomeCompleto: widget.perfil.nomeCompleto,
              fotoPath: widget.perfil.fotoUrl,
              raio: 64,
            ),
            const SizedBox(height: 16),
            Text(
              widget.perfil.nomeCompleto,
              style: AppTextStyles.tituloMedio,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.verde.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.perfil.tipo.rotulo,
                style: AppTextStyles.legenda.copyWith(
                  color: AppColors.verdeClaro,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _LinhaInfo(rotulo: 'E-mail', valor: widget.perfil.email),
            _LinhaInfo(
              rotulo: 'Data de nascimento',
              valor: FormatadorData.data(widget.perfil.dataNascimento),
            ),
            _LinhaInfo(
              rotulo: 'Membro desde',
              valor: FormatadorData.data(widget.perfil.criadoEm),
            ),
            if (widget.perfil.ehAluno) ...[
              _CartaoCreditosDisponiveis(perfil: widget.perfil),
              if (widget.perfil.ultimaRenovacaoCreditos != null)
                _LinhaInfo(
                  rotulo: 'Última renovação',
                  valor: FormatadorData.data(
                    widget.perfil.ultimaRenovacaoCreditos!,
                  ),
                ),
            ],
            const SizedBox(height: 16),
            _CartaoGoogle(
              vinculada: _googleVinculado,
              temSenha: _temSenha,
              processando: _processando,
              aoVincular: _vincular,
            ),
          ],
        ),
      ),
    );
  }
}

class _CartaoCreditosDisponiveis extends StatelessWidget {
  final PerfilUsuario perfil;

  const _CartaoCreditosDisponiveis({required this.perfil});

  @override
  Widget build(BuildContext context) {
    final total = AppConstants.creditosIniciais;
    final disponiveis = perfil.creditos.clamp(0, total);
    final percentualDisponivel = total == 0 ? 0.0 : disponiveis / total;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Créditos disponíveis',
            style: AppTextStyles.legenda.copyWith(
              color: AppColors.textoSuave,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$disponiveis de $total',
            style: AppTextStyles.tituloPequeno,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percentualDisponivel,
                    minHeight: 10,
                    backgroundColor: AppColors.superficieElevada,
                    color: AppColors.verde,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(percentualDisponivel * 100).round()}%',
                style: AppTextStyles.subtituloDestaque,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartaoGoogle extends StatelessWidget {
  final bool vinculada;
  final bool temSenha;
  final bool processando;
  final VoidCallback aoVincular;

  const _CartaoGoogle({
    required this.vinculada,
    required this.temSenha,
    required this.processando,
    required this.aoVincular,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.g_mobiledata, size: 32, color: AppColors.azul),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conta Google',
                      style: AppTextStyles.subtituloDestaque,
                    ),
                    Text(
                      vinculada ? 'Vinculada' : 'Não vinculada',
                      style: AppTextStyles.legenda.copyWith(
                        color: vinculada
                            ? AppColors.verdeClaro
                            : AppColors.textoApagado,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (vinculada)
                const Icon(Icons.check_circle, color: AppColors.verde)
              else
                const Icon(
                  Icons.cancel_outlined,
                  color: AppColors.textoApagado,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (vinculada)
            Text(
              temSenha
                  ? 'Sua conta está vinculada ao Google. Você pode entrar usando os dois métodos.'
                  : 'Sua conta foi criada com o Google. O acesso é feito sempre por essa conta Google.',
              style: AppTextStyles.corpoMedio,
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Vincule sua conta Google para também poder entrar com ela.',
                  style: AppTextStyles.corpoMedio,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: processando ? null : aoVincular,
                  icon: processando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.branco,
                          ),
                        )
                      : const Icon(Icons.link),
                  label: const Text('Vincular conta Google'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _LinhaInfo extends StatelessWidget {
  final String rotulo;
  final String valor;

  const _LinhaInfo({required this.rotulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotulo,
            style: AppTextStyles.legenda.copyWith(
              color: AppColors.textoSuave,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(valor, style: AppTextStyles.corpo),
        ],
      ),
    );
  }
}
